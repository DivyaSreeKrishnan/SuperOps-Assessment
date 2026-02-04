#Delete PAM access for users

import os
import boto3

iam = boto3.client('iam')

user_name = os.getenv("IAM_USER_NAME")
group_name = os.getenv("IAM_GROUP_NAME")

if not user_name or not group_name:
    raise ValueError("IAM_USER_NAME and IAM_GROUP_NAME must be set")

try:
    iam.remove_user_from_group(GroupName=group_name, UserName=user_name)
    print("User removed from group")
except Exception:
    print("User not in group")

try:
    policies = iam.list_attached_group_policies(GroupName=group_name)["AttachedPolicies"]
    for policy in policies:
        iam.detach_group_policy(
            GroupName=group_name,
            PolicyArn=policy["PolicyArn"]
        )
        print(f"Detached policy: {policy['PolicyName']}")
except Exception:
    print("No policies attached")

try:
    iam.delete_user(UserName=user_name)
    print("User deleted")
except Exception:
    print("User already deleted")

try:
    iam.delete_group(GroupName=group_name)
    print("Group deleted")
except Exception as e:
    print("Group delete failed:", e)