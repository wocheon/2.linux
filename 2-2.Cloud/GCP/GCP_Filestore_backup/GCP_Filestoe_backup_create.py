#! /usr/bin/python3

PROJECT_ID = 'project-id'
SOURCE_INSTANCE_ZONE = 'filestore-zone'
SOURCE_INSTANCE_NAME = 'filestore-name'
SOURCE_FILE_SHARE_NAME = 'file-share-name'
BACKUP_REGION = 'backup-region'

import google.auth
import google.auth.transport.requests
from google.auth.transport.requests import AuthorizedSession
import time
import requests
import json

credentials, project = google.auth.default()
request = google.auth.transport.requests.Request()
credentials.refresh(request)
authed_session = AuthorizedSession(credentials)

def get_backup_id():
    return "mybackup-" + time.strftime("%Y%m%d-%H%M%S")


def create_backup(request):
    trigger_run_url = "https://file.googleapis.com/v1beta1/projects/{}/locations/{}/backups?backupId={}".format(PROJECT_ID, BACKUP_REGION, get_backup_id())
    headers = {
        'Content-Type': 'application/json'
    }
    post_data = {
        "description": "my new backup",
        "source_instance": "projects/{}/locations/{}/instances/{}".format(PROJECT_ID, SOURCE_INSTANCE_ZONE, SOURCE_INSTANCE_NAME),
        "source_file_share": "{}".format(SOURCE_FILE_SHARE_NAME)
    }
    print("Making a request to " + trigger_run_url)
    r = authed_session.post(url=trigger_run_url, headers=headers, data=json.dumps(post_data))
    data = r.json()
    print(data)
    if r.status_code == requests.codes.ok:
        print(str(r.status_code) + ": The backup is uploading in the background.")
        return {"status": "success", "message": "Backup started successfully."}, 200
    else:
        error_message = data.get('error', 'Unknown error')
        print(f"Error: {error_message}")
        return {"status": "error", "message": error_message}, r.status_code
