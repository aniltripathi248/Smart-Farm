const Animal = require("../models/animalModel");

// Simple helper so we can send numbers as strings from the app
const toNumber = (value) => {
  if (value === undefined || value === null || value === "") return undefined;
  const n = Number(value);
  return Number.isNaN(n) ? undefined : n;
};

// POST /api/animals
// Body shape is designed to map closely to the Flutter "add animal" flow.
//
// Example (group flow):
// {
//   "animalType": "Cow",
//   "entryMode": "group",
//   "groupInfo": {
//     "numberOfAnimals": 12,
//     "purpose": "Dairy",
//     "landAvailable": "1.5 acres",
//     "shelterAreaSqm": 120,
//     "waterPerDayLiters": 780,
//     "feedingSystem": "Semi-intensive",
//     "cleaningFrequency": "Daily",
//     "monthlyCost": 35000
//   },
//   "summary": {
//     "purpose": "Milk sales",
//     "monthlyCost": 35000,
//     "notes": "Planned expansion in Q4"
//   }
// }
exports.createAnimal = async (req, res) => {
  try {
    const {
      animalType,
      entryMode,
      singleAnimals = [],
      groupInfo,
      summary,
    } = req.body;

    if (!animalType || !entryMode) {
      return res
        .status(400)
        .json({ message: "animalType and entryMode are required." });
    }

    if (entryMode === "single" && singleAnimals.length === 0) {
      return res.status(400).json({
        message: "Add at least one animal in singleAnimals when entryMode=single.",
      });
    }

    if (entryMode === "group") {
      if (!groupInfo || !toNumber(groupInfo.numberOfAnimals)) {
        return res.status(400).json({
          message:
            "groupInfo.numberOfAnimals is required when entryMode=group.",
        });
      }
    }

    const doc = new Animal({
      owner: req.userId, // set from auth middleware
      animalType,
      entryMode,
      singleAnimals: singleAnimals.map((a, index) => ({
        tag: a.tag || `Animal ${index + 1}`,
        age: a.age,
        weightKg: toNumber(a.weightKg),
        breed: a.breed,
        bodyCondition: a.bodyCondition,
        photoUrl: a.photoUrl,
        notes: a.notes,
      })),
      groupInfo: groupInfo
        ? {
            numberOfAnimals: toNumber(groupInfo.numberOfAnimals),
            purpose: groupInfo.purpose,
            landAvailable: groupInfo.landAvailable,
            shelterAreaSqm: toNumber(groupInfo.shelterAreaSqm),
            waterPerDayLiters: toNumber(groupInfo.waterPerDayLiters),
            feedingSystem: groupInfo.feedingSystem,
            cleaningFrequency: groupInfo.cleaningFrequency,
            monthlyCost: toNumber(groupInfo.monthlyCost),
          }
        : undefined,
      summary: summary
        ? {
            purpose: summary.purpose,
            monthlyCost: toNumber(summary.monthlyCost),
            notes: summary.notes,
          }
        : undefined,
    });

    const saved = await doc.save();
    return res
      .status(201)
      .json({ message: "Animal entry created successfully", data: saved });
  } catch (err) {
    console.error("Error creating animal:", err);
    return res
      .status(500)
      .json({ message: "Failed to create animal", error: err.message });
  }
};

// GET /api/animals/all
// Returns all animal documents (for now, no auth restriction)
exports.getAllAnimals = async (_req, res) => {
  try {
    const animals = await Animal.find().populate("owner", "fullName email");
    res.status(200).json({ count: animals.length, data: animals });
  } catch (err) {
    console.error("Error fetching animals:", err);
    res
      .status(500)
      .json({ message: "Failed to fetch animals", error: err.message });
  }
};

// GET /api/animals/mine
// Returns animals for the currently authenticated user
exports.getMyAnimals = async (req, res) => {
  try {
    const userId = req.userId;

    const animals = await Animal.find({ owner: userId }).sort({
      createdAt: -1,
    });

    res.status(200).json({ count: animals.length, data: animals });
  } catch (err) {
    console.error("Error fetching user animals:", err);
    res.status(500).json({
      message: "Failed to fetch animals for this user",
      error: err.message,
    });
  }
};

