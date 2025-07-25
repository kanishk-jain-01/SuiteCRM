#!/bin/bash
set -e

ENV=${1:-staging}
ACTION=${2:-apply}

if [[ "$ENV" != "staging" && "$ENV" != "prod" ]]; then
    echo "Error: Environment must be one of: staging, prod"
    exit 1
fi

if [[ "$ACTION" != "plan" && "$ACTION" != "apply" && "$ACTION" != "destroy" ]]; then
    echo "Error: Action must be one of: plan, apply, destroy"
    exit 1
fi

echo "Deploying to environment: $ENV"
echo "Action: $ACTION"

# Navigate to environment directory
cd "$(dirname "$0")/../environments/$ENV"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Run the specified action
echo "Running terraform $ACTION..."
terraform $ACTION

if [ "$ACTION" = "apply" ]; then
    echo ""
    echo "=== Deployment Summary ==="
    echo "Environment: $ENV"
    echo "ALB DNS Name: $(terraform output -raw alb_dns_name)"
    echo "VPC ID: $(terraform output -raw vpc_id)"
    echo "ECS Cluster: $(terraform output -raw ecs_cluster_id)"
    echo ""
    echo "Next steps:"
    echo "1. Build and push container images using: ../../scripts/build.sh $ENV"
    echo "2. Access your application at: http://$(terraform output -raw alb_dns_name)"
    echo "3. Monitor your infrastructure in the AWS Console"
fi

if [ "$ACTION" = "destroy" ]; then
    echo ""
    echo "=== Destruction Complete ==="
    echo "All resources for environment '$ENV' have been destroyed."
    echo "Note: S3 buckets with versioning may retain some data."
fi