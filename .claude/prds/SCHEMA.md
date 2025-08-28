# Data Schema & Diagrams (Firestore + Cloud SQL/pgvector)

## Firestore (NoSQL)
- `users/{userId}` with subcollections: `pantry`, `preferences`, `runs`
- `recipes/{recipeId}` with subcollection: `ingredients`
- `mealPlans/{planId}`
- `carts/{cartId}` with subcollection: `items`

## Cloud SQL (pgvector)
- `app_user(user_id)`
- `product(product_id, title, brand, attributes)`
- `embedding(id, user_id, obj_type, obj_ref, embedding VECTOR, metadata)`

See detailed Mermaid diagrams and SQL DDL in full schema documentation.
