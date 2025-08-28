# CartChef - Meal Planning & Grocery Automation

CartChef is a user-friendly meal-planning and grocery automation system that integrates with Nemlig.com. Users can plan weekly meals, generate ingredient lists, and automatically fill their Nemlig.com shopping cart using an intelligent agent framework.

## Key Features

- **Recipe Management**: Add recipes via URL parsing or manual entry
- **Meal Planning**: Weekly meal planning with drag-and-drop interface  
- **Smart Shopping Lists**: Automatic ingredient aggregation and normalization
- **Nemlig.com Integration**: Seamless cart management via MCP server
- **AI-Powered Preferences**: Learning system for personalized shopping
- **Pantry Tracking**: Track what's at home to optimize shopping lists

## Architecture

- **Frontend**: Next.js web application
- **Backend**: FastAPI microservices with MCP server
- **AI Orchestration**: Agno agent framework  
- **Storage**: Firebase Firestore + Cloud SQL with pgvector
- **Integration**: Unofficial Nemlig API via custom MCP server

## Development Setup

### Prerequisites
- Node.js 18+
- Python 3.9+
- Docker & Docker Compose
- Firebase CLI
- Git

### Getting Started

1. Clone the repository:
```bash
git clone https://github.com/DARdk/cartcheck.git
cd cartcheck
```

2. Install dependencies:
```bash
# Frontend
cd frontend && npm install

# Backend  
cd ../backend && pip install -r requirements.txt

# MCP Server
cd ../mcp-server && npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Start development services:
```bash
docker-compose up -d
```

## Branching Strategy

We use **Git Flow** branching strategy:

### Main Branches
- **`main`**: Production-ready code. Protected branch with required PR reviews.
- **`develop`**: Integration branch for features. All feature branches merge here first.

### Supporting Branches
- **`feature/*`**: New features (e.g., `feature/recipe-parser`)
- **`bugfix/*`**: Bug fixes (e.g., `bugfix/cart-sync-issue`) 
- **`hotfix/*`**: Critical production fixes (e.g., `hotfix/auth-security`)
- **`release/*`**: Prepare releases (e.g., `release/v1.2.0`)

### Workflow
1. Create feature branch from `develop`: `git checkout -b feature/my-feature develop`
2. Work on feature and commit changes
3. Push branch and create PR to `develop`
4. After review and merge, delete feature branch
5. For releases: create `release/*` branch from `develop`, then merge to both `main` and `develop`

### Branch Protection Rules
- **`main`**: Requires PR review, up-to-date branches, status checks
- **`develop`**: Requires PR review for external contributors

## Commit Message Conventions

We follow **Conventional Commits** specification:

### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **feat**: New feature for users
- **fix**: Bug fix for users  
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependency updates
- **ci**: CI/CD pipeline changes

### Examples
```bash
feat(auth): add Firebase authentication integration
fix(cart): resolve item duplication in shopping list  
docs(readme): update installation instructions
chore(deps): bump next.js to v14.0.0
```

### Scope Guidelines
- **auth**: Authentication & authorization
- **cart**: Shopping cart functionality
- **recipe**: Recipe management
- **ui**: User interface components  
- **api**: Backend API changes
- **db**: Database schema or queries
- **mcp**: MCP server functionality

## Project Management

Tasks are managed using [Backlog.md](https://github.com/MrLesk/Backlog.md) in the `backlog/` directory:

- View tasks: Open backlog browser in VS Code
- Task files: `backlog/tasks/task-*.md`
- Configuration: `backlog/config.yml`

## Contributing

1. Fork the repository
2. Create feature branch from `develop`
3. Follow commit message conventions
4. Ensure all tests pass
5. Submit PR with clear description

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.