"""
Environment configuration settings for CartChef Backend API.

This module uses Pydantic settings for environment variable validation
and type conversion with comprehensive error handling.
"""

import os
from typing import List, Optional
from pydantic import BaseSettings, Field, validator, AnyHttpUrl
from pydantic.env_settings import SettingsSourceCallable


class DatabaseSettings(BaseSettings):
    """Database configuration settings."""
    
    url: str = Field(..., env="DATABASE_URL", description="PostgreSQL connection URL")
    echo: bool = Field(False, env="DATABASE_ECHO")
    pool_size: int = Field(10, env="DATABASE_POOL_SIZE")
    max_overflow: int = Field(20, env="DATABASE_MAX_OVERFLOW")
    
    @validator("url")
    def validate_database_url(cls, v):
        if not v.startswith("postgresql://"):
            raise ValueError("DATABASE_URL must be a PostgreSQL connection string")
        return v


class RedisSettings(BaseSettings):
    """Redis configuration settings."""
    
    url: str = Field(..., env="REDIS_URL", description="Redis connection URL")
    password: Optional[str] = Field(None, env="REDIS_PASSWORD")
    db: int = Field(0, env="REDIS_DB")
    
    @validator("url")
    def validate_redis_url(cls, v):
        if not v.startswith("redis://"):
            raise ValueError("REDIS_URL must be a Redis connection string")
        return v


