/**
 * Environment configuration validation for CartChef MCP Server
 * 
 * This module validates all environment variables using Zod schemas
 * and provides type-safe configuration objects.
 */

import { z } from 'zod';
import dotenv from 'dotenv';
import { URL } from 'url';
import Redis from 'ioredis';

// Load environment variables
dotenv.config();

/**
 * Application settings schema
 */
const AppConfigSchema = z.object({
  nodeEnv: z.enum(['development', 'staging', 'production', 'test']).default('development'),
  appName: z.string().default('CartChef MCP Server'),
  appVersion: z.string().default('0.1.0'),
  port: z.coerce.number().int().min(1).max(65535).default(3001),
  host: z.string().default('0.0.0.0'),
});

/**
 * MCP Protocol configuration schema
 */
const MCPConfigSchema = z.object({
  serverName: z.string().default('cartchef-nemlig'),
  serverVersion: z.string().default('0.1.0'),
  protocolVersion: z.string().default('2024-11-05'),
  supportsResources: z.boolean().default(true),
  supportsTools: z.boolean().default(true),
  supportsPrompts: z.boolean().default(false),
});

/**
 * Nemlig API configuration schema
 */
const NemligConfigSchema = z.object({
  apiBaseUrl: z.string().url().default('https://api.nemlig.com'),
  webBaseUrl: z.string().url().default('https://www.nemlig.com'),
  username: z.string().email('NEMLIG_USERNAME must be a valid email'),
  password: z.string().min(1, 'NEMLIG_PASSWORD is required'),
  loginEndpoint: z.string().default('/auth/login'),
  searchEndpoint: z.string().default('/api/search'),
  cartEndpoint: z.string().default('/api/cart'),
  productsEndpoint: z.string().default('/api/products'),
  categoriesEndpoint: z.string().default('/api/categories'),
});

/**
 * Authentication configuration schema
 */
const AuthConfigSchema = z.object({
  sessionTimeout: z.coerce.number().int().min(60000).default(3600000), // 1 hour
  sessionRefreshThreshold: z.coerce.number().int().min(60000).default(600000), // 10 minutes
  maxConcurrentSessions: z.coerce.number().int().min(1).max(20).default(5),
  cookieDomain: z.string().default('.nemlig.com'),
  cookieSecure: z.boolean().default(true),
  cookieSameSite: z.enum(['strict', 'lax', 'none']).default('strict'),
  jwtSecret: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  jwtExpiration: z.string().default('1h'),
});

/**
 * Rate limiting configuration schema
 */
const RateLimitConfigSchema = z.object({
  requests: z.coerce.number().int().min(1).max(1000).default(60),
  window: z.coerce.number().int().min(1000).default(60000), // 1 minute
  skipSuccessful: z.boolean().default(false),
  requestTimeout: z.coerce.number().int().min(1000).max(60000).default(10000), // 10 seconds
  requestRetries: z.coerce.number().int().min(0).max(10).default(3),
  requestRetryDelay: z.coerce.number().int().min(100).default(1000), // 1 second
  concurrentRequests: z.coerce.number().int().min(1).max(50).default(10),
  userAgent: z.string().default('CartChef/1.0 (+https://cartchef.app)'),
});

/**
 * Caching configuration schema
 */
