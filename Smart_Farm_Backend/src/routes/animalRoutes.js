const express = require("express");
const router = express.Router();

const {
  createAnimal,
  getAllAnimals,
  getMyAnimals,
  getAnimalById,
  updateAnimal,
  deleteAnimal,
} = require("../controllers/animalController");
const requireAuth = require("../middleware/authMiddleware");

// POST /api/animals/addanimal -> create a new animal entry for logged-in user
router.post("/addanimal", requireAuth, createAnimal);

// GET /api/animals/mine -> list animals for logged-in user
router.get("/mine", requireAuth, getMyAnimals);

// GET /api/animals/all -> list all animals (admin / debug)
router.get("/all", getAllAnimals);

// POST /api/animals/:animalId/update -> update an animal (authenticated user only)
// This must come before /:animalId to avoid route conflicts
router.post("/:animalId/update", requireAuth, updateAnimal);

// GET /api/animals/:animalId -> get a single animal by ID (authenticated user only)
router.get("/:animalId", requireAuth, getAnimalById);

// DELETE /api/animals/:animalId -> delete an animal (authenticated user only)
router.delete("/:animalId", requireAuth, deleteAnimal);

module.exports = router;

