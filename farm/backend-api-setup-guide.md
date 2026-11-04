# Backend API Setup Guide

This guide explains how to integrate the animal detail, update, and delete API endpoints into your backend-farm_companion server.

## Files to Add/Modify

### 1. Add Routes to Your Animal Routes File

If you have a file like `routes/animals.js` or `routes/animalRoutes.js`, add these routes:

```javascript
// In your existing animal routes file, add these routes:

// GET /api/animals/:id - Get single animal
router.get('/:id', auth, async (req, res) => {
  // ... (see backend-api-routes.js for full code)
});

// POST /api/animals/:id/update - Update animal
router.post('/:id/update', auth, async (req, res) => {
  // ... (see backend-api-routes.js for full code)
});

// DELETE /api/animals/:id - Delete animal
router.delete('/:id', auth, async (req, res) => {
  // ... (see backend-api-routes.js for full code)
});
```

### 2. Ensure Your Animal Model Has These Fields

Your Animal model should have:
- `_id` or `id` - Animal ID
- `userId` - Owner's user ID
- `animalType` - Type of animal (Cow, Goat, etc.)
- `entryMode` - 'group' or 'single'
- `groupInfo` - Object containing:
  - `numberOfAnimals` - Number of animals in group
  - `purpose` - Purpose (Dairy, Meat, etc.)
  - `monthlyCost` - Monthly cost
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp

### 3. Authentication Middleware

Make sure you have an `auth` middleware that:
- Verifies the JWT token from the `Authorization: Bearer <token>` header
- Sets `req.user` with the user information (including `req.user.id`)

Example auth middleware:
```javascript
const jwt = require('jsonwebtoken');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ message: 'No token, authorization denied' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};
```

## API Endpoints

### 1. GET /api/animals/:id
Get a single animal by ID.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "_id": "animal_id",
    "animalType": "Cow",
    "entryMode": "group",
    "groupInfo": {
      "numberOfAnimals": 5,
      "purpose": "Dairy",
      "monthlyCost": 500
    },
    "userId": "user_id",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response (Error - 404):**
```json
{
  "success": false,
  "message": "Animal not found"
}
```

### 2. POST /api/animals/:id/update
Update an animal.

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "groupInfo": {
    "numberOfAnimals": 6,
    "purpose": "Dairy",
    "monthlyCost": 600
  }
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Animal updated successfully",
  "data": {
    "_id": "animal_id",
    "animalType": "Cow",
    "entryMode": "group",
    "groupInfo": {
      "numberOfAnimals": 6,
      "purpose": "Dairy",
      "monthlyCost": 600
    },
    "updatedAt": "2024-01-02T00:00:00.000Z"
  }
}
```

### 3. DELETE /api/animals/:id
Delete an animal.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (Success - 200):**
```json
{
  "success": true,
  "message": "Animal deleted successfully"
}
```

## Testing the Endpoints

You can test these endpoints using:
- Postman
- curl
- Your frontend app

Example curl commands:

```bash
# Get animal
curl -X GET http://localhost:3000/api/animals/ANIMAL_ID \
  -H "Authorization: Bearer YOUR_TOKEN"

# Update animal
curl -X POST http://localhost:3000/api/animals/ANIMAL_ID/update \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "groupInfo": {
      "numberOfAnimals": 6,
      "purpose": "Dairy",
      "monthlyCost": 600
    }
  }'

# Delete animal
curl -X DELETE http://localhost:3000/api/animals/ANIMAL_ID \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Important Notes

1. **Security**: Always verify that the animal belongs to the authenticated user before allowing updates or deletes.

2. **Error Handling**: Make sure to handle cases where:
   - Animal doesn't exist
   - User doesn't own the animal
   - Invalid data is sent
   - Database errors occur

3. **Validation**: Validate the request data before updating:
   - `numberOfAnimals` should be a positive integer
   - `purpose` should be one of the allowed values
   - `monthlyCost` should be a non-negative number

4. **Database**: Make sure your database indexes are set up for efficient queries on `userId` and `_id`.

