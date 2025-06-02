// routes/ReviewRoutes.js
const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/ReviewController');
const Product = require('../models/Product'); // ✅ This is missing!
const Review = require('../models/Review');
// Route to create a new review
// POST /api/reviews
router.post('/', reviewController.createReview);

// Route to get all reviews for a specific product
// GET /api/products/:productId/reviews
// routes/ReviewRoutes.js
router.get('/products/:productId', reviewController.getReviewsForProduct);
// Route to delete a review
// DELETE /api/reviews/:reviewId
router.delete('/:reviewId', reviewController.deleteReview);
// GET /api/reviews/owner/:ownerId
router.get('/owner/:ownerId', async (req, res) => {
  try {
    const ownerId = req.params.ownerId.trim(); // ✅ fix here

    const products = await Product.find({ owner_id: ownerId }).select('_id');

    if (!products.length) {
      return res.json({ success: true, data: [] });
    }

    const productIds = products.map((product) => product._id);

    const reviews = await Review.find({ product: { $in: productIds } })
      .populate('user', 'name avatar')
      .populate('product', 'name');

    const formatted = reviews.map((r) => ({
      userName: r.user?.name ?? 'Anonymous',
      userAvatar: r.user?.avatar ?? '',
      comment: r.comment,
      rating: r.rating,
      productName: r.product?.name ?? 'Unknown Product',
    }));

    return res.json({ success: true, data: formatted });
  } catch (error) {
    console.error('❌ Error in owner reviews:', error.message);
    return res.status(500).json({ success: false, error: error.message });
  }
});



module.exports = router;