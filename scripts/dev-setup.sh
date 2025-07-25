#!/bin/bash
set -e

echo "🚀 SuiteCRM Development Environment Setup"
echo "========================================"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists docker; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command_exists docker-compose; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file..."
    cat > .env << 'EOF'
# Database Configuration
DB_ROOT_PASSWORD=rootpass123
DB_USER=suitecrm
DB_PASSWORD=dev_suite_123

# Chatbot Configuration (optional - add your keys)
OPENAI_API_KEY=your_openai_api_key_here
SUITECRM_CLIENT_ID=your_client_id_here
SUITECRM_CLIENT_SECRET=your_client_secret_here
SUITECRM_USERNAME=admin
SUITECRM_PASSWORD=admin_password
EOF
    echo "✅ Created .env file - please update with your actual API keys"
else
    echo "✅ .env file already exists"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p docker/nginx/ssl
mkdir -p docker/fluentd
mkdir -p logs

# Choose development mode
echo ""
echo "Choose your development setup:"
echo "1) Simple (existing docker-compose.yml) - Recommended for most development"
echo "2) Advanced (docker-compose.local.yml) - AWS-like setup with load balancer"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo "🔧 Starting simple development environment..."
        docker-compose up -d
        echo ""
        echo "🎉 SuiteCRM is starting up!"
        echo "📍 Access your application at: http://localhost:8080"
        echo "📍 Database at: localhost:3306"
        echo "📍 Chatbot API at: http://localhost:8000"
        ;;
    2)
        echo "🔧 Starting advanced development environment..."
        docker-compose -f docker-compose.local.yml up -d
        echo ""
        echo "🎉 SuiteCRM is starting up!"
        echo "📍 Access your application at: http://localhost"
        echo "📍 Database at: localhost:3306"
        echo "📍 Chatbot API at: http://localhost/api/chatbot/"
        echo "📍 Health checks at: http://localhost/health/suitecrm and http://localhost/health/chatbot"
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "🔍 Service Status:"
docker-compose ps

echo ""
echo "📚 Useful Commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop services: docker-compose down"
echo "  Rebuild: docker-compose up --build"
echo "  Clean restart: docker-compose down && docker-compose up -d"
echo ""
echo "🎯 Next Steps:"
echo "  1. Wait for SuiteCRM to fully initialize (first run takes a few minutes)"
echo "  2. Access http://localhost:8080 and complete SuiteCRM setup"
echo "  3. Configure your chatbot API keys in .env file"
echo "  4. When ready for AWS deployment, use: cd terraform && ./scripts/deploy.sh dev plan"