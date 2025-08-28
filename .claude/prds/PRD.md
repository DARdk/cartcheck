# Product Requirements Document (PRD)

## Project Overview
This project builds a user-friendly **meal-planning and grocery automation system** that integrates with **Nemlig.com**.  
Users can plan weekly meals, generate ingredient lists, and automatically fill their Nemlig.com shopping cart.  
The system uses an **MCP server** on top of the **unofficial Nemlig API** for reliability,  
**Agno** for intelligent orchestration, **Firebase Firestore** for structured storage,  
and **Cloud SQL (Postgres + pgvector)** for semantic memory.

All project tasks and planning are tracked using **Backlog.md** for lightweight task management.

---

## Key Features

### 1. Frontend (Next.js Web App)
- **Responsive UI** for recipe selection, weekly meal planning, and ingredient review.  
- **Recipe input options:**  
  - Paste a **URL link** to an online recipe → system parses and extracts ingredients.  
  - Add a **recipe manually** (enter ingredients + steps directly).  
- Recipe history & favorites for quick reuse.  
- Pantry tracker: users mark what’s already at home → deducted from shopping list.  

### 2. Shopping List Generation
- Aggregates ingredients across multiple recipes.  
- Normalizes units (e.g., grams vs. kg).  
- Deduplicates overlapping ingredients into a single line item.  

### 3. Nemlig.com Integration (via API + MCP server)
- Wrap the [unofficial Nemlig API](https://github.com/schourode/nemlig/tree/master/api) in a **custom MCP server**.  
- MCP server responsibilities:  
  - Normalize API calls for cart management, search, and authentication.  
  - Abstract quirks of the unofficial client.  
  - Provide a stable interface for the backend/agent.  
- Secure login/session handling with tokens.  
- Structured feedback:  
  - ✅ Items successfully added  
  - ❌ Items missing/not found  

### 4. Preference Handling & Memory (Agno Agent Framework)
- **Agno orchestrates:** recipe → shopping list → Nemlig cart.  
- **Short-term memory:** session context (current run).  
- **Long-term memory:**  
  - **Firestore (NoSQL):** structured preferences (e.g., “always organic eggs”), recipes, user accounts.  
  - **Cloud SQL (Postgres + pgvector):** semantic embeddings for fuzzy recall (e.g., “similar to oat milk” or “brands like X”).  
- Learns structured and semantic preferences over time.  
- Suggests substitutions for unavailable items.  

### 5. Optional Chrome Extension
- Monitors manual cart changes on Nemlig.com.  
- Reports corrections back to Agno.  
- Updates **Firestore** (structured memory) and **pgvector** (semantic memory).  

---

## Technical Architecture

- **Frontend:** Next.js (React-based web app).  
- **Backend Services:**  
  - FastAPI or Flask microservice for orchestrating API calls.  
  - **MCP server** wrapping the unofficial Nemlig API.  
  - Agno agent framework for reasoning, substitutions, orchestration.  
- **Database & Storage:**  
  - **Firebase Firestore (NoSQL):** recipes, structured preferences, user accounts.  
  - **Cloud SQL (Postgres + pgvector):** semantic memory for embeddings and similarity search.  
  - **Firebase Auth:** secure user authentication.  
  - **Firebase Hosting (optional):** for frontend deployment.  
- **Nemlig API:** Accessed only via MCP server.  
- **Chrome Extension (optional):** Tracks manual edits for preference learning.  

---

## Planning & Workflow

- **Backlog Management:** Use [Backlog.md](https://github.com/MrLesk/Backlog.md) in the repo root for task planning.  
  - Each feature or fix represented as a Markdown task.  
  - Developers and contributors update directly in Backlog.md.  
  - Keeps planning lightweight and transparent.  

---

## User Flow

1. User selects or creates recipes in the Next.js app:  
   - Adds recipe by **URL link** (parsed automatically), or  
   - Adds recipe **manually** (ingredients + steps entered).  
2. Ingredients aggregated → normalized shopping list.  
3. User clicks **“Add to Nemlig Cart.”**  
4. Backend calls MCP server → Nemlig API.  
5. Agno applies preferences:  
   - Structured rules (from Firestore).  
   - Semantic preferences (from pgvector).  
6. User reviews cart on Nemlig.com.  
7. Manual changes (via extension) → synced to Firestore + pgvector.  
8. Next run: Agno uses updated memory automatically.  

---

## Benefits
- **Reliable automation**: MCP server abstracts Nemlig API quirks.  
- **Personalized**: Agent learns explicit rules + fuzzy semantic preferences.  
- **Scalable**: Firestore + Cloud SQL handle growth smoothly.  
- **Simple UX**: User picks recipes (URL or manual), one click → cart is ready.  
- **Lightweight planning**: Backlog.md keeps dev tasks simple and transparent.  

---
