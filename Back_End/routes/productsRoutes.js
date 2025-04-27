const express = require('express');
const { protect, adminOrOwner} = require('../Middleware/auth');
const upload = require('../Middleware/multer'); 

const multer = require('multer');
const router = express.Router();
const {
  getProducts,
  addProduct,
  recommendProducts,
  deleteProduct,
  updatePopularity,
  updateProduct,
  getProductsByOwner,
  getProductById
} = require('../controllers/productController'); // Destructured import

const Product = require('../models/Product');
router.get('/categories', (req, res) => {
  const categories = Product.schema.path('category').enumValues;
  res.json({ categories });
});


// Basic routes
router.post('/addproduct', upload.array('images', 3), addProduct);
router.get('/all', getProducts);
router.get('/owner/:ownerId', getProductsByOwner);
router.get('/:id', getProductById);

// Recommendation engine
router.post('/recommend', recommendProducts);

// Popularity tracking
router.put('/:id/popularity', updatePopularity);
router.put('/:id', updateProduct);

router.delete('/:id', deleteProduct);
module.exports = router;
