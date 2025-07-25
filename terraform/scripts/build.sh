#!/bin/bash
set -e

ENV=${1:-staging}
REGION=${2:-us-east-1}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Building images for environment: $ENV"
echo "Region: $REGION"
echo "Account ID: $ACCOUNT_ID"

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push SuiteCRM
echo "Building SuiteCRM image..."
docker build -f docker/suitecrm/Dockerfile -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-suitecrm:latest .
echo "Pushing SuiteCRM image..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-suitecrm:latest

# Build and push Chatbot  
echo "Building Chatbot image..."
docker build -f suitecrm_chatbot/Dockerfile -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-chatbot:latest ./suitecrm_chatbot/
echo "Pushing Chatbot image..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-chatbot:latest

echo "Images built and pushed successfully"
echo "SuiteCRM: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-suitecrm:latest"
echo "Chatbot: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-chatbot:latest"