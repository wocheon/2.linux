#!/bin/bash

# 1. 환경 변수 로드
if [ -f "solr_backup.env" ]; then
    source solr_backup.env
else
    echo "Error: solr.env file not found!"
    exit 1
fi

# jq 설치 확인
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

# 메뉴 출력 함수
show_menu() {
    echo "================================================"
    echo "   Solr GCS Backup/Admin Manager"
    echo "   URL: $SOLR_URL"
    echo "================================================"
    echo "1) [BACKUP] Start Async Backup"
    echo "2) [STATUS] Check Async Job Status"
    echo "3) [LIST]   List Backups in Repository"
    echo "4) [DELETE] Delete Backup Points (Retention)"
    echo "5) [PURGE]  Purge Unused Files (GC)"
    echo "6) [ADMIN]  Flush All Async Status"
    echo "7) [RESTORE] Restore from Backup"
    echo "q) Quit"
    echo "------------------------------------------------"
}

# 공통 API 호출 함수
call_api() {
    local params=$1
    curl -s -X POST "$SOLR_URL/admin/collections" $params | jq .
}

# 메인 루프
while true; do
    show_menu
    read -p "Select an option: " choice

    case $choice in
        1)
            read -p "Collection [$DEFAULT_COLLECTION]: " col
            col=${col:-$DEFAULT_COLLECTION}
            read -p "Backup Name [$DEFAULT_BACKUP_NAME]: " bname
            bname=${bname:-$DEFAULT_BACKUP_NAME}
            async_id="backup_${col}_${TIMESTAMP}"

            echo "Starting Backup for $col..."
            call_api "--data-urlencode action=BACKUP \
                      --data-urlencode name=$bname \
                      --data-urlencode collection=$col \
                      --data-urlencode repository=$REPOSITORY_NAME \
                      --data-urlencode location=$BACKUP_LOCATION \
                      --data-urlencode async=$async_id"
            echo -e "\n>>> ASYNC_ID: $async_id"
            ;;
        2)
            read -p "Enter Request ID to check: " req_id
            curl -s "$SOLR_URL/admin/collections?action=REQUESTSTATUS&requestid=$req_id" | jq .
            ;;
        3)
            read -p "Backup Name [$DEFAULT_BACKUP_NAME]: " bname
            bname=${bname:-$DEFAULT_BACKUP_NAME}
            call_api "--data-urlencode action=LISTBACKUP \
                      --data-urlencode name=$bname \
                      --data-urlencode repository=$REPOSITORY_NAME \
                      --data-urlencode location=$BACKUP_LOCATION"
            ;;
        4)
            read -p "Backup Name [$DEFAULT_BACKUP_NAME]: " bname
            bname=${bname:-$DEFAULT_BACKUP_NAME}
            read -p "Max Backup Points to KEEP (0 for all): " max_pts
            call_api "--data-urlencode action=DELETEBACKUP \
                      --data-urlencode name=$bname \
                      --data-urlencode repository=$REPOSITORY_NAME \
                      --data-urlencode location=$BACKUP_LOCATION \
                      --data-urlencode maxNumBackupPoints=$max_pts"
            ;;
        5)
            read -p "Backup Name [$DEFAULT_BACKUP_NAME]: " bname
            bname=${bname:-$DEFAULT_BACKUP_NAME}
            echo "Purging unused files for $bname... This may take a while."
            call_api "--data-urlencode action=DELETEBACKUP \
                      --data-urlencode name=$bname \
                      --data-urlencode repository=$REPOSITORY_NAME \
                      --data-urlencode location=$BACKUP_LOCATION \
                      --data-urlencode purgeUnused=true"
            ;;
        6)
            read -p "Are you sure you want to FLUSH all status? (y/n): " confirm
            if [[ $confirm == "y" ]]; then
                call_api "--data-urlencode action=DELETESTATUS \
                          --data-urlencode flush=true"
            fi
            ;;
        7)
            read -p "Backup Name to Restore: " bname
            read -p "New Collection Name: " new_col
            read -p "Backup ID (Number): " bid
            async_id="restore_${new_col}_${TIMESTAMP}"

            call_api "--data-urlencode action=RESTORE \
                      --data-urlencode name=$bname \
                      --data-urlencode collection=$new_col \
                      --data-urlencode repository=$REPOSITORY_NAME \
                      --data-urlencode location=$BACKUP_LOCATION \
                      --data-urlencode backupId=$bid \
                      --data-urlencode async=$async_id"
            echo -e "\n>>> ASYNC_ID: $async_id"
            ;;
        q)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo ""
done
