#!/bin/bash

# === CONFIGURATION ===
ACCOUNT_ID="650234510693"
REGION="us-east-1"
CLUSTER_NAME="demo-cluster"
ROLE_NAME="AmazonEKSALBRoleCustom"
SERVICE_ACCOUNT_NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
CUSTOM_POLICY_NAME="MyALBControllerPolicy"

# === STEP 1: Get OIDC Provider URL ===
OIDC_PROVIDER=$(aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query "cluster.identity.oidc.issuer" \
  --output text | sed 's|https://||')

echo "OIDC Provider: $OIDC_PROVIDER"

# === STEP 2: Create Trust Policy File ===
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_PROVIDER:sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
        }
      }
    }
  ]
}
EOF

# === STEP 3: Create IAM Role ===
echo "Creating IAM Role: $ROLE_NAME"
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json || echo "Role already exists"

# === STEP 4: Attach Policy to Role ===
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/$CUSTOM_POLICY_NAME"
echo "Attaching policy $CUSTOM_POLICY_NAME to role"
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn $POLICY_ARN

# === STEP 5: Annotate the Service Account ===
echo "Annotating Kubernetes service account"
kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME \
  -n $SERVICE_ACCOUNT_NAMESPACE \
  eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT
