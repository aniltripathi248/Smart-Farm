const mongoose = require("mongoose");
const config = require("./config");

const db = {};

db.connect = async () => {
  try {
    if (!config.MONGODB_URI) {
      throw new Error("MONGODB_URI is not set");
    }

    await mongoose.connect(config.MONGODB_URI, {
      autoIndex: true,
    });

    console.log("MongoDB connected");
  } catch (error) {
    console.error("MongoDB connection error:", error.message);
    console.warn("⚠️ Server running without database connection. Please configure a valid MONGODB_URI in .env.");
  }
};

db.disconnect = async () => {
  try {
    await mongoose.connection.close(false);
    console.log("MongoDB disconnected");
  } catch (error) {
    console.error("MongoDB disconnection error:", error.message);
  }
};

module.exports = db;

