# SuiteCRM Terraform Infrastructure

This repository contains Terraform configurations for deploying SuiteCRM with a Python FastAPI chatbot on AWS using ECS Fargate.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Account                         │
├─────────────────────────────────────────────────────────────┤
│  VPC (10.x.0.0/16)                                         │
│  ┌─────────────────┐  ┌─────────────────┐                  │
│  │  Public Subnet   │  │  Private Subnet │                  │
│  │  (Web Tier)     │  │  (App Tier)     │                  │
│  │  ┌─────────────┐ │  │  ┌─────────────┐│                  │
│  │  │     ALB     │ │  │  │ ECS Cluster ││                  │
│  │  │  + WAF      │ │  │  │ - SuiteCRM  ││                  │
│  │  │             │ │  │  │ - Chatbot   ││                  │
│  │  └─────────────┘ │  │  └─────────────┘│                  │
│  └─────────────────┘  └─────────────────┘                  │
│                       ┌─────────────────┐                  │
│                       │  Private Subnet │                  │
│                       │  (Data Tier)    │                  │
│                       │  ┌─────────────┐│                  │
│                       │  │     RDS     ││                  │
│                       │  │     EFS     ││                  │
│                       │  │     S3      ││                  │
│                       │  └─────────────┘│                  │
│                       └─────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

## Infrastructure Components

### Networking
- **VPC**: Isolated network environment with public/private subnets across multiple AZs
- **Internet Gateway**: Internet access for public resources
- **NAT Gateways**: Outbound internet access for private resources
- **Security Groups**: Network-level firewall rules

### Compute
- **ECS Fargate Cluster**: Serverless container orchestration
- **Application Load Balancer**: SSL termination and traffic distribution
- **Target Groups**: Health checking and load balancing

### Storage
- **RDS MySQL 8.0**: Managed database with automated backups
- **EFS**: Shared file system for persistent data
- **S3**: Static assets and backup storage
- **ECR**: Container image repositories

### Security
- **IAM Roles**: Service-to-service authentication
- **KMS**: Encryption key management
- **Secrets Manager**: Secure credential storage
- **Security Groups**: Network access control

### Monitoring
- **CloudWatch**: Logging, metrics, and dashboards
- **SNS**: Alert notifications
- **X-Ray**: Distributed tracing (optional)

## Directory Structure

```
terraform/
├── main.tf                    # Main configuration
├── variables.tf               # Global variables
├── outputs.tf                 # Global outputs
├── versions.tf                # Provider versions
├── modules/                   # Reusable modules
│   ├── vpc/                   # VPC and networking
│   ├── security/              # Security groups and IAM
│   ├── rds/                   # Database configuration
│   ├── ecs/                   # ECS cluster and services
│   ├── storage/               # EFS and S3
│   ├── ecr/                   # Container repositories
│   └── monitoring/            # CloudWatch and alerting
└── environments/              # Environment-specific configs
    ├── dev/                   # Development environment
    ├── staging/               # Staging environment
    └── prod/                  # Production environment
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **Docker** for building container images
4. **Domain name** and **SSL certificate** (for production)

## Quick Start

### 1. Clone and Navigate
```bash
cd terraform/environments/dev
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review Variables
Edit `terraform.tfvars` with your specific configuration:
```hcl
aws_region = "us-east-1"
default_tags = {
  Project     = "SuiteCRM"
  Environment = "dev"
  Owner       = "YourTeam"
}
```

### 4. Plan Deployment
```bash
terraform plan
```

### 5. Deploy Infrastructure
```bash
terraform apply
```

### 6. Build and Push Container Images
```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and push SuiteCRM image
cd ../../../
docker build -f docker/suitecrm/Dockerfile -t <account-id>.dkr.ecr.us-east-1.amazonaws.com/suitecrm-dev-suitecrm:latest .
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/suitecrm-dev-suitecrm:latest

# Build and push Chatbot image
docker build -f suitecrm_chatbot/Dockerfile -t <account-id>.dkr.ecr.us-east-1.amazonaws.com/suitecrm-dev-chatbot:latest ./suitecrm_chatbot/
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/suitecrm-dev-chatbot:latest
```

## Environment Configuration

### Development
- **VPC CIDR**: 10.0.0.0/16
- **Database**: db.t3.micro, 20GB storage
- **ECS Tasks**: 1 SuiteCRM, 1 Chatbot
- **Backup Retention**: 3 days

