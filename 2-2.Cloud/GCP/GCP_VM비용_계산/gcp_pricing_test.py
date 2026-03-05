# -*- coding: utf-8 -*-
import pandas as pd
import re
import warnings
import pytz
from datetime import datetime, timedelta
from croniter import croniter
from google.cloud import compute_v1

warnings.filterwarnings("ignore", category=FutureWarning)

def calculate_sud(series: str, hours: float, hourly_rate: float):
    total_hours_in_month = 730.0
    usage_fraction = min(hours / total_hours_in_month, 1.0)
    base_cost = hours * hourly_rate
    # 가동 시간이 0시간이면 할인도 없고 비용도 0원
    if base_cost == 0: return 0.0, "-"

    eligible_30 = ['n1', 'm1', 'm2']
    eligible_20 = ['n2', 'n2d', 'c2', 'c2d']
    if series not in eligible_30 and series not in eligible_20: return base_cost, "X"

    rates = [1.0, 0.80, 0.60, 0.40] if series in eligible_30 else [1.0, 0.866667, 0.733333, 0.60]
    remaining, cost_fraction = usage_fraction, 0.0

    for rate in rates:
        if remaining > 0.25:
            cost_fraction += 0.25 * rate; remaining -= 0.25
        else:
            cost_fraction += remaining * rate; break

    discounted_cost = cost_fraction * total_hours_in_month * hourly_rate
    if hours > total_hours_in_month: discounted_cost += (hours - total_hours_in_month) * hourly_rate * rates[-1]

    if usage_fraction > 0.25:
        return discounted_cost, f"O ({(1 - (discounted_cost / base_cost)) * 100:.1f}%↓)"
    return discounted_cost, "미달"

def calculate_monthly_running_hours(start_cron: str, stop_cron: str, timezone_str: str) -> float:
    try:
        tz = pytz.timezone(timezone_str)
        now = datetime.now(tz)
        end_time = now + timedelta(days=30)
        start_iter, stop_iter = croniter(start_cron, now), croniter(stop_cron, now)

        total_seconds = 0
        while True:
            next_start = start_iter.get_next(datetime)
            if next_start > end_time: break
            stop_iter = croniter(stop_cron, next_start)
            next_stop = stop_iter.get_next(datetime)
            if next_stop > end_time: next_stop = end_time
            duration = (next_stop - next_start).total_seconds()
            if duration > 0: total_seconds += duration

        return round(total_seconds / 3600.0, 1)
    except Exception: return 216.0

def load_pricing_from_csv(csv_path: str, target_region: str) -> dict:
    try: df = pd.read_csv(csv_path)
    except FileNotFoundError: return {}
    df.rename(columns={'regions': 'region', 'usageUnit': 'unit', 'price(KRW)': 'price'}, inplace=True)
    df_region = df[df['region'].str.contains(target_region, na=False)].copy()
    pricing = {}

    for _, row in df_region.iterrows():
        desc = str(row['description']).lower()
        try: price = float(row['price'])
        except (ValueError, TypeError): continue
        if any(k in desc for k in ['spot', 'preemptible', 'sole tenancy', 'commitment', 'premium']): continue

        if 'small instance with 1 vcpu' in desc: pricing['n1_g1-small'] = price
        elif 'micro instance with burstable cpu' in desc: pricing['n1_f1-micro'] = price
        elif 'balanced pd capacity' in desc: pricing['pd-balanced'] = price
        elif 'ssd backed pd capacity' in desc: pricing['pd-ssd'] = price
        elif 'extreme pd capacity' in desc: pricing['pd-extreme'] = price
        elif 'storage pd capacity' in desc or ('pd' in desc and 'standard' in desc): pricing['pd-standard'] = price
        else:
            match = re.search(r'([a-z0-9]+)\s+(predefined|custom)?\s*(?:instance)?\s*(core|ram)', desc)
            if match: pricing[f"{match.group(1)}_{match.group(2) if match.group(2) else 'predefined'}_{match.group(3)}"] = price
    return pricing

