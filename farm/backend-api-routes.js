// ============================================
// BACKEND API ROUTES FOR ANIMAL OPERATIONS
// ============================================
// Add these routes to your backend-farm_companion server
// This file contains the routes for:
// - GET /api/animals/:id - Get single animal by ID
// - POST /api/animals/:id/update - Update animal
// - DELETE /api/animals/:id - Delete animal
// ============================================

// Example Express.js routes (adjust based on your backend framework)
// Make sure you have authentication middleware to verify the token

const express = require('express');
const router = express.Router();
const Animal = require('./models/Animal'); // Adjust path to your Animal model
const auth = require('./middleware/auth'); // Your authentication middleware

/**
 * GET /api/animals/:id
 * Get a single animal by ID
 * Requires authentication
 */
router.get('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id; // From auth middleware

    // Find animal by ID and ensure it belongs to the user
    const animal = await Animal.findOne({
      _id: id,
      userId: userId, // Ensure user owns this animal
    });

    if (!animal) {
      return res.status(404).json({
        success: false,
        message: 'Animal not found',
      });
    }

    res.json({
      success: true,
      data: animal,
    });
  } catch (error) {
    console.error('Error fetching animal:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching animal',
      error: error.message,
    });
  }
});

/**
 * POST /api/animals/:id/update
 * Update an animal
 * Requires authentication
 */
router.post('/:id/update', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { groupInfo } = req.body;

    // Validate required fields
    if (!groupInfo || !groupInfo.numberOfAnimals || !groupInfo.purpose) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: numberOfAnimals, purpose',
      });
    }

    // Find animal and ensure it belongs to the user
    const animal = await Animal.findOne({
      _id: id,
      userId: userId,
    });

    if (!animal) {
      return res.status(404).json({
        success: false,
        message: 'Animal not found',
      });
    }

    // Update animal data
    if (animal.entryMode === 'group') {
      animal.groupInfo = {
        numberOfAnimals: groupInfo.numberOfAnimals,
        purpose: groupInfo.purpose,
        monthlyCost: groupInfo.monthlyCost || animal.groupInfo?.monthlyCost || 0,
      };
    }

    animal.updatedAt = new Date();
    await animal.save();

    res.json({
      success: true,
      message: 'Animal updated successfully',
      data: animal,
    });
  } catch (error) {
    console.error('Error updating animal:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating animal',
      error: error.message,
    });
  }
});

/**
 * DELETE /api/animals/:id
 * Delete an animal
 * Requires authentication
 */
router.delete('/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    // Find animal and ensure it belongs to the user
    const animal = await Animal.findOne({
      _id: id,
      userId: userId,
    });

    if (!animal) {
      return res.status(404).json({
        success: false,
        message: 'Animal not found',
      });
    }

    // Delete the animal
    await Animal.findByIdAndDelete(id);

    res.json({
      success: true,
      message: 'Animal deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting animal:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting animal',
      error: error.message,
    });
  }
});

module.exports = router;

