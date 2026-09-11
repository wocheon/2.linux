#!/usr/bin/env bash
# Ubuntu용 Docker Engine 버전 선택 설치 스크립트 (v2)
# 실행: sudo bash Docker_fzf를_통한_버전별_자동설치스크립트_v2.sh
# 선택: sudo bash ... --docker-root /data/docker --containerd-root /data/containerd

set -Eeuo pipefail
IFS=$'\n\t'

readonly DOCKER_KEYRING='/etc/apt/keyrings/docker.asc'
readonly DOCKER_SOURCE='/etc/apt/sources.list.d/docker.sources'
readonly DOCKER_DAEMON_CONFIG='/etc/docker/daemon.json'
readonly CONTAINERD_CONFIG='/etc/containerd/config.toml'

DOCKER_ROOT=''
CONTAINERD_ROOT=''
CONTAINERD_STATE=''
DOCKER_RESTART_REQUIRED=0
CONTAINERD_RESTART_REQUIRED=0

usage() {
    cat <<'EOF'
Usage:
  sudo bash Docker_fzf를_통한_버전별_자동설치스크립트_v2.sh [options]

Options:
  --docker-root PATH        Docker data-root를 PATH로 설정
  --containerd-root PATH    containerd root를 PATH로 설정
  --containerd-state PATH   containerd state를 PATH로 설정
  -h, --help                도움말 출력

root directory를 변경할 때 기존 데이터가 있으면 이전 여부를 별도로 확인합니다.
EOF
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

info() {
    echo "==> $*"
}

cleanup() {
    [[ -n "${TMPDIRS:-}" ]] && rm -rf -- "$TMPDIRS"
}
trap cleanup EXIT
trap 'die "스크립트가 ${LINENO}행에서 실패했습니다."' ERR

require_root() {
    [[ $EUID -eq 0 ]] || die "root 권한이 필요합니다. sudo bash $0 로 실행하세요."
}

require_ubuntu() {
    [[ -r /etc/os-release ]] || die '/etc/os-release를 읽을 수 없습니다.'
    # shellcheck disable=SC1091
    . /etc/os-release
    [[ ${ID:-} == 'ubuntu' ]] || die "이 스크립트는 Ubuntu 전용입니다. 현재 OS: ${PRETTY_NAME:-unknown}"
}

validate_path() {
    local path=$1
    [[ $path == /* ]] || die "절대 경로만 사용할 수 있습니다: $path"
    [[ $path != *$'\n'* && $path != *'"'* ]] || die "허용되지 않는 문자가 포함된 경로입니다: $path"
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --docker-root)
                [[ $# -ge 2 ]] || die '--docker-root에는 경로가 필요합니다.'
                DOCKER_ROOT=$2
                shift 2
                ;;
            --containerd-root)
                [[ $# -ge 2 ]] || die '--containerd-root에는 경로가 필요합니다.'
                CONTAINERD_ROOT=$2
                shift 2
                ;;
            --containerd-state)
                [[ $# -ge 2 ]] || die '--containerd-state에는 경로가 필요합니다.'
                CONTAINERD_STATE=$2
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *) die "알 수 없는 옵션: $1" ;;
        esac
    done

    [[ -z $DOCKER_ROOT ]] || validate_path "$DOCKER_ROOT"
    [[ -z $CONTAINERD_ROOT ]] || validate_path "$CONTAINERD_ROOT"
    [[ -z $CONTAINERD_STATE ]] || validate_path "$CONTAINERD_STATE"
}

confirm() {
    local prompt=$1 answer
    read -r -p "$prompt [y/N]: " answer
    [[ $answer =~ ^([yY]|[yY][eE][sS])$ ]]
}

install_prerequisites() {
    info '필수 패키지 설치 및 패키지 인덱스 갱신'
    apt-get update
    apt-get install -y ca-certificates curl fzf jq rsync
}

configure_docker_repository() {
    local codename arch key_tmp source_tmp
    # shellcheck disable=SC1091
    . /etc/os-release
    codename=${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}
    [[ -n $codename ]] || die 'Ubuntu codename을 확인할 수 없습니다.'
    arch=$(dpkg --print-architecture)

    install -d -m 0755 /etc/apt/keyrings
    TMPDIRS=$(mktemp -d)
    key_tmp="$TMPDIRS/docker.asc"
    source_tmp="$TMPDIRS/docker.sources"

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$key_tmp"
    if [[ ! -f $DOCKER_KEYRING ]] || ! cmp -s "$key_tmp" "$DOCKER_KEYRING"; then
        install -m 0644 "$key_tmp" "$DOCKER_KEYRING"
        info 'Docker GPG keyring을 갱신했습니다.'
    fi

    printf '%s\n' \
        'Types: deb' \
        'URIs: https://download.docker.com/linux/ubuntu' \
        "Suites: $codename" \
        'Components: stable' \
        "Architectures: $arch" \
        "Signed-By: $DOCKER_KEYRING" > "$source_tmp"

    if [[ ! -f $DOCKER_SOURCE ]] || ! cmp -s "$source_tmp" "$DOCKER_SOURCE"; then
        install -m 0644 "$source_tmp" "$DOCKER_SOURCE"
        info 'Docker APT source를 갱신했습니다.'
    fi

    apt-get update
}

select_docker_version() {
    local candidates selected
    candidates=$(apt-cache madison docker-ce | awk -F'|' '
        NF >= 3 {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
            if ($2 != "") print $2 "\t" $3
        }
    ' | awk '!seen[$1]++')
    [[ -n $candidates ]] || die '설치 가능한 docker-ce 버전을 찾지 못했습니다.'

    # 이 함수는 command substitution으로 호출되므로 stdout은 TTY가 아니다.
    # fzf는 후보 목록을 stdin으로 받고, 대화형 UI는 controlling terminal(/dev/tty)을 사용한다.
    [[ -r /dev/tty && -w /dev/tty ]] \
        || die 'fzf 선택을 위한 controlling TTY(/dev/tty)를 사용할 수 없습니다.'

    if ! selected=$(printf '%s\n' "$candidates" | fzf \
        --delimiter=$'\t' \
        --with-nth=1,2 \
        --prompt='Docker 버전 검색: ' \
        --header=$'Version\tRepository' \
        --height=60% \
        --border \
        --reverse \
        --select-1); then
        die '버전 선택이 취소되었습니다.'
    fi

    printf '%s\n' "${selected%%$'\t'*}"
}

installed_version() {
    local package=$1
    dpkg-query -W -f='${Version}' "$package" 2>/dev/null || true
}

ensure_docker_packages() {
    local target_version=$1 current_engine current_cli current_containerd
    current_engine=$(installed_version docker-ce)
    current_cli=$(installed_version docker-ce-cli)
    current_containerd=$(installed_version containerd.io)

    if [[ $current_engine == "$target_version" && $current_cli == "$target_version" ]] \
        && dpkg-query -W containerd.io docker-compose-plugin docker-buildx-plugin >/dev/null 2>&1; then
        info "Docker Engine $target_version 및 Compose/Buildx가 이미 설치되어 있습니다."
        return
    fi

    if [[ -n $current_engine && $current_engine != "$target_version" ]]; then
        echo "현재 Docker Engine: $current_engine"
        echo "선택 Docker Engine: $target_version"
        echo "containerd.io 현재 버전: ${current_containerd:-미설치}"
        confirm 'Docker 버전 변경을 진행하시겠습니까?' || die '사용자가 버전 변경을 취소했습니다.'
    fi

    info "Docker Engine $target_version 설치"
    apt-get install -y --allow-downgrades \
        "docker-ce=$target_version" \
        "docker-ce-cli=$target_version" \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
}

directory_has_data() {
    local path=$1
    [[ -d $path ]] && find "$path" -mindepth 1 -maxdepth 1 -print -quit | grep -q .
}

stop_runtime_services() {
    info 'Docker/containerd 서비스를 중지합니다.'
    systemctl stop docker.service docker.socket 2>/dev/null || true
    systemctl stop containerd.service 2>/dev/null || true
}

migrate_data_if_requested() {
    local source=$1 target=$2 label=$3
    [[ $source == "$target" ]] && return
    [[ $target != "$source"/* && $source != "$target"/* ]] \
        || die "$label root directory는 기존 경로 내부 또는 상위 경로로 지정할 수 없습니다."

    if directory_has_data "$source"; then
        echo "$label 기존 데이터가 감지되었습니다: $source"
        confirm "$target 로 데이터를 이전하시겠습니까?" \
            || die "데이터 손실 방지를 위해 $label root directory 변경을 중단합니다."
        install -d -m 0711 "$target"
        info "$label 데이터를 이전합니다."
        rsync -aHAX --numeric-ids "$source/" "$target/"
    else
        install -d -m 0711 "$target"
    fi
}

configure_docker_root() {
    local current_root tmp
    [[ -n $DOCKER_ROOT ]] || return

    current_root='/var/lib/docker'
    if [[ -f $DOCKER_DAEMON_CONFIG ]]; then
        jq -e . "$DOCKER_DAEMON_CONFIG" >/dev/null \
            || die "$DOCKER_DAEMON_CONFIG 가 유효한 JSON이 아닙니다. 직접 수정 후 다시 실행하세요."
        current_root=$(jq -r '.["data-root"] // "/var/lib/docker"' "$DOCKER_DAEMON_CONFIG")
    fi
    [[ $current_root == "$DOCKER_ROOT" ]] && { info 'Docker data-root가 이미 설정되어 있습니다.'; return; }

    stop_runtime_services
    migrate_data_if_requested "$current_root" "$DOCKER_ROOT" 'Docker'

    tmp=$(mktemp)
    if [[ -f $DOCKER_DAEMON_CONFIG ]]; then
        jq --arg root "$DOCKER_ROOT" '.["data-root"] = $root' "$DOCKER_DAEMON_CONFIG" > "$tmp"
    else
        jq -n --arg root "$DOCKER_ROOT" '{"data-root": $root}' > "$tmp"
    fi
    install -d -m 0755 /etc/docker
    install -m 0644 "$tmp" "$DOCKER_DAEMON_CONFIG"
    rm -f -- "$tmp"
    DOCKER_RESTART_REQUIRED=1
    CONTAINERD_RESTART_REQUIRED=1
}

containerd_config_value() {
    local key=$1 fallback=$2
    [[ -f $CONTAINERD_CONFIG ]] || { printf '%s\n' "$fallback"; return; }
    awk -v key="$key" -v fallback="$fallback" '
        $0 ~ "^[[:space:]]*#?[[:space:]]*" key "[[:space:]]*=[[:space:]]*\"" {
            value=$0
            sub("^[[:space:]]*#?[[:space:]]*" key "[[:space:]]*=[[:space:]]*\"", "", value)
            sub("\".*$", "", value)
            print value
            found=1
            exit
        }
        END { if (!found) print fallback }
    ' "$CONTAINERD_CONFIG"
}

configure_containerd_root() {
    local current_root current_state tmp
    [[ -n $CONTAINERD_ROOT || -n $CONTAINERD_STATE ]] || return

    if [[ ! -f $CONTAINERD_CONFIG ]]; then
        install -d -m 0755 /etc/containerd
        containerd config default > "$CONTAINERD_CONFIG"
    fi

    current_root=$(containerd_config_value root '/var/lib/containerd')
    current_state=$(containerd_config_value state '/run/containerd')
    [[ -n $CONTAINERD_ROOT ]] || CONTAINERD_ROOT=$current_root
    [[ -n $CONTAINERD_STATE ]] || CONTAINERD_STATE=$current_state

    if [[ $current_root == "$CONTAINERD_ROOT" && $current_state == "$CONTAINERD_STATE" ]]; then
        info 'containerd root/state가 이미 설정되어 있습니다.'
        return
    fi

    stop_runtime_services
    migrate_data_if_requested "$current_root" "$CONTAINERD_ROOT" 'containerd'
    install -d -m 0755 "$CONTAINERD_STATE"

    tmp=$(mktemp)
    awk -v root="$CONTAINERD_ROOT" -v state="$CONTAINERD_STATE" '
        /^[[:space:]]*#?[[:space:]]*root[[:space:]]*=/ {
            print "root = \"" root "\""
            root_seen=1
            next
        }
        /^[[:space:]]*#?[[:space:]]*state[[:space:]]*=/ {
            print "state = \"" state "\""
            state_seen=1
            next
        }
        { print }
        END {
            if (!root_seen) print "root = \"" root "\""
            if (!state_seen) print "state = \"" state "\""
        }
    ' "$CONTAINERD_CONFIG" > "$tmp"
    install -m 0644 "$tmp" "$CONTAINERD_CONFIG"
    rm -f -- "$tmp"
    CONTAINERD_RESTART_REQUIRED=1
    DOCKER_RESTART_REQUIRED=1
}

start_and_verify() {
    if (( CONTAINERD_RESTART_REQUIRED )); then
        systemctl enable --now containerd.service
    fi
    systemctl enable --now docker.service

    systemctl is-active --quiet docker.service || die 'Docker service가 active 상태가 아닙니다.'
    docker --version
    docker compose version
    docker buildx version
    info 'Docker 동작 검증(hello-world)'
    docker run --rm hello-world
}

main() {
    parse_arguments "$@"
    require_root
    require_ubuntu
    install_prerequisites
    configure_docker_repository

    local selected_version
    selected_version=$(select_docker_version)
    echo "선택한 Docker Engine 버전: $selected_version"
    ensure_docker_packages "$selected_version"
    configure_docker_root
    configure_containerd_root
    start_and_verify
    info 'Docker 설치 및 검증이 완료되었습니다.'
}

main "$@"