def extract_specs_from_machine_type(machine_type: str) -> dict:
    if machine_type == 'f1-micro': return {"series": "n1", "vcpu": 1, "ram_gb": 0.6, "category": "f1-micro"}
    if machine_type == 'g1-small': return {"series": "n1", "vcpu": 1, "ram_gb": 1.7, "category": "g1-small"}
    e2_shared = {"e2-micro": (0.25, 1.0), "e2-small": (0.5, 2.0), "e2-medium": (1.0, 4.0)}
    if machine_type in e2_shared: return {"series": "e2", "vcpu": e2_shared[machine_type][0], "ram_gb": e2_shared[machine_type][1], "category": "predefined"}

    match = re.match(r'^custom-(\d+)-(\d+)$', machine_type)
    if match: return {"series": "n1", "vcpu": int(match.group(1)), "ram_gb": int(match.group(2)) / 1024.0, "category": "custom"}

    match = re.match(r'^([a-z0-9]+)-custom-(\d+)-(\d+)$', machine_type)
    if match: return {"series": match.group(1), "vcpu": int(match.group(2)), "ram_gb": int(match.group(3)) / 1024.0, "category": "custom"}

    match = re.match(r'^([a-z0-9]+)-(standard|highmem|highcpu)-(\d+)$', machine_type)
    if match:
        series, subtype, vcpu = match.group(1), match.group(2), int(match.group(3))
        ram_gb = vcpu * {"standard": 3.75, "highmem": 6.5, "highcpu": 0.9}[subtype] if series == 'n1' else vcpu * {"standard": 4.0, "highmem": 8.0, "highcpu": 1.0}[subtype]
        return {"series": series, "vcpu": vcpu, "ram_gb": ram_gb, "category": "predefined"}
    return {"series": "unknown", "vcpu": 2, "ram_gb": 8.0, "category": "predefined"}

def get_disk_types_map(project_id: str) -> dict:
    disk_client = compute_v1.DisksClient()
    return {disk.self_link: (disk.type.split('/')[-1] if disk.type else 'pd-balanced')
            for _, response in disk_client.aggregated_list(request=compute_v1.AggregatedListDisksRequest(project=project_id))
            if response.disks for disk in response.disks}

def get_instance_schedules(project_id: str, region: str) -> dict:
    policy_client = compute_v1.ResourcePoliciesClient()
    schedule_map = {}
    try:
        for policy in policy_client.list(request=compute_v1.ListResourcePoliciesRequest(project=project_id, region=region)):
            if policy.instance_schedule_policy:
                schedule_map[policy.self_link] = {
                    "name": policy.name, "start_cron": policy.instance_schedule_policy.vm_start_schedule.schedule,
                    "stop_cron": policy.instance_schedule_policy.vm_stop_schedule.schedule, "timezone": policy.instance_schedule_policy.time_zone
                }
    except Exception: pass
    return schedule_map

def get_active_commitments(project_id: str, region: str) -> dict:
    client = compute_v1.RegionCommitmentsClient()
    cud_map = {}
    try:
        for commitment in client.list(request=compute_v1.ListRegionCommitmentsRequest(project=project_id, region=region)):
            if commitment.status == "ACTIVE":
                ctype_upper = (commitment.type_ if commitment.type_ else "COMPUTE").upper()
                if "E2" in ctype_upper: series = "e2"
                elif "N2D" in ctype_upper: series = "n2d"
                elif "N2" in ctype_upper: series = "n2"
                elif "C2" in ctype_upper or "OPTIMIZED" in ctype_upper: series = "c2"
                else: series = "n1"

                if series not in cud_map: cud_map[series] = {"vcpu": 0.0, "ram_gb": 0.0}
                for resource in commitment.resources:
                    if resource.type_ == "VCPU": cud_map[series]["vcpu"] += float(resource.amount)
                    elif resource.type_ == "MEMORY": cud_map[series]["ram_gb"] += (float(resource.amount) / 1024.0)
    except Exception: pass
    return cud_map

