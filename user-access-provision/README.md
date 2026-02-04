# PAM Access Management (AWS IAM)

Python scripts to create and delete PAM access for AWS IAM users using groups and managed policies.

## Prerequisites
- Python 3
- AWS CLI configured
- boto3 installed

``` text
pip install boto3
```
## Environment Variables
$env:IAM_USER_NAME="SO-Assessment-Divya-PyAdmin"
$env:IAM_GROUP_NAME="PyAdmin"
$env:IAM_POLICY_TYPE="admin"

IAM_POLICY_TYPE values: 
admin | readonly | poweruser

## Create PAM Access
Creates IAM group, attaches policy, creates user, and adds user to group.
- python create-pam.py

## Delete PAM Access
Removes user from group, detaches all policies, deletes user and group.
- python delete-pam.py