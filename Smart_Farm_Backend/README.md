# Farm Companion Backend

Node.js + Express API that mirrors the structure of `BlogAppBackend` while focusing on farmer authentication (signup & login) backed by MongoDB.

## Folder structure

```
Backend-Farm_Companion
├── index.js
├── env.example
├── package.json
└── src
    ├── configs
    │   ├── config.js
    │   └── db.js
    ├── controllers
    │   └── authController.js
    ├── models
    │   └── userModel.js
    └── routes
        └── authRoutes.js
```

## Environment variables

Copy `env.example` to `.env` and fill in values:

```
PORT=5000
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-url>/<database>?retryWrites=true&w=majority
JWT_SECRET=super-secret-key
JWT_EXPIRATION=7d
```

> You can replace the `<username>`, `<password>`, and `<cluster-url>` parts with your own Atlas cluster details (e.g. `mongodb+srv://bishal_user:database123@demo.unjkt6a.mongodb.net/farm-companion`).

## Scripts

- `npm run dev` – start the API with nodemon
- `npm start` – run with Node

## Available endpoints

| Method | Endpoint             | Description                                   |
|--------|----------------------|-----------------------------------------------|
| POST   | `/api/auth/v1/signup`| Create farmer account (fullName, email, etc.) |
| POST   | `/api/auth/v1/login` | Login using email **or** phone + password     |
| GET    | `/health`            | Simple health check                            |

Both auth responses omit the password field and the login endpoint returns a JWT token so the client can maintain sessions.

## Testing quickly with curl

```
curl -X POST http://localhost:5000/api/auth/v1/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"fullName\":\"Alex Mwangi\",\"farmName\":\"Green Fields\",\"email\":\"alex@farm.com\",\"phoneNumber\":\"+254712345678\",\"password\":\"password123\"}"
```

```
curl -X POST http://localhost:5000/api/auth/v1/login ^
  -H "Content-Type: application/json" ^
  -d "{\"identifier\":\"alex@farm.com\",\"password\":\"password123\"}"
```

Replace `identifier` with the phone number to support phone-based logins.

