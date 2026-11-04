const express = require("express");
const {
  registerFarmer,
  loginFarmer,
  updateProfile,
} = require("../controllers/authController");
const requireAuth = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/signup", registerFarmer);
router.post("/login", loginFarmer);
router.post("/update-profile", requireAuth, updateProfile);

module.exports = router;