class SecuritySettings(BaseSettings):
    """Security and authentication settings."""
    
    secret_key: str = Field(..., env="SECRET_KEY", min_length=32)
    algorithm: str = Field("HS256", env="ALGORITHM")
    access_token_expire_minutes: int = Field(30, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    refresh_token_expire_days: int = Field(7, env="REFRESH_TOKEN_EXPIRE_DAYS")
    
    # CORS settings
    cors_origins: List[str] = Field(["http://localhost:3000"], env="CORS_ORIGINS")
    cors_credentials: bool = Field(True, env="CORS_CREDENTIALS")
    
    @validator("secret_key")
    def validate_secret_key(cls, v):
        if len(v) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters long")
        return v


class FirebaseSettings(BaseSettings):
    """Firebase configuration settings."""
    
    project_id: str = Field(..., env="FIREBASE_PROJECT_ID")
    private_key_id: Optional[str] = Field(None, env="FIREBASE_PRIVATE_KEY_ID")
    private_key: str = Field(..., env="FIREBASE_PRIVATE_KEY")
    client_email: str = Field(..., env="FIREBASE_CLIENT_EMAIL")
    client_id: Optional[str] = Field(None, env="FIREBASE_CLIENT_ID")
    
    # Emulator settings for development
    firestore_emulator_host: Optional[str] = Field(None, env="FIRESTORE_EMULATOR_HOST")
    
    @validator("client_email")
    def validate_client_email(cls, v):
        if "@" not in v or ".iam.gserviceaccount.com" not in v:
            raise ValueError("FIREBASE_CLIENT_EMAIL must be a valid service account email")
        return v


class ExternalAPISettings(BaseSettings):
    """External API configuration settings."""
    
    # MCP Server
    mcp_server_url: AnyHttpUrl = Field(..., env="MCP_SERVER_URL")
    mcp_server_timeout: int = Field(30, env="MCP_SERVER_TIMEOUT")
    mcp_server_retries: int = Field(3, env="MCP_SERVER_RETRIES")
    
    # Agno Agent
    agno_agent_url: Optional[AnyHttpUrl] = Field(None, env="AGNO_AGENT_URL")
    agno_agent_timeout: int = Field(60, env="AGNO_AGENT_TIMEOUT")


class AISettings(BaseSettings):
    """AI/ML model configuration settings."""
    
    # OpenAI
    openai_api_key: str = Field(..., env="OPENAI_API_KEY")
    openai_model: str = Field("gpt-4", env="OPENAI_MODEL")
    openai_max_tokens: int = Field(4000, env="OPENAI_MAX_TOKENS")
    openai_temperature: float = Field(0.1, env="OPENAI_TEMPERATURE")
    
    # Embeddings
    embedding_model: str = Field("text-embedding-3-small", env="EMBEDDING_MODEL")
    embedding_dimensions: int = Field(1536, env="EMBEDDING_DIMENSIONS")
    embedding_batch_size: int = Field(100, env="EMBEDDING_BATCH_SIZE")
    
    @validator("openai_api_key")
    def validate_openai_api_key(cls, v):
        if not v.startswith("sk-"):
            raise ValueError("OPENAI_API_KEY must start with 'sk-'")
        return v


class LoggingSettings(BaseSettings):
    """Logging configuration settings."""
    
    level: str = Field("INFO", env="LOG_LEVEL")
    format_str: str = Field(
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        env="LOG_FORMAT"
    )
    file: Optional[str] = Field(None, env="LOG_FILE")
    max_bytes: int = Field(10485760, env="LOG_MAX_BYTES")  # 10MB
    backup_count: int = Field(5, env="LOG_BACKUP_COUNT")
    use_json_logging: bool = Field(False, env="USE_JSON_LOGGING")
    
    @validator("level")
    def validate_log_level(cls, v):
        valid_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if v.upper() not in valid_levels:
            raise ValueError(f"LOG_LEVEL must be one of: {valid_levels}")
        return v.upper()


class MonitoringSettings(BaseSettings):
    """Monitoring and observability settings."""
    
    enable_metrics: bool = Field(True, env="ENABLE_METRICS")
    metrics_port: int = Field(9090, env="METRICS_PORT")
    
    # External monitoring
    sentry_dsn: Optional[str] = Field(None, env="SENTRY_DSN")
    sentry_environment: str = Field("development", env="SENTRY_ENVIRONMENT")
    sentry_traces_sample_rate: float = Field(0.1, env="SENTRY_TRACES_SAMPLE_RATE")


class TestingSettings(BaseSettings):
    """Testing configuration settings."""
    
    test_database_url: Optional[str] = Field(None, env="TEST_DATABASE_URL")
    test_redis_url: Optional[str] = Field(None, env="TEST_REDIS_URL")
    disable_external_apis: bool = Field(False, env="DISABLE_EXTERNAL_APIS")
    mock_external_services: bool = Field(True, env="MOCK_EXTERNAL_SERVICES")


class Settings(BaseSettings):
    """Main application settings combining all configuration sections."""
    
    # Application info
    app_name: str = Field("CartChef Backend API", env="APP_NAME")
    app_version: str = Field("0.1.0", env="APP_VERSION")
    debug: bool = Field(False, env="DEBUG")
    environment: str = Field("development", env="ENVIRONMENT")
    
    # Server settings
    host: str = Field("0.0.0.0", env="HOST")
    port: int = Field(8000, env="PORT")
    reload: bool = Field(True, env="RELOAD")
    
    # Configuration sections
    database: DatabaseSettings = DatabaseSettings()
    redis: RedisSettings = RedisSettings()
    security: SecuritySettings = SecuritySettings()
    firebase: FirebaseSettings = FirebaseSettings()
    external_apis: ExternalAPISettings = ExternalAPISettings()
    ai: AISettings = AISettings()
    logging: LoggingSettings = LoggingSettings()
    monitoring: MonitoringSettings = MonitoringSettings()
    testing: TestingSettings = TestingSettings()
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        
    @validator("environment")
    def validate_environment(cls, v):
        valid_envs = ["development", "staging", "production", "test"]
        if v.lower() not in valid_envs:
            raise ValueError(f"ENVIRONMENT must be one of: {valid_envs}")
        return v.lower()
    
    def is_development(self) -> bool:
        """Check if running in development environment."""
        return self.environment == "development"
    
    def is_production(self) -> bool:
        """Check if running in production environment."""
        return self.environment == "production"
    
    def is_testing(self) -> bool:
        """Check if running in testing environment."""
        return self.environment == "test"


def get_settings() -> Settings:
    """
    Get application settings with caching.
    
    This function creates and caches the settings instance to avoid
    re-parsing environment variables on every call.
    """
    return Settings()


def validate_environment() -> None:
    """
    Validate all environment variables and raise descriptive errors.
    
    This function should be called at application startup to ensure
    all required configuration is present and valid.
    """
    try:
        settings = get_settings()
        
        # Additional validation checks
        if settings.is_production():
            # Production-specific validations
            if settings.debug:
                raise ValueError("DEBUG must be False in production")
            
            if "localhost" in str(settings.external_apis.mcp_server_url):
                raise ValueError("MCP_SERVER_URL cannot use localhost in production")
        
        # Test database connectivity if not in test mode
        if not settings.is_testing():
            test_database_connection(settings.database.url)
            test_redis_connection(settings.redis.url)
        
        print(f"✅ Environment validation successful for {settings.environment} environment")
        
    except Exception as e:
        print(f"❌ Environment validation failed: {e}")
        raise


def test_database_connection(database_url: str) -> None:
    """Test PostgreSQL database connectivity."""
    try:
        import psycopg2
        conn = psycopg2.connect(database_url)
        conn.close()
        print("✅ Database connection successful")
    except ImportError:
        print("⚠️  psycopg2 not installed, skipping database connection test")
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        raise


def test_redis_connection(redis_url: str) -> None:
    """Test Redis connectivity."""
    try:
        import redis
        r = redis.from_url(redis_url)
        r.ping()
        print("✅ Redis connection successful")
    except ImportError:
        print("⚠️  redis package not installed, skipping Redis connection test")
    except Exception as e:
        print(f"❌ Redis connection failed: {e}")
        raise


if __name__ == "__main__":
    """Standalone validation script."""
    validate_environment()