def generate_final_vm_cost_report(project_id: str, csv_path: str = "compute_pricing.csv", target_region: str = "asia-northeast3"):
    instance_client = compute_v1.InstancesClient()
    rates = load_pricing_from_csv(csv_path, target_region)
    disk_type_map = get_disk_types_map(project_id)
    schedule_map = get_instance_schedules(project_id, target_region)
    cud_map = get_active_commitments(project_id, target_region)

    print("\n| VM명 | Zone | 상태/일정 | SUD | Machine | vCPU | RAM | Boot | Add Disk | VM 월비용 | Disk 총비용 | **총 월비용** |")
    print("|:---|:---|:---|:---:|:---|---:|---:|:---|:---|---:|---:|---:|")

    usage_map = {}
    total_disk_cost_all = 0.0
    total_all_vms = 0.0

    request = compute_v1.AggregatedListInstancesRequest(project=project_id)

    for zone_path, response in instance_client.aggregated_list(request=request):
        if not response.instances: continue
        zone = zone_path.split('/')[-1]
        if target_region not in zone: continue

        for instance in response.instances:
            # [수정] RUNNING이 아니어도 필터링하지 않고 처리합니다.
            vm_name = instance.name
            is_running = (instance.status == "RUNNING")
            machine_type = instance.machine_type.split('/')[-1]
            specs = extract_specs_from_machine_type(machine_type)
            series, vcpu_count, ram_gb, category = specs["series"], specs["vcpu"], specs["ram_gb"], specs["category"]

            # [수정] 상태 및 스케줄에 따른 가동 시간 동적 판별
            estimated_hours = 730.0 if is_running else 0.0
            status_str = "실행중(730h)" if is_running else "중지됨(0h)"

            if instance.resource_policies:
                for policy_url in instance.resource_policies:
                    if policy_url in schedule_map:
                        p_data = schedule_map[policy_url]
                        # 스케줄이 있다면 현재 상태(중지/실행)에 상관없이 월 예상 스케줄 시간을 적용합니다.
                        estimated_hours = calculate_monthly_running_hours(p_data["start_cron"], p_data["stop_cron"], p_data["timezone"])
                        status_str = f"일정O({estimated_hours}h)"
                        break

            # 디스크 계산 (VM이 중지되어 있어도 100% 계산됩니다)
            boot_info, attached_info, total_disk_cost = "", [], 0.0
            for disk in instance.disks:
                size = int(disk.disk_size_gb) if disk.disk_size_gb else 0
                d_type = disk_type_map.get(disk.source, "pd-balanced")
                total_disk_cost += (size * rates.get(d_type, rates.get('pd-standard', 0.0)))

                info_str = f"{size}GB({d_type})"
                if disk.boot: boot_info = info_str
                else: attached_info.append(info_str)
            attached_str = ", ".join(attached_info) if attached_info else "-"

            if category in ["f1-micro", "g1-small"]: hourly_vm_cost = rates.get(f"n1_{category}", 0.0)
            else:
                vcpu_rate = rates.get(f"{series}_{category}_core", rates.get(f"{series}_predefined_core", 0.0))
                ram_rate = rates.get(f"{series}_{category}_ram", rates.get(f"{series}_predefined_ram", 0.0))
                hourly_vm_cost = (vcpu_rate * vcpu_count) + (ram_rate * ram_gb)

            # VM 컴퓨팅 비용 (estimated_hours가 0이면 vm_monthly_cost도 0이 됩니다)
            vm_monthly_cost, sud_flag = calculate_sud(series, estimated_hours, hourly_vm_cost)
            total_monthly_cost = vm_monthly_cost + total_disk_cost

            total_disk_cost_all += total_disk_cost
            total_all_vms += total_monthly_cost

            # [수정] 구동 시간(비용 발생)이 있는 경우에만 CUD 차감 풀에 추가합니다.
            if estimated_hours > 0:
                if series not in usage_map:
                    usage_map[series] = {"vcpu": 0.0, "ram_gb": 0.0, "cost": 0.0}
                usage_map[series]["vcpu"] += float(vcpu_count)
                usage_map[series]["ram_gb"] += float(ram_gb)
                usage_map[series]["cost"] += vm_monthly_cost

            display_vcpu = f"{vcpu_count}" if isinstance(vcpu_count, int) else f"{vcpu_count:.2f}"
            print(f"| {vm_name} | {zone} | {status_str} | {sud_flag} | {machine_type} | {display_vcpu} | {ram_gb:.1f}GB | {boot_info} | {attached_str} | ₩{vm_monthly_cost:,.0f} | ₩{total_disk_cost:,.0f} | **₩{total_monthly_cost:,.0f}** |")

    # (이하 CUD 서머리 부분 로직은 이전과 동일하므로 생략 없이 출력됩니다)
    print("\n### 📊 리전 비용 요약 및 시리즈별 CUD(약정) 적용 상세")
    print("\n#### [시리즈별 자원 및 약정 커버리지]")
    print("| 시리즈 | 구동 중 자원(비용발생) | CUD 보유량 | 커버리지(예상) | 해당VM 총비용 | 약정 할인액 |")
    print("|:---|:---|:---|---:|---:|---:|")

    total_raw_vm_cost = sum(d["cost"] for d in usage_map.values())
    total_cud_savings = 0.0
    all_series = set(usage_map.keys()).union(set(cud_map.keys()))

    for s in sorted(all_series):
        used_v = usage_map.get(s, {}).get("vcpu", 0.0)
        used_r = usage_map.get(s, {}).get("ram_gb", 0.0)
        used_cost = usage_map.get(s, {}).get("cost", 0.0)

        cud_v = cud_map.get(s, {}).get("vcpu", 0.0)
        cud_r = cud_map.get(s, {}).get("ram_gb", 0.0)

        cov_v = min(cud_v / used_v, 1.0) if used_v > 0 else (1.0 if cud_v > 0 else 0.0)
        cov_r = min(cud_r / used_r, 1.0) if used_r > 0 else (1.0 if cud_r > 0 else 0.0)
        avg_cov = 0.0 if (used_v == 0 and used_r == 0) else (cov_v + cov_r) / 2.0

        savings = (used_cost * avg_cov) * 0.37
        total_cud_savings += savings
        print(f"| {s.upper()} | {used_v:.1f} vCPU / {used_r:.1f}GB | {cud_v:.1f} vCPU / {cud_r:.1f}GB | {avg_cov*100:.1f}% | ₩{used_cost:,.0f} | -₩{savings:,.0f} |")

    final_billed_cost = (total_raw_vm_cost + total_disk_cost_all) - total_cud_savings

    print("\n#### [최종 예상 청구액]")
    print("| 청구 항목 | 예상 금액 |")
    print("|:---|---:|")
    print(f"| 1. 전체 디스크 비용 (중지된 VM 포함) | ₩{total_disk_cost_all:,.0f} |")
    print(f"| 2. 전체 VM 비용 (SUD 자동 반영가) | ₩{total_raw_vm_cost:,.0f} |")
    if total_cud_savings > 0: print(f"| 3. 시리즈별 CUD 누적 할인액 | **-₩{total_cud_savings:,.0f}** |")
    print(f"| **총 결제 예상액** | **₩{final_billed_cost:,.0f}** |")

# 실행 예:
# generate_final_vm_cost_report("your-project-id", "compute_pricing.csv", "asia-northeast3")
generate_final_vm_cost_report("your-project-id", "compute_pricing.csv", "asia-northeast3")
