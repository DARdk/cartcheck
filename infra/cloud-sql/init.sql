-- Initialize CartChef database with pgvector extension

-- Create the vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS products;
CREATE SCHEMA IF NOT EXISTS memory;

-- Create basic tables for vector storage
CREATE TABLE IF NOT EXISTS memory.embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding vector(1536), -- OpenAI embedding dimension
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS embeddings_embedding_idx ON memory.embeddings 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Create products table for Nemlig product cache
CREATE TABLE IF NOT EXISTS products.nemlig_products (
    id SERIAL PRIMARY KEY,
    nemlig_id VARCHAR(255) UNIQUE NOT NULL,
    name TEXT NOT NULL,
    brand VARCHAR(255),
    price DECIMAL(10,2),
    unit VARCHAR(50),
    category VARCHAR(255),
    availability BOOLEAN DEFAULT true,
    embedding vector(1536),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for product search
CREATE INDEX IF NOT EXISTS nemlig_products_embedding_idx ON products.nemlig_products 
USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

CREATE INDEX IF NOT EXISTS nemlig_products_name_idx ON products.nemlig_products (name);
CREATE INDEX IF NOT EXISTS nemlig_products_category_idx ON products.nemlig_products (category);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA auth TO cartchef;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA products TO cartchef;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA memory TO cartchef;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA auth TO cartchef;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA products TO cartchef;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA memory TO cartchef;
