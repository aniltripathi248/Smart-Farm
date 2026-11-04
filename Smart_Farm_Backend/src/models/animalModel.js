const mongoose = require("mongoose");

// Basic profile for one animal (used in "single / small" flow)
const singleAnimalSchema = new mongoose.Schema(
  {
    tag: { type: String, trim: true }, // e.g. "Animal 1"
    age: { type: String, trim: true }, // free-text like "2 years 3 months"
    weightKg: { type: Number, min: 0 },
    breed: { type: String, trim: true },
    bodyCondition: {
      type: String,
      enum: ["Excellent", "Good", "Fair", "Poor"],
    },
    photoUrl: { type: String, trim: true },
    notes: { type: String, trim: true },
  },
  { _id: false }
);

// Info for "group / farm setup" flow
const groupInfoSchema = new mongoose.Schema(
  {
    numberOfAnimals: { type: Number, min: 1 },
    purpose: { type: String, trim: true }, // e.g. Dairy, Meat, Breeding
    landAvailable: { type: String, trim: true }, // "1.5 acres"
    shelterAreaSqm: { type: Number, min: 0 },
    waterPerDayLiters: { type: Number, min: 0 },
    feedingSystem: { type: String, trim: true },
    cleaningFrequency: { type: String, trim: true },
    monthlyCost: { type: Number, min: 0 },
  },
  { _id: false }
);

// High‑level animal entry document
const animalSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    animalType: {
      type: String,
      required: true,
      trim: true, // e.g. Cow, Goat, Chicken
    },
    entryMode: {
      type: String,
      enum: ["single", "group"],
      required: true,
    },

    // For single/small flow (can contain up to 2 animals)
    singleAnimals: [singleAnimalSchema],

    // For group/farm setup flow
    groupInfo: groupInfoSchema,

    // Summary card from the last step in the UI
    summary: {
      purpose: { type: String, trim: true },
      monthlyCost: { type: Number, min: 0 },
      notes: { type: String, trim: true },
    },
  },
  {
    timestamps: true,
  }
);

const Animal = mongoose.model("Animal", animalSchema);

module.exports = Animal;


