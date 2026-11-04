const User = require("../models/userModel");

// GET /api/users
// Returns all users (without passwords)
const getAllUsers = async (_req, res) => {
  try {
    const users = await User.find().select("-password -__v");
    res.status(200).json({ count: users.length, data: users });
  } catch (error) {
    console.error("Error fetching users:", error);
    res
      .status(500)
      .json({ error: "Failed to fetch users", details: error.message });
  }
};

module.exports = { getAllUsers };


