const jwt = require("jsonwebtoken");
const config = require("../configs/config");

// Verifies JWT and attaches req.userId.
// Expects header: Authorization: Bearer <token>
const requireAuth = (req, res, next) => {
  const authHeader = req.headers.authorization || "";

  if (!authHeader.startsWith("Bearer ")) {
    return res
      .status(401)
      .json({ error: "Authorization header missing or malformed" });
  }

  const token = authHeader.substring("Bearer ".length);

  try {
    const payload = jwt.verify(token, config.JWT_SECRET);
    req.userId = payload.id;
    return next();
  } catch (err) {
    console.error("JWT verification failed:", err);
    return res.status(401).json({ error: "Invalid or expired token" });
  }
};

module.exports = requireAuth;