const CacheConfigSchema = z.object({
  redisUrl: z.string().regex(/^redis:\/\//, 'REDIS_URL must start with redis://'),
  redisPassword: z.string().optional(),
  redisKeyPrefix: z.string().default('cartchef:mcp:'),
  productCacheTtl: z.coerce.number().int().min(60).default(3600), // 1 hour
  searchCacheTtl: z.coerce.number().int().min(60).default(300), // 5 minutes
  cartCacheTtl: z.coerce.number().int().min(30).default(60), // 1 minute
  sessionCacheTtl: z.coerce.number().int().min(300).default(3600), // 1 hour
});

/**
 * Logging configuration schema
 */
const LoggingConfigSchema = z.object({
  level: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
  format: z.enum(['combined', 'common', 'dev', 'short', 'tiny']).default('combined'),
  timestamp: z.boolean().default(true),
  logDir: z.string().default('./logs'),
  logFileMaxSize: z.string().regex(/^\d+[kmg]$/i).default('10m'),
  logFileMaxFiles: z.coerce.number().int().min(1).max(20).default(5),
  useJsonLogging: z.boolean().default(false),
  logRequests: z.boolean().default(true),
  logResponses: z.boolean().default(false),
});

/**
 * Security configuration schema
 */
const SecurityConfigSchema = z.object({
  corsOrigin: z.array(z.string().url()).default(['http://localhost:3000', 'http://localhost:8000']),
  corsMethods: z.array(z.string()).default(['GET', 'POST', 'PUT', 'DELETE']),
  corsCredentials: z.boolean().default(true),
  validateRequests: z.boolean().default(true),
  maxRequestSize: z.string().regex(/^\d+[kmg]?b$/i).default('1mb'),
  enableCsrfProtection: z.boolean().default(false),
  apiKey: z.string().min(16, 'API_KEY must be at least 16 characters'),
});

/**
 * Monitoring configuration schema
 */
const MonitoringConfigSchema = z.object({
  enableMetrics: z.boolean().default(true),
  metricsPort: z.coerce.number().int().min(1).max(65535).default(9091),
  metricsPath: z.string().default('/metrics'),
  sentryDsn: z.string().url().optional(),
  sentryEnvironment: z.string().default('development'),
});

/**
 * Main configuration schema combining all sections
 */
const ConfigSchema = z.object({
  app: AppConfigSchema,
  mcp: MCPConfigSchema,
  nemlig: NemligConfigSchema,
  auth: AuthConfigSchema,
  rateLimit: RateLimitConfigSchema,
  cache: CacheConfigSchema,
  logging: LoggingConfigSchema,
  security: SecurityConfigSchema,
  monitoring: MonitoringConfigSchema,
});

/**
 * Configuration type inferred from schema
 */
export type Config = z.infer<typeof ConfigSchema>;

/**
 * Parse and validate environment variables
 */
function parseEnvironment(): Config {
  const env = process.env;
  
  const config = {
    app: {
      nodeEnv: env.NODE_ENV,
      appName: env.APP_NAME,
      appVersion: env.APP_VERSION,
      port: env.PORT,
      host: env.HOST,
    },
    mcp: {
      serverName: env.MCP_SERVER_NAME,
      serverVersion: env.MCP_SERVER_VERSION,
      protocolVersion: env.MCP_PROTOCOL_VERSION,
      supportsResources: env.MCP_SUPPORTS_RESOURCES === 'true',
      supportsTools: env.MCP_SUPPORTS_TOOLS === 'true',
      supportsPrompts: env.MCP_SUPPORTS_PROMPTS === 'true',
    },
    nemlig: {
      apiBaseUrl: env.NEMLIG_API_BASE_URL,
      webBaseUrl: env.NEMLIG_WEB_BASE_URL,
      username: env.NEMLIG_USERNAME,
      password: env.NEMLIG_PASSWORD,
      loginEndpoint: env.NEMLIG_LOGIN_ENDPOINT,
      searchEndpoint: env.NEMLIG_SEARCH_ENDPOINT,
      cartEndpoint: env.NEMLIG_CART_ENDPOINT,
      productsEndpoint: env.NEMLIG_PRODUCTS_ENDPOINT,
      categoriesEndpoint: env.NEMLIG_CATEGORIES_ENDPOINT,
    },
    auth: {
      sessionTimeout: env.SESSION_TIMEOUT,
      sessionRefreshThreshold: env.SESSION_REFRESH_THRESHOLD,
      maxConcurrentSessions: env.MAX_CONCURRENT_SESSIONS,
      cookieDomain: env.COOKIE_DOMAIN,
      cookieSecure: env.COOKIE_SECURE === 'true',
      cookieSameSite: env.COOKIE_SAME_SITE as any,
      jwtSecret: env.JWT_SECRET,
      jwtExpiration: env.JWT_EXPIRATION,
    },
    rateLimit: {
      requests: env.RATE_LIMIT_REQUESTS,
      window: env.RATE_LIMIT_WINDOW,
      skipSuccessful: env.RATE_LIMIT_SKIP_SUCCESSFUL === 'true',
      requestTimeout: env.REQUEST_TIMEOUT,
      requestRetries: env.REQUEST_RETRIES,
      requestRetryDelay: env.REQUEST_RETRY_DELAY,
      concurrentRequests: env.CONCURRENT_REQUESTS,
      userAgent: env.USER_AGENT,
    },
    cache: {
      redisUrl: env.REDIS_URL,
      redisPassword: env.REDIS_PASSWORD,
      redisKeyPrefix: env.REDIS_KEY_PREFIX,
      productCacheTtl: env.PRODUCT_CACHE_TTL,
      searchCacheTtl: env.SEARCH_CACHE_TTL,
      cartCacheTtl: env.CART_CACHE_TTL,
      sessionCacheTtl: env.SESSION_CACHE_TTL,
    },
    logging: {
      level: env.LOG_LEVEL as any,
      format: env.LOG_FORMAT as any,
      timestamp: env.LOG_TIMESTAMP !== 'false',
      logDir: env.LOG_DIR,
      logFileMaxSize: env.LOG_FILE_MAX_SIZE,
      logFileMaxFiles: env.LOG_FILE_MAX_FILES,
      useJsonLogging: env.USE_JSON_LOGGING === 'true',
      logRequests: env.LOG_REQUESTS !== 'false',
      logResponses: env.LOG_RESPONSES === 'true',
    },
    security: {
      corsOrigin: env.CORS_ORIGIN ? JSON.parse(env.CORS_ORIGIN) : undefined,
      corsMethods: env.CORS_METHODS ? JSON.parse(env.CORS_METHODS) : undefined,
      corsCredentials: env.CORS_CREDENTIALS !== 'false',
      validateRequests: env.VALIDATE_REQUESTS !== 'false',
      maxRequestSize: env.MAX_REQUEST_SIZE,
      enableCsrfProtection: env.ENABLE_CSRF_PROTECTION === 'true',
      apiKey: env.API_KEY,
    },
    monitoring: {
      enableMetrics: env.ENABLE_METRICS !== 'false',
      metricsPort: env.METRICS_PORT,
      metricsPath: env.METRICS_PATH,
      sentryDsn: env.SENTRY_DSN,
      sentryEnvironment: env.SENTRY_ENVIRONMENT,
    },
  };
  
  return ConfigSchema.parse(config);
}

/**
 * Test external service connectivity
 */
async function testConnections(config: Config): Promise<void> {
  const errors: string[] = [];
  
  // Test Redis connection
  try {
    const redis = new Redis(config.cache.redisUrl, {
      password: config.cache.redisPassword,
      retryDelayOnFailover: 100,
      maxRetriesPerRequest: 3,
    });
    
    await redis.ping();
    console.log('✅ Redis connection successful');
    redis.disconnect();
  } catch (error) {
    errors.push(`Redis connection failed: ${error}`);
  }
  
  // Test Nemlig API accessibility (without authentication)
  try {
    const response = await fetch(config.nemlig.apiBaseUrl, { 
      method: 'HEAD',
      signal: AbortSignal.timeout(5000)
    });
    if (response.ok || response.status === 404) {
      console.log('✅ Nemlig API base URL accessible');
    } else {
      errors.push(`Nemlig API returned status: ${response.status}`);
    }
  } catch (error) {
    errors.push(`Nemlig API accessibility test failed: ${error}`);
  }
  
  if (errors.length > 0) {
    console.error('❌ Connection tests failed:');
    errors.forEach(error => console.error(`  - ${error}`));
    throw new Error('Connection tests failed');
  }
}

/**
 * Validate production-specific requirements
 */
function validateProductionConfig(config: Config): void {
  if (config.app.nodeEnv !== 'production') {
    return;
  }
  
  const errors: string[] = [];
  
  // Production security checks
  if (!config.auth.cookieSecure) {
    errors.push('COOKIE_SECURE must be true in production');
  }
  
  if (!config.security.enableCsrfProtection) {
    console.warn('⚠️  CSRF protection is disabled in production');
  }
  
  if (config.logging.logResponses) {
    console.warn('⚠️  Response logging is enabled in production (may expose sensitive data)');
  }
  
  // Check for localhost URLs
  if (config.nemlig.apiBaseUrl.includes('localhost')) {
    errors.push('NEMLIG_API_BASE_URL cannot use localhost in production');
  }
  
  if (config.cache.redisUrl.includes('localhost')) {
    errors.push('REDIS_URL cannot use localhost in production');
  }
  
  if (errors.length > 0) {
    throw new Error(`Production validation failed: ${errors.join(', ')}`);
  }
}

/**
 * Main validation function
 */
export async function validateEnvironment(): Promise<Config> {
  try {
    console.log('🔍 Validating MCP Server environment configuration...');
    
    // Parse and validate configuration
    const config = parseEnvironment();
    
    // Validate production-specific requirements
    validateProductionConfig(config);
    
    // Test external connections (skip in test environment)
    if (config.app.nodeEnv !== 'test') {
      await testConnections(config);
    }
    
    console.log(`✅ Environment validation successful for ${config.app.nodeEnv} environment`);
    
    return config;
    
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('❌ Environment validation failed:');
      error.errors.forEach(err => {
        const path = err.path.join('.');
        console.error(`  - ${path}: ${err.message}`);
      });
    } else {
      console.error(`❌ Environment validation failed: ${error}`);
    }
    
    process.exit(1);
  }
}

/**
 * Get validated configuration instance
 */
let configInstance: Config | null = null;

export async function getConfig(): Promise<Config> {
  if (!configInstance) {
    configInstance = await validateEnvironment();
  }
  return configInstance;
}

/**
 * Standalone validation script
 */
if (require.main === module) {
  validateEnvironment()
    .then(() => {
      console.log('Environment validation completed successfully');
      process.exit(0);
    })
    .catch(() => {
      process.exit(1);
    });
}