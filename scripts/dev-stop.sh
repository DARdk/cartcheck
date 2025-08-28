#!/bin/bash

# CartChef Development Environment Stop Script

set -e

echo "🛑 Stopping CartChef development environment..."

# Stop and remove containers
docker-compose down

echo "✅ All services stopped."
echo ""
echo "💡 To remove all data volumes, run:"
echo "   docker-compose down -v"
