# GitHub Actions CI/CD Setup

## Workflows

### 1. CI Pipeline (`ci.yml`)
- **Triggers**: Push/PR to `main`, `hotfix`, `develop` branches
- **Purpose**: Run tests and code quality checks
- **Features**:
  - Automated SuiteCRM silent installation in container
  - PHPUnit unit tests on fully installed system
  - Code quality checks (PHPCS, PHPStan)
  - Security scanning with Trivy
  - Docker-based testing environment with GitHub Actions MySQL

### 2. Staging Deployment (`deploy-staging.yml`)
- **Triggers**: Push to `staging` branch or manual dispatch
- **Purpose**: Deploy to AWS staging environment
- **Features**:
  - Automated SuiteCRM silent installation for testing
  - Run tests before deployment with quality gates
  - Build and push Docker images to ECR
  - Deploy using Terraform
  - Force deployment option for manual runs

## Required GitHub Secrets

Add these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

### AWS Deployment Secrets
```
AWS_ACCESS_KEY_ID       # AWS access key for deployment
AWS_SECRET_ACCESS_KEY   # AWS secret key for deployment
ADMIN_PASSWORD          # Admin password for SuiteCRM deployment
```

### Optional Secrets (if needed)
```
OPENAI_API_KEY         # For chatbot functionality
SUITECRM_CLIENT_ID     # OAuth client ID
SUITECRM_CLIENT_SECRET # OAuth client secret
```

## Current Configuration

The workflow is configured for your specific AWS setup:

```yaml
env:
  AWS_REGION: us-east-1
  AWS_ACCOUNT_ID: 787187109626
  ECR_REPOSITORY_SUITECRM: suitecrm-staging-suitecrm
  ECR_REPOSITORY_CHATBOT: suitecrm-staging-chatbot
```

### Deployment Process
The staging deployment mirrors your manual process:

1. **Build Images**: Both SuiteCRM and Chatbot with `--platform=linux/amd64`
2. **Tag for ECR**: Using your account ID and repository names
3. **Push to ECR**: Both latest and commit-tagged versions
4. **Run Terraform**: From `terraform/environments/staging` directory
5. **Apply Changes**: With `admin_password` variable from secrets

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