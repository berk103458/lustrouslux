import requests
import base64
import json

KEY_ID = '4cdaff7e8d1a'
APP_KEY = '005009d79e72e4ec8c212709ec52b15dc269bcbaa0'

def fix_bucket():
    # 1. Authorize
    auth_str = f"{KEY_ID}:{APP_KEY}"
    b64_auth = base64.b64encode(auth_str.encode()).decode()
    headers = {'Authorization': f'Basic {b64_auth}'}
    
    print("Authenticating...")
    resp = requests.get('https://api.backblazeb2.com/b2api/v2/b2_authorize_account', headers=headers)
    if resp.status_code != 200:
        print(f"Auth Failed: {resp.text}")
        return
        
    data = resp.json()
    api_url = data['apiUrl']
    auth_token = data['authorizationToken']
    account_id = data['accountId']
    
    # 2. List Buckets
    print("Listing Buckets...")
    resp = requests.post(f"{api_url}/b2api/v2/b2_list_buckets", 
                         headers={'Authorization': auth_token},
                         json={'accountId': account_id})
                         
    buckets = resp.json().get('buckets', [])
    if not buckets:
        print("No buckets found!")
        return
        
    for bucket in buckets:
        b_name = bucket['bucketName']
        b_type = bucket['bucketType']
        b_id = bucket['bucketId']
        print(f"Found Bucket: {b_name} | Type: {b_type} | ID: {b_id}")
        
        if b_type != 'allPublic':
            print(f"!!! Bucket {b_name} is PRIVATE. Making Public...")
            # 3. Update to Public
            update_resp = requests.post(f"{api_url}/b2api/v2/b2_update_bucket",
                headers={'Authorization': auth_token},
                json={
                    'accountId': account_id,
                    'bucketId': b_id,
                    'bucketType': 'allPublic',
                    'corsRules': [{
                        'corsRuleName': 'allowAny',
                        'allowedOrigins': ['*'],
                        'allowedOperations': ['b2_download_file_by_name', 'b2_download_file_by_id', 'b2_upload_file'],
                        'allowedHeaders': ['*'],
                        'maxAgeSeconds': 3600
                    }]
                }
            )
            print(f"Update Result: {update_resp.status_code} - {update_resp.text}")
        else:
            print(f"Bucket {b_name} is already PUBLIC. Verifying CORS...")
            # Ensure CORS even if public
            update_resp = requests.post(f"{api_url}/b2api/v2/b2_update_bucket",
                headers={'Authorization': auth_token},
                json={
                    'accountId': account_id,
                    'bucketId': b_id,
                    'bucketType': 'allPublic',
                    'corsRules': [{
                        'corsRuleName': 'allowAny',
                        'allowedOrigins': ['*'],
                        'allowedOperations': ['b2_download_file_by_name', 'b2_download_file_by_id', 'b2_upload_file'],
                        'allowedHeaders': ['*'],
                        'maxAgeSeconds': 3600
                    }]
                }
            )
            print(f"CORS Update: {update_resp.status_code}")

if __name__ == "__main__":
    fix_bucket()
