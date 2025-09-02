#!/usr/bin/python3.9
import google.auth
import google.auth.transport.requests
from google.auth.transport.requests import AuthorizedSession
import time
import requests
import json

PROJECT_ID = 'project-id'
BACKUP_REGION = 'region'
BACKUP_RETENTION_TIME_DAYS = 30

credentials, project = google.auth.default()
request = google.auth.transport.requests.Request()
credentials.refresh(request)
authed_session = AuthorizedSession(credentials)

now = time.time()
retention_seconds = BACKUP_RETENTION_TIME_DAYS * 24 * 60 * 60

def delete_backup(request):
    backups_to_delete = []
    trigger_run_url = "https://file.googleapis.com/v1beta1/projects/{}/locations/{}/backups".format(PROJECT_ID, BACKUP_REGION)
    r = authed_session.get(trigger_run_url)
    data = r.json()

    if not data:
        return "No backups to delete."
    
    backups_to_delete.extend(data.get('backups', []))

    while 'nextPageToken' in data:
        nextPageToken = data['nextPageToken']
        trigger_run_url_next = "https://file.googleapis.com/v1beta1/projects/{}/locations/{}/backups?pageToken={}".format(PROJECT_ID, BACKUP_REGION, nextPageToken)
        r = authed_session.get(trigger_run_url_next)
        data = r.json()
        backups_to_delete.extend(data.get('backups', []))

    deleted_backups = []
    for backup in backups_to_delete:
        backup_time = backup['createTime'][:-4]
        backup_time = float(time.mktime(time.strptime(backup_time, "%Y-%m-%dT%H:%M:%S.%f")))
        if now - backup_time > retention_seconds:
            backup_name = backup['name']
            print(f"Deleting {backup_name} in the background.")
            r = authed_session.delete(f"https://file.googleapis.com/v1beta1/{backup_name}")
            if r.status_code == requests.codes.ok:
                print(f"{r.status_code}: Successfully deleted {backup_name}.")
                deleted_backups.append(backup_name)
            else:
                error_message = r.json().get('error', 'Unknown error')
                raise RuntimeError(f"Error deleting {backup_name}: {error_message}")

    if deleted_backups:
        return f"Successfully deleted {len(deleted_backups)} backups: {', '.join(deleted_backups)}"
    else:
        return "No backups were deleted."
