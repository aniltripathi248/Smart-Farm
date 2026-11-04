const mongoose = require("mongoose");
const config = require("../src/configs/config");

async function dropUsernameIndex() {
  try {
    if (!config.MONGODB_URI) {
      throw new Error("MONGODB_URI is not set");
    }

    await mongoose.connect(config.MONGODB_URI);
    console.log("Connected to MongoDB");

    const db = mongoose.connection.db;
    const collection = db.collection("users");

    // Get all indexes
    const indexes = await collection.indexes();
    console.log("Current indexes:", indexes);

    // Check if username index exists
    const usernameIndex = indexes.find(
      (idx) => idx.key && idx.key.username === 1
    );

    if (usernameIndex) {
      console.log("Found username index, dropping it...");
      await collection.dropIndex("username_1");
      console.log("✅ Successfully dropped username index");
    } else {
      console.log("ℹ️  No username index found. Nothing to drop.");
    }

    // Show updated indexes
    const updatedIndexes = await collection.indexes();
    console.log("Updated indexes:", updatedIndexes);

    await mongoose.connection.close();
    console.log("Connection closed");
    process.exit(0);
  } catch (error) {
    console.error("Error:", error.message);
    if (error.code === 27) {
      console.log("ℹ️  Index doesn't exist or already dropped");
    }
    await mongoose.connection.close();
    process.exit(1);
  }
}

dropUsernameIndex();

