#Create PAM access for users

import os
import boto3

iam = boto3.client('iam')

user_name = os.getenv("IAM_USER_NAME")
group_name = os.getenv("IAM_GROUP_NAME")
policy_type = os.getenv("IAM_POLICY_TYPE", "readonly").lower()

if not user_name or not group_name:
    raise ValueError("IAM_USER_NAME and IAM_GROUP_NAME must be set as environment variables")

policy_map = {
    "admin": "arn:aws:iam::aws:poliscy/AdministratorAccess",
    "readonly": "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "poweruser": "arn:aws:iam::aws:policy/PowerUserAccess"
}

if policy_type not in policy_map:
    raise ValueError("IAM_POLICY_TYPE must be admin, readonly, or poweruser")

policy_arn = policy_map[policy_type]

try:
    iam.create_group(GroupName=group_name)
    print(f"Group '{group_name}' created")
except iam.exceptions.EntityAlreadyExistsException:
    print(f"Group '{group_name}' already exists")

iam.attach_group_policy(
    GroupName=group_name,
    PolicyArn=policy_arn
)
print("AdministratorAccess policy attached to group")

try:
    iam.create_user(UserName=user_name)
    print(f"User '{user_name}' created")
except iam.exceptions.EntityAlreadyExistsException:
    print(f"User '{user_name}' already exists")

iam.add_user_to_group(
    GroupName=group_name,
    UserName=user_name
)
print(f"User '{user_name}' added to group '{group_name}'")