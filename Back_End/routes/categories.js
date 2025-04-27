const express = require('express');
const router = express.Router();
const Category = require('../models/Category');
const uploadCategoryImage = require('../Middleware/uploadCategoryImage');
// GET all categories
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find();
    res.json({ categories });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST to create a new category
router.post('/', uploadCategoryImage.single('image'), async (req, res) => {
  try {
    const { name, icon } = req.body;
    const image = req.file ? req.file.filename : null; // Save filename

    const newCategory = new Category({
      name,
      icon,
      image
    });

    await newCategory.save();
    res.status(201).json(newCategory);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
