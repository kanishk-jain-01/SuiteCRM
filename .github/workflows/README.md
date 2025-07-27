# GitHub Actions CI/CD Setup

## Workflows

### 1. CI Pipeline (`ci.yml`)
- **Triggers**: Push/PR to `main`, `hotfix`, `develop` branches
- **Purpose**: Run tests and code quality checks
- **Features**:
  - PHPUnit unit tests
  - Code quality checks (PHPCS, PHPStan)
  - Security scanning with Trivy
  - Docker-based testing environment

### 2. Staging Deployment (`deploy-staging.yml`)
- **Triggers**: Push to `staging` branch or manual dispatch
- **Purpose**: Deploy to AWS staging environment
- **Features**:
  - Run tests before deployment
  - Build and push Docker images to ECR
  - Deploy using Terraform
  - Force deployment option for manual runs

## Required GitHub Secrets

Add these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

### AWS Deployment Secrets
```
AWS_ACCESS_KEY_ID       # AWS access key for deployment
AWS_SECRET_ACCESS_KEY   # AWS secret key for deployment
```

### Optional Secrets (if needed)
```
OPENAI_API_KEY         # For chatbot functionality
SUITECRM_CLIENT_ID     # OAuth client ID
SUITECRM_CLIENT_SECRET # OAuth client secret
```

## Environment Variables to Update

In `deploy-staging.yml`, update these values to match your AWS setup:

```yaml
env:
  AWS_REGION: us-east-1           # Your AWS region
  ECR_REPOSITORY: suitecrm-app    # Your ECR repository name
  ECS_SERVICE: suitecrm-service   # Your ECS service name
  ECS_CLUSTER: suitecrm-cluster   # Your ECS cluster name
```

## Testing the Setup

1. **CI Pipeline**: Create a PR to any main branch to trigger tests
2. **Staging Deployment**: Push to `staging` branch or use manual dispatch

## Local Testing Commands

Test the same commands locally:
```bash
# Start services
docker compose up -d

# Run tests
docker compose exec suitecrm bash -c "cd tests && ../vendor/bin/phpunit unit/phpunit/ConfigTest.php"
docker compose exec suitecrm bash -c "cd tests && ../vendor/bin/phpunit unit/phpunit/data/"
docker compose exec suitecrm bash -c "cd tests && ../vendor/bin/phpunit unit/phpunit/includes/"

# Code quality
docker compose exec suitecrm vendor/bin/phpcs --standard=PSR2 --extensions=php --ignore=vendor/,cache/,upload/ .
docker compose exec suitecrm vendor/bin/phpstan analyse --memory-limit=2G
```