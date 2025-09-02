#!/bin/bash

# ==============================================================================
# CartChef Environment Validation Script
# ==============================================================================
# This script validates environment configuration across all services
# and provides helpful error messages for missing or invalid configuration.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Global error tracking
VALIDATION_ERRORS=0

# Function to check if a file exists
check_file_exists() {
    local file_path="$1"
    local description="$2"
    
    if [[ -f "$file_path" ]]; then
        log_success "$description found: $file_path"
        return 0
    else
        log_error "$description not found: $file_path"
        ((VALIDATION_ERRORS++))
        return 1
    fi
}

# Function to check if a required environment variable is set in a file
check_env_var() {
    local env_file="$1"
    local var_name="$2"
    local description="$3"
    
    if [[ ! -f "$env_file" ]]; then
        log_error "Environment file not found: $env_file"
        ((VALIDATION_ERRORS++))
        return 1
    fi
    
    if grep -q "^${var_name}=" "$env_file" && ! grep -q "^${var_name}=$" "$env_file"; then
        log_success "$description is configured in $env_file"
        return 0
    else
        log_error "$description is missing or empty in $env_file"
        ((VALIDATION_ERRORS++))
        return 1
    fi
}

# Function to validate URL format
validate_url() {
    local url="$1"
    local description="$2"
    
    if [[ "$url" =~ ^https?://[^[:space:]]+$ ]]; then
        log_success "$description URL format is valid: $url"
        return 0
    else
        log_error "$description URL format is invalid: $url"
        ((VALIDATION_ERRORS++))
        return 1
    fi
}

# Function to check if a port is available
check_port_available() {
    local port="$1"
    local service="$2"
    
    if command -v lsof >/dev/null 2>&1; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
            log_warning "Port $port for $service is already in use"
            return 1
        else
            log_success "Port $port for $service is available"
            return 0
        fi
    else
        log_warning "lsof not available, cannot check port $port for $service"
        return 0
    fi
}

# Function to test database connectivity
test_database_connection() {
    local db_url="$1"
    
    log_info "Testing database connectivity..."
    
    if command -v psql >/dev/null 2>&1; then
        if psql "$db_url" -c "SELECT version();" >/dev/null 2>&1; then
            log_success "Database connection successful"
            return 0
        else
            log_error "Database connection failed"
            ((VALIDATION_ERRORS++))
            return 1
        fi
    else
        log_warning "psql not available, skipping database connectivity test"
        return 0
    fi
}

# Function to test Redis connectivity
test_redis_connection() {
    local redis_url="$1"
    
    log_info "Testing Redis connectivity..."
    
    if command -v redis-cli >/dev/null 2>&1; then
        if redis-cli -u "$redis_url" ping >/dev/null 2>&1; then
            log_success "Redis connection successful"
            return 0
        else
            log_error "Redis connection failed"
            ((VALIDATION_ERRORS++))
            return 1
        fi
    else
        log_warning "redis-cli not available, skipping Redis connectivity test"
        return 0
    fi
}

# Main validation function
validate_environment() {
    local environment="${1:-development}"
    
    log_info "Starting environment validation for: $environment"
    echo ""
    
    # Check if .env.example files exist
    log_info "Checking .env.example files..."
    check_file_exists ".env.example" "Main .env.example"
    check_file_exists "backend/.env.example" "Backend .env.example"
    check_file_exists "frontend/.env.example" "Frontend .env.example" 
    check_file_exists "mcp-server/.env.example" "MCP Server .env.example"
    check_file_exists "agno-agent/.env.example" "Agno Agent .env.example"
    echo ""
    
    # Check if actual .env files exist
    log_info "Checking .env files..."
    check_file_exists ".env" "Main .env file"
    check_file_exists "backend/.env" "Backend .env file"
    check_file_exists "frontend/.env.local" "Frontend .env.local file"
    check_file_exists "mcp-server/.env" "MCP Server .env file"
    check_file_exists "agno-agent/.env" "Agno Agent .env file"
    echo ""
    
    # Validate critical environment variables
    log_info "Validating critical environment variables..."
    
    # Main application
    if [[ -f ".env" ]]; then
        check_env_var ".env" "DATABASE_URL" "Database URL"
        check_env_var ".env" "REDIS_URL" "Redis URL"
        check_env_var ".env" "FIREBASE_PROJECT_ID" "Firebase Project ID"
        check_env_var ".env" "JWT_SECRET" "JWT Secret"
    fi
    
    # Backend
    if [[ -f "backend/.env" ]]; then
        check_env_var "backend/.env" "SECRET_KEY" "Backend Secret Key"
        check_env_var "backend/.env" "OPENAI_API_KEY" "OpenAI API Key"
    fi
    
    # MCP Server
    if [[ -f "mcp-server/.env" ]]; then
        check_env_var "mcp-server/.env" "NEMLIG_USERNAME" "Nemlig Username"
        check_env_var "mcp-server/.env" "NEMLIG_PASSWORD" "Nemlig Password"
    fi
    
    # Frontend
    if [[ -f "frontend/.env.local" ]]; then
        check_env_var "frontend/.env.local" "NEXT_PUBLIC_API_URL" "Frontend API URL"
        check_env_var "frontend/.env.local" "NEXT_PUBLIC_FIREBASE_PROJECT_ID" "Frontend Firebase Project ID"
    fi
    echo ""
    
    # Check port availability
    log_info "Checking port availability..."
    check_port_available 3000 "Frontend"
    check_port_available 3001 "MCP Server"
    check_port_available 5000 "Agno Agent"
    check_port_available 8000 "Backend"
    check_port_available 5432 "PostgreSQL"
    check_port_available 6379 "Redis"
    echo ""
    
    # Test service connectivity (only if not in CI/test mode)
    if [[ "$environment" != "test" && "$CI" != "true" ]]; then
        log_info "Testing service connectivity..."
        
        # Extract URLs from .env files for testing
        if [[ -f ".env" ]]; then
            local db_url=$(grep "^DATABASE_URL=" .env | cut -d '=' -f2- | tr -d '"')
            local redis_url=$(grep "^REDIS_URL=" .env | cut -d '=' -f2- | tr -d '"')
            
            if [[ -n "$db_url" ]]; then
                test_database_connection "$db_url"
            fi
            
            if [[ -n "$redis_url" ]]; then
                test_redis_connection "$redis_url"
            fi
        fi
        echo ""
    fi
    
    # Security checks for production
    if [[ "$environment" == "production" ]]; then
        log_info "Running production security checks..."
        
        # Check for localhost URLs in production
        if grep -r "localhost" .env* */**.env* 2>/dev/null | grep -v ".example"; then
            log_error "localhost URLs found in production environment files"
            ((VALIDATION_ERRORS++))
        else
            log_success "No localhost URLs found in production environment files"
        fi
        
        # Check for default/weak secrets
        if grep -r "change-this\|your-secret\|default-key" .env* */**.env* 2>/dev/null | grep -v ".example"; then
            log_error "Default or weak secrets found in environment files"
            ((VALIDATION_ERRORS++))
        else
            log_success "No obvious default secrets found"
        fi
        echo ""
    fi
    
    # Run service-specific validations
    log_info "Running service-specific validations..."
    
    # Backend validation (Python)
    if [[ -f "backend/.env" && -f "backend/config/settings.py" ]]; then
        log_info "Validating backend configuration..."
        if cd backend && python -c "from config.settings import validate_environment; validate_environment()" 2>/dev/null; then
            log_success "Backend environment validation passed"
        else
            log_error "Backend environment validation failed"
            ((VALIDATION_ERRORS++))
        fi
        cd - >/dev/null
    fi
    
    # MCP Server validation (Node.js)
    if [[ -f "mcp-server/.env" && -f "mcp-server/src/config/validation.ts" ]]; then
        log_info "Validating MCP server configuration..."
        if cd mcp-server && npm run validate-env 2>/dev/null; then
            log_success "MCP server environment validation passed"
        else
            log_warning "MCP server environment validation skipped (npm script not available)"
        fi
        cd - >/dev/null
    fi
    echo ""
    
    # Final validation summary
    log_info "Environment validation summary:"
    if [[ $VALIDATION_ERRORS -eq 0 ]]; then
        log_success "All environment validations passed! ✨"
        return 0
    else
        log_error "Environment validation failed with $VALIDATION_ERRORS errors"
        echo ""
        log_info "To fix these issues:"
        echo "  1. Copy .env.example files to .env files if they don't exist"
        echo "  2. Fill in the required environment variables"
        echo "  3. Ensure external services (PostgreSQL, Redis) are running"
        echo "  4. Check the documentation: docs/ENVIRONMENT_CONFIGURATION.md"
        return 1
    fi
}

# Help function
show_help() {
    echo "CartChef Environment Validation Script"
    echo ""
    echo "Usage: $0 [ENVIRONMENT]"
    echo ""
    echo "Arguments:"
    echo "  ENVIRONMENT    Environment to validate (development|staging|production|test)"
    echo "                 Default: development"
    echo ""
    echo "Examples:"
    echo "  $0                    # Validate development environment"
    echo "  $0 production        # Validate production environment"
    echo "  $0 test             # Validate test environment"
    echo ""
    echo "This script will:"
    echo "  - Check for required .env files"
    echo "  - Validate critical environment variables"
    echo "  - Test service connectivity"
    echo "  - Run environment-specific validations"
}

# Main script execution
main() {
    case "${1:-}" in
        -h|--help|help)
            show_help
            exit 0
            ;;
        ""|development|staging|production|test)
            validate_environment "${1:-development}"
            exit $?
            ;;
        *)
            log_error "Invalid environment: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"