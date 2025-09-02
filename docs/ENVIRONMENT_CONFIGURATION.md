# Environment Configuration Guide

This document provides comprehensive information about environment variables and configuration for the CartChef application.

## Overview

CartChef consists of multiple services that require environment configuration:

- **Main Application** (Root `.env`)
- **Backend API** (FastAPI service)
- **MCP Server** (Nemlig API integration)
- **Frontend** (Next.js application)
- **Agno Agent** (AI orchestration service)

## Quick Start

### Local Development Setup

1. Copy all `.env.example` files to `.env` files:
   ```bash
   cp .env.example .env
   cp backend/.env.example backend/.env
   cp frontend/.env.example frontend/.env.local
   cp mcp-server/.env.example mcp-server/.env
   cp agno-agent/.env.example agno-agent/.env
   ```

2. Fill in the required values (marked as required below)

3. Start the development environment:
   ```bash
   docker-compose up -d
   ```

## Environment Files Structure

```
CartChef/
├── .env                           # Main application config
├── backend/.env                   # FastAPI backend service
├── frontend/.env.local           # Next.js frontend application
├── mcp-server/.env              # MCP server for Nemlig API
├── agno-agent/.env              # AI agent orchestration
└── docs/ENVIRONMENT_CONFIGURATION.md
```

## Main Application Configuration (`.env`)

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@localhost:5432/cartchef` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `FIREBASE_PROJECT_ID` | Firebase project identifier | `cartchef-dev` |
| `JWT_SECRET` | Secret for JWT token signing | `your-super-secret-jwt-key` |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `development` | Application environment |
| `LOG_LEVEL` | `info` | Logging level |
| `NEMLIG_RATE_LIMIT_REQUESTS` | `60` | API rate limit |

## Backend Configuration (`backend/.env`)

### Database Configuration

```env
# PostgreSQL with pgvector
DATABASE_URL=postgresql://cartchef:cartchef_dev@localhost:5432/cartchef
DATABASE_ECHO=false
DATABASE_POOL_SIZE=10

# Redis for caching
REDIS_URL=redis://localhost:6379/0
```

### Authentication & Security

```env
# JWT Configuration
SECRET_KEY=your-super-secret-key-change-this-in-production-minimum-32-chars
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS settings
CORS_ORIGINS=["http://localhost:3000", "http://localhost:3001"]
```

### Firebase Integration

```env
FIREBASE_PROJECT_ID=cartchef-dev
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-@cartchef-dev.iam.gserviceaccount.com
```

### AI/ML Configuration

```env
# OpenAI API
OPENAI_API_KEY=sk-your-openai-api-key
OPENAI_MODEL=gpt-4
OPENAI_MAX_TOKENS=4000

# Embeddings for pgvector
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSIONS=1536
```

## MCP Server Configuration (`mcp-server/.env`)

### Nemlig.com API Integration

```env
# Required
NEMLIG_USERNAME=your-nemlig-email@example.com
NEMLIG_PASSWORD=your-nemlig-password
NEMLIG_API_BASE_URL=https://api.nemlig.com

# Rate Limiting
RATE_LIMIT_REQUESTS=60
RATE_LIMIT_WINDOW=60000
```

### Session Management

```env
SESSION_TIMEOUT=3600000
SESSION_REFRESH_THRESHOLD=600000
JWT_SECRET=your-internal-jwt-secret-32-characters-minimum
```

### Caching Configuration

```env
REDIS_URL=redis://localhost:6379/3
PRODUCT_CACHE_TTL=3600
SEARCH_CACHE_TTL=300
```

## Frontend Configuration (`frontend/.env.local`)

### API Endpoints

```env
# Required
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_FIREBASE_PROJECT_ID=cartchef-dev

# Firebase Web Config
NEXT_PUBLIC_FIREBASE_API_KEY=your-firebase-api-key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=cartchef-dev.firebaseapp.com
```

### Feature Flags

```env
# Core Features
NEXT_PUBLIC_ENABLE_RECIPE_URL_PARSING=true
NEXT_PUBLIC_ENABLE_PANTRY_MANAGEMENT=true
NEXT_PUBLIC_ENABLE_NEMLIG_INTEGRATION=true

# Beta Features
NEXT_PUBLIC_ENABLE_AI_SUGGESTIONS=true
NEXT_PUBLIC_ENABLE_SMART_SUBSTITUTIONS=false
```

## Agno Agent Configuration (`agno-agent/.env`)

### AI Model Configuration

```env
# Primary Provider
OPENAI_API_KEY=sk-your-openai-api-key
OPENAI_MODEL=gpt-4

# Alternative Providers
ANTHROPIC_API_KEY=your-anthropic-api-key
GOOGLE_AI_API_KEY=your-google-ai-api-key

