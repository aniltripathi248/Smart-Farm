const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("../models/userModel");
const config = require("../configs/config");

const sanitizeUser = (userDoc) => {
  const { password, __v, ...safeUser } = userDoc.toObject();
  return safeUser;
};

const registerFarmer = async (req, res) => {
  try {
    const { fullName, farmName, email, phoneNumber, password, confirmPassword } =
      req.body;

    if (!fullName || !email || !phoneNumber || !password) {
      return res
        .status(400)
        .json({ error: "fullName, email, phoneNumber, and password are required" });
    }

    const cleanFullName = String(fullName).trim();
    const cleanEmail = String(email).toLowerCase().trim();
    const cleanPhone = String(phoneNumber).trim();
    const cleanFarmName = farmName ? String(farmName).trim() : undefined;
    const cleanPassword = String(password);

    if (cleanPassword.length < 8) {
      return res
        .status(400)
        .json({ error: "Password must be at least 8 characters long" });
    }

    if (confirmPassword && String(confirmPassword) !== cleanPassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    const [existingEmail, existingPhone] = await Promise.all([
      User.findOne({ email: cleanEmail }),
      User.findOne({ phoneNumber: cleanPhone }),
    ]);

    if (existingEmail) {
      return res.status(409).json({ error: "Email already registered" });
    }

    if (existingPhone) {
      return res.status(409).json({ error: "Phone number already registered" });
    }

    const hashedPassword = await bcrypt.hash(cleanPassword, 10);

    const user = await User.create({
      fullName: cleanFullName,
      farmName: cleanFarmName,
      email: cleanEmail,
      phoneNumber: cleanPhone,
      password: hashedPassword,
    });

    res
      .status(201)
      .json({ message: "Account created successfully", user: sanitizeUser(user) });
  } catch (error) {
    console.error("Error during registration:", error);

    // Handle MongoDB duplicate key errors (code 11000)
    if (error.code === 11000) {
      const keys = Object.keys(error.keyPattern || error.keyValue || {});
      const field = keys[0] || "detail";
      let message = "Account with this detail already exists";
      if (field === "email") {
        message = "Email already registered";
      } else if (field === "phoneNumber") {
        message = "Phone number already registered";
      } else if (field === "username") {
        message = "An account with this username already exists";
      }
      return res.status(409).json({ error: message });
    }

    // Handle Mongoose validation errors
    if (error.name === "ValidationError") {
      return res.status(400).json({ error: error.message });
    }

    res.status(500).json({ error: "Server error. Please try again later." });
  }
};

const loginFarmer = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ error: "identifier and password are required" });
    }

    const cleanIdentifier = String(identifier).trim();
    const normalizedIdentifier = cleanIdentifier.toLowerCase();
    const cleanPassword = String(password);

    const user = await User.findOne({
      $or: [{ email: normalizedIdentifier }, { phoneNumber: cleanIdentifier }],
    });

    if (!user) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    const isValid = await bcrypt.compare(cleanPassword, user.password);

    if (!isValid) {
      return res.status(400).json({ error: "Invalid credentials" });
    }

    if (!config.JWT_SECRET) {
      console.warn("JWT_SECRET missing; using fallback secret");
    }

    const token = jwt.sign({ id: user._id }, config.JWT_SECRET, {
      expiresIn: config.JWT_EXPIRATION,
    });

    res.status(200).json({
      message: "Login successful",
      token,
      user: sanitizeUser(user),
    });
  } catch (error) {
    console.error("Error during login:", error);
    res.status(500).json({ error: "Server error. Please try again later." });
  }
};

const updateProfile = async (req, res) => {
  try {
    const userId = req.userId;
    const { fullName, farmName, email, phoneNumber } = req.body;

    if (!userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // Find the user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Build update object with only provided fields
    const updateData = {};
    if (fullName !== undefined) {
      updateData.fullName = String(fullName).trim();
    }
    if (farmName !== undefined) {
      updateData.farmName = farmName ? String(farmName).trim() : undefined;
    }
    if (email !== undefined) {
      const normalizedEmail = String(email).toLowerCase().trim();
      // Check if email is already taken by another user
      const existingUser = await User.findOne({
        email: normalizedEmail,
        _id: { $ne: userId },
      });
      if (existingUser) {
        return res.status(409).json({ error: "Email already in use" });
      }
      updateData.email = normalizedEmail;
    }
    if (phoneNumber !== undefined) {
      const trimmedPhone = String(phoneNumber).trim();
      // Check if phone number is already taken by another user
      const existingUser = await User.findOne({
        phoneNumber: trimmedPhone,
        _id: { $ne: userId },
      });
      if (existingUser) {
        return res.status(409).json({ error: "Phone number already in use" });
      }
      updateData.phoneNumber = trimmedPhone;
    }

    // Update the user
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    res.status(200).json({
      message: "Profile updated successfully",
      user: sanitizeUser(updatedUser),
    });
  } catch (error) {
    console.error("Error updating profile:", error);
    if (error.name === "ValidationError") {
      return res.status(400).json({
        error: "Validation error",
        details: error.message,
      });
    }
    res.status(500).json({ error: "Server error. Please try again later." });
  }
};

module.exports = {
  registerFarmer,
  loginFarmer,
  updateProfile,
};
