const express = require("express");
const cors = require("cors");

const config = require("./src/configs/config");
const db = require("./src/configs/db");

const authRoutes = require("./src/routes/authRoutes");
const animalRoutes = require("./src/routes/animalRoutes");
const userRoutes = require("./src/routes/userRoutes");


const app = express();

// Allow Flutter Web (localhost on any port) and the production domain
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl, Postman)
    if (!origin) return callback(null, true);
    // Allow any localhost origin (Flutter Web dev server)
    if (/^https?:\/\/localhost(:\d+)?$/.test(origin) ||
        /^https?:\/\/127\.0\.0\.1(:\d+)?$/.test(origin)) {
      return callback(null, true);
    }
    // Allow production domain if deployed
    return callback(null, true);
  },
  credentials: true,
}));
app.use(express.json());

db.connect();

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "Farm Companion API" });
});

app.use("/api/auth", authRoutes);
app.use("/api/animals", animalRoutes);
app.use("/api/users", userRoutes);

// 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({
    error: "Route not found",
    message: `Cannot ${req.method} ${req.path}`,
    availableRoutes: [
      "POST /api/auth/signup",
      "POST /api/auth/login",
      "POST /api/auth/update-profile",
      "POST /api/animals/addanimal",
      "GET /api/animals/mine",
      "GET /api/animals/all",
      "GET /api/animals/:animalId",
      "POST /api/animals/:animalId/update",
      "DELETE /api/animals/:animalId",
    ],
  });
});

const port = config.PORT;

app.listen(port, () => {
  console.log(`Farm Companion API is running on port ${port}`);
});