### Staging
- **VPC CIDR**: 10.1.0.0/16
- **Database**: db.t3.small, 50GB storage
- **ECS Tasks**: 2 SuiteCRM, 1 Chatbot
- **Backup Retention**: 7 days

### Production
- **VPC CIDR**: 10.2.0.0/16
- **Database**: db.t3.medium, 100GB storage, Multi-AZ
- **ECS Tasks**: 3 SuiteCRM, 2 Chatbot
- **Backup Retention**: 30 days

## Required Secrets

Before deploying, create these secrets in AWS Secrets Manager:

1. **Database Password**: Auto-generated and stored securely
2. **OpenAI API Key**: For chatbot functionality
3. **SuiteCRM OAuth Credentials**: For chatbot integration

## Deployment Scripts

### Build Script (`scripts/build.sh`)
```bash
#!/bin/bash
set -e

ENV=${1:-dev}
REGION=${2:-us-east-1}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "Building images for environment: $ENV"

# Login to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push SuiteCRM
docker build -f docker/suitecrm/Dockerfile -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-suitecrm:latest .
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-suitecrm:latest

# Build and push Chatbot  
docker build -f suitecrm_chatbot/Dockerfile -t $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-chatbot:latest ./suitecrm_chatbot/
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/suitecrm-$ENV-chatbot:latest

echo "Images built and pushed successfully"
```

### Deploy Script (`scripts/deploy.sh`)
```bash
#!/bin/bash
set -e

ENV=${1:-dev}
ACTION=${2:-apply}

echo "Deploying to environment: $ENV"

cd terraform/environments/$ENV

terraform init
terraform $ACTION

if [ "$ACTION" = "apply" ]; then
    echo "Deployment completed successfully"
    echo "ALB DNS Name: $(terraform output -raw alb_dns_name)"
fi
```

## Monitoring and Alerts

### CloudWatch Dashboards
- **ECS Metrics**: CPU, Memory, Task counts
- **ALB Metrics**: Request count, response times, error rates
- **RDS Metrics**: Database performance

### Automated Alerts
- High CPU/Memory utilization (>80%)
- Database connection failures
- Application errors (5xx responses)

### Log Aggregation
- Application logs centralized in CloudWatch
- Structured logging with JSON format
- Log retention policies by environment

## Security Features

### Network Security
- Private subnets for application and database tiers
- Security groups with minimal required access
- WAF protection for web applications

### Data Protection
- Encryption at rest (RDS, EFS, S3)
- Encryption in transit (ALB, EFS)
- Secrets stored in AWS Secrets Manager

### Access Control
- IAM roles with least privilege principle
- No hardcoded credentials
- Service-to-service authentication

## Backup and Disaster Recovery

### Automated Backups
- RDS automated backups with point-in-time recovery
- EFS automatic backups
- S3 versioning for static assets

### Recovery Procedures
1. **Database Recovery**: Restore from RDS backup
2. **Application Recovery**: Redeploy from ECR images
3. **File Recovery**: Restore from EFS backup

## Cost Optimization

### Development
- Single AZ deployment
- Smaller instance sizes
- Shorter backup retention

### Production
- Reserved instances for predictable workloads
- Auto-scaling for variable traffic
- S3 lifecycle policies for log archival

## Troubleshooting

### Common Issues

1. **ECS Tasks Not Starting**
   - Check CloudWatch logs for container errors
   - Verify ECR image availability
   - Check security group configuration

2. **Database Connection Issues**
   - Verify security group rules
   - Check Secrets Manager permissions
   - Validate database endpoint

3. **Load Balancer Health Checks Failing**
   - Check application health endpoint
   - Verify target group configuration
   - Review security group rules

### Useful Commands

```bash
# View ECS service status
aws ecs describe-services --cluster suitecrm-dev-cluster --services suitecrm-dev-suitecrm-service

# Check CloudWatch logs
aws logs describe-log-groups --log-group-name-prefix "/ecs/suitecrm-dev"

# View RDS status
aws rds describe-db-instances --db-instance-identifier suitecrm-dev-db
```

## Contributing

1. Create feature branch from `main`
2. Make changes in isolated environment
3. Test thoroughly before merging
4. Update documentation as needed

## Support

For issues and questions:
- Check CloudWatch logs first
- Review AWS documentation
- File issues in project repository

## License

This infrastructure code is provided under the MIT License.