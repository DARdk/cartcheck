#!/bin/bash

# CartChef Development Environment Setup Script

set -e

echo "🚀 Setting up CartChef development environment..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "📋 Creating .env file from template..."
    cp .env.example .env
    echo "✅ Created .env file. Please update it with your configuration."
fi

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p infra/firebase-auth
mkdir -p infra/firestore
mkdir -p logs
mkdir -p frontend/src/components
mkdir -p frontend/src/pages
mkdir -p frontend/src/hooks
mkdir -p frontend/src/services
mkdir -p frontend/src/types
mkdir -p frontend/src/utils
mkdir -p backend/api
mkdir -p backend/models
mkdir -p backend/services
mkdir -p backend/tests
mkdir -p mcp-server/src
mkdir -p mcp-server/tests

# Build and start services
echo "🐳 Building and starting Docker containers..."
docker-compose up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
docker-compose ps

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "🌐 Services are running at:"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:8000"
echo "  MCP Server: http://localhost:3001"
echo "  PostgreSQL: localhost:5432"
echo "  Redis:     localhost:6379"
echo "  Firebase UI: http://localhost:4000"
echo ""
echo "📚 Next steps:"
echo "  1. Update .env file with your Firebase credentials"
echo "  2. Run 'docker-compose logs -f' to view logs"
echo "  3. Run 'scripts/dev-stop.sh' to stop all services"