// GET /api/animals/:animalId
// Returns a single animal by ID (only if owned by the authenticated user)
exports.getAnimalById = async (req, res) => {
  try {
    const { animalId } = req.params;
    const userId = req.userId;

    if (!animalId) {
      return res.status(400).json({ message: "Animal ID is required" });
    }

    const animal = await Animal.findOne({ _id: animalId, owner: userId });

    if (!animal) {
      return res.status(404).json({
        message: "Animal not found or you don't have permission to view it",
      });
    }

    res.status(200).json({ data: animal });
  } catch (err) {
    console.error("Error fetching animal:", err);
    if (err.name === "CastError") {
      return res.status(400).json({ message: "Invalid animal ID format" });
    }
    res.status(500).json({
      message: "Failed to fetch animal",
      error: err.message,
    });
  }
};

// POST /api/animals/:animalId/update
// Updates an animal entry (only if owned by the authenticated user)
exports.updateAnimal = async (req, res) => {
  try {
    const { animalId } = req.params;
    const userId = req.userId;
    const { groupInfo, summary, singleAnimals, animalType, entryMode } = req.body;

    if (!animalId) {
      return res.status(400).json({ message: "Animal ID is required" });
    }

    // Find the animal and verify ownership
    const animal = await Animal.findOne({ _id: animalId, owner: userId });

    if (!animal) {
      return res.status(404).json({
        message: "Animal not found or you don't have permission to update it",
      });
    }

    // Update fields if provided
    if (animalType !== undefined) {
      animal.animalType = animalType.trim();
    }

    if (entryMode !== undefined) {
      if (!["single", "group"].includes(entryMode)) {
        return res.status(400).json({
          message: "entryMode must be either 'single' or 'group'",
        });
      }
      animal.entryMode = entryMode;
    }

    // Update groupInfo if provided
    if (groupInfo !== undefined) {
      if (animal.entryMode === "group" || entryMode === "group") {
        animal.groupInfo = {
          numberOfAnimals: toNumber(groupInfo.numberOfAnimals),
          purpose: groupInfo.purpose,
          landAvailable: groupInfo.landAvailable,
          shelterAreaSqm: toNumber(groupInfo.shelterAreaSqm),
          waterPerDayLiters: toNumber(groupInfo.waterPerDayLiters),
          feedingSystem: groupInfo.feedingSystem,
          cleaningFrequency: groupInfo.cleaningFrequency,
          monthlyCost: toNumber(groupInfo.monthlyCost),
        };
      }
    }

    // Update singleAnimals if provided
    if (singleAnimals !== undefined && Array.isArray(singleAnimals)) {
      if (animal.entryMode === "single" || entryMode === "single") {
        animal.singleAnimals = singleAnimals.map((a, index) => ({
          tag: a.tag || `Animal ${index + 1}`,
          age: a.age,
          weightKg: toNumber(a.weightKg),
          breed: a.breed,
          bodyCondition: a.bodyCondition,
          photoUrl: a.photoUrl,
          notes: a.notes,
        }));
      }
    }

    // Update summary if provided
    if (summary !== undefined) {
      animal.summary = {
        purpose: summary.purpose,
        monthlyCost: toNumber(summary.monthlyCost),
        notes: summary.notes,
      };
    }

    const updated = await animal.save();

    res.status(200).json({
      message: "Animal updated successfully",
      data: updated,
    });
  } catch (err) {
    console.error("Error updating animal:", err);
    if (err.name === "CastError") {
      return res.status(400).json({ message: "Invalid animal ID format" });
    }
    res.status(500).json({
      message: "Failed to update animal",
      error: err.message,
    });
  }
};

// DELETE /api/animals/:animalId
// Deletes an animal entry (only if owned by the authenticated user)
exports.deleteAnimal = async (req, res) => {
  try {
    const { animalId } = req.params;
    const userId = req.userId;

    if (!animalId) {
      return res.status(400).json({ message: "Animal ID is required" });
    }

    // Find and delete the animal, ensuring ownership
    const animal = await Animal.findOneAndDelete({
      _id: animalId,
      owner: userId,
    });

    if (!animal) {
      return res.status(404).json({
        message: "Animal not found or you don't have permission to delete it",
      });
    }

    res.status(200).json({
      message: "Animal deleted successfully",
    });
  } catch (err) {
    console.error("Error deleting animal:", err);
    if (err.name === "CastError") {
      return res.status(400).json({ message: "Invalid animal ID format" });
    }
    res.status(500).json({
      message: "Failed to delete animal",
      error: err.message,
    });
  }
};