# Fallback Configuration
ENABLE_MODEL_FALLBACK=true
FALLBACK_ORDER=["openai", "anthropic", "google"]
```

### Memory System

```env
# Short-term (Redis)
REDIS_URL=redis://localhost:6379/4
MEMORY_TTL=3600

# Long-term (Firestore)
FIREBASE_PROJECT_ID=cartchef-dev

# Vector Database (pgvector)
VECTOR_DATABASE_URL=postgresql://cartchef:cartchef_dev@localhost:5432/cartchef
VECTOR_SIMILARITY_THRESHOLD=0.8
```

## Environment-Specific Configurations

### Development Environment

```env
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
ENABLE_HOT_RELOAD=true
USE_FIREBASE_EMULATORS=true
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
FIRESTORE_EMULATOR_HOST=localhost:8080
```

### Production Environment

```env
NODE_ENV=production
DEBUG=false
LOG_LEVEL=info
SSL_ENABLED=true
CORS_ORIGINS=["https://cartchef.app"]
COOKIE_SECURE=true
VALIDATE_REQUESTS=true
```

### Testing Environment

```env
NODE_ENV=test
TEST_DATABASE_URL=postgresql://cartchef:cartchef_test@localhost:5432/cartchef_test
TEST_REDIS_URL=redis://localhost:6379/15
MOCK_EXTERNAL_SERVICES=true
DISABLE_EXTERNAL_APIS=false
```

## Security Best Practices

### Secret Management

1. **Never commit `.env` files** to version control
2. **Use strong, unique secrets** for JWT keys and API keys
3. **Rotate secrets regularly** in production
4. **Use environment-specific secrets** (dev/staging/prod)

### Production Considerations

```env
# Use strong JWT secrets (minimum 32 characters)
JWT_SECRET=your-super-secret-key-minimum-32-characters-long

# Enable HTTPS in production
SSL_ENABLED=true
COOKIE_SECURE=true

# Restrict CORS origins
CORS_ORIGINS=["https://cartchef.app"]

# Enable request validation
VALIDATE_REQUESTS=true
ENABLE_CSRF_PROTECTION=true
```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check `DATABASE_URL` format
   - Ensure PostgreSQL is running
   - Verify pgvector extension is installed

2. **Firebase Authentication Issues**
   - Verify Firebase project configuration
   - Check service account key format
   - Ensure proper JSON escaping for private key

3. **Redis Connection Problems**
   - Verify Redis is running on correct port
   - Check Redis password if set
   - Ensure different databases for different services

4. **API Rate Limiting**
   - Adjust `NEMLIG_RATE_LIMIT_REQUESTS`
   - Check Nemlig.com API status
   - Verify credentials are correct

### Debug Mode

Enable debug logging for troubleshooting:

```env
DEBUG=true
LOG_LEVEL=debug
LOG_API_REQUESTS=true
LOG_PERFORMANCE=true
```

### Health Checks

Test service connectivity:

```bash
# Check database connection
psql $DATABASE_URL -c "SELECT version();"

# Check Redis connection
redis-cli -u $REDIS_URL ping

# Check API endpoints
curl http://localhost:8000/health
curl http://localhost:3001/health
```

## Environment Validation

Each service includes environment validation on startup:

- **Required variables** are checked for presence
- **Format validation** for URLs, numbers, and structured data
- **Connection testing** for external services
- **Warning messages** for insecure configurations

## Docker Configuration

When using Docker Compose, environment variables can be:

1. **Defined in docker-compose.yml**
2. **Loaded from .env files** using `env_file`
3. **Passed from host environment** using `${VARIABLE}`

Example docker-compose.yml service:
```yaml
services:
  backend:
    build: ./backend
    env_file:
      - ./backend/.env
    environment:
      - DATABASE_URL=${DATABASE_URL}
```

## Monitoring and Observability

### Logging Configuration

```env
# Structured logging
LOG_FORMAT=json
LOG_LEVEL=info

# File logging
LOG_FILE=logs/app.log
LOG_MAX_BYTES=10485760
LOG_BACKUP_COUNT=5
```

### Metrics and Monitoring

```env
# Enable metrics collection
ENABLE_METRICS=true
METRICS_PORT=9090

# External monitoring
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
DATADOG_API_KEY=your-datadog-api-key
```

## Migration and Updates

When updating environment configurations:

1. **Review changelog** for new variables
2. **Update all .env.example files**
3. **Test in development** before production
4. **Document breaking changes**
5. **Provide migration scripts** if needed

## Support

For environment configuration issues:

1. Check this documentation first
2. Review service-specific logs
3. Validate configuration with health checks
4. Contact the development team with specific error messages

---

**Note**: This configuration guide is versioned with the application. Always refer to the version that matches your CartChef deployment.