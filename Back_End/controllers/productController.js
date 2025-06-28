const Product = require('../models/Product');
const asyncHandler = require('express-async-handler');
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const Notification = require('../models/notification');
// @desc    Get all products (with filtering)
// @route   GET /api/products
// @access  Public
exports.getProducts = asyncHandler(async (req, res) => {
  try {
    // Extract query parameters
    const { category, recipient, occasion, minPrice, maxPrice, keyword, limit = 20 } = req.query;
    
    // Build filter object
    const filter = {};
    
    if (category) filter.category = category;
    if (recipient) filter.recipientType = recipient;
    if (occasion) filter.occasion = occasion;
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    if (keyword) {
      filter.$text = { $search: keyword };
    }

    // Get products with filters
    const products = await Product.find(filter)
      .sort({ popularity: -1 })
      

    res.json({
      success: true,
      count: products.length,
      data: products
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Server Error: ' + err.message
    });
  }
});

// @desc    Get smart gift recommendations
// @route   POST /api/products/recommend
// @access  Public
exports.recommendProducts = asyncHandler(async (req, res) => {
  try {
    const { message, chatHistory = [] } = req.body;
    
    // Extract keywords from chat history (simplified NLP)
    const keywords = extractKeywordsFromChat([...chatHistory, { text: message }]);
    
    // Get recommendations (using the model's static method)
    const recommendations = await Product.recommendGifts({
      keywords,
      ...extractFiltersFromMessage(message)
    });

    if (!recommendations.length) {
      return res.json({
        success: true,
        message: "I couldn't find perfect matches, but here are some popular gifts:",
        data: await Product.find().sort('-popularity').limit(3)
      });
    }

    res.json({
      success: true,
      data: recommendations
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Recommendation failed: ' + err.message
    });
  }
});

// Helper: Extract gift filters from natural language
function extractFiltersFromMessage(message) {
  const filters = {};
  const lowerMsg = message.toLowerCase();

  // Price extraction (simple pattern)
  const priceMatch = lowerMsg.match(/(under|below|less than) (\$|€|£)?(\d+)/);
  if (priceMatch) filters.budget = Number(priceMatch[3]);

  // Recipient extraction
  const recipients = ['Parents', 'Grandparents', 'Colleagues', 'Wife/Husband', 'Siblings', 'child', 'friends'];
  recipients.forEach(recipient => {
    if (lowerMsg.includes(recipient)) filters.recipient = recipient;
  });

  // Occasion extraction
  const occasions = ['birthday', 'anniversary', 'valentine', 'christmas', 'graduation'];
  occasions.forEach(occasion => {
    if (lowerMsg.includes(occasion)) filters.occasion = occasion;
  });

  return filters;
}

// Helper: Extract keywords from conversation
function extractKeywordsFromChat(chatHistory) {
  const keywords = new Set();
  const commonWords = new Set(['the', 'and', 'for', 'with', 'this', 'that']);

  chatHistory.forEach(entry => {
    entry.text.toLowerCase().split(/\s+/).forEach(word => {
      if (word.length > 3 && !commonWords.has(word)) {
        keywords.add(word);
      }
    });
  });

  return Array.from(keywords);
}

// @desc    Update product popularity
// @route   PUT /api/products/:id/popularity
// @access  Private (Admin)
exports.updatePopularity = asyncHandler(async (req, res) => {
  try {
    const product = await Product.findOneAndUpdate(
      { productId: req.params.id },
      { $inc: { popularity: 1 } },
      { new: true }
    );

    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found'
      });
    }

    res.json({
      success: true,
      data: product
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Update failed: ' + err.message
    });
  }
});

// @desc    Add new product
// @route   POST /api/products
// @access  Private (Admin)
exports.addProduct = asyncHandler(async (req, res) => {
  const imageUrls = req.files?.map(file => {
    return `${req.protocol}://${req.get('host')}/uploads/${file.filename}`;
  }) || [];

  console.log("📥 Incoming body:", req.body);
  console.log("📸 Incoming files:", req.files);

  const { owner_id, category } = req.body;

  if (!mongoose.Types.ObjectId.isValid(owner_id) || !mongoose.Types.ObjectId.isValid(category)) {
    return res.status(400).json({ error: 'Invalid owner or category ID' });
  }

  try {
    const product = new Product({
      ...req.body,
      imageUrls,
      owner_id,
      category,
      stock: Number(req.body.stock),
      price: parseFloat(req.body.price),
      maxPrice: parseFloat(req.body.maxPrice),
      discountAmount: parseFloat(req.body.discountAmount),
      isOnSale: req.body.isOnSale === 'true',
      recipientType: JSON.parse(req.body.recipientType || '[]'),
      occasion: JSON.parse(req.body.occasion || '[]'),
      keywords: JSON.parse(req.body.keywords || '[]'),
      lastUpdated: new Date()
    });

    await product.save();
    if (owner_id) {
  await Notification.create({
    userId: owner_id,
    content: `You added a new product: ${product.name}`,
    triggeredBy: 'system'
  });
}
    res.status(201).json({
      success: true,
      data: product
    });
  } catch (err) {
    if (err instanceof mongoose.Error.ValidationError) {
      return res.status(400).json({
        success: false,
        error: 'Validation Error: ' + Object.values(err.errors).map(e => e.message).join(', ')
      });
    }
    console.error("🔥 Save Error:", err);
    res.status(500).json({
      success: false,
      error: 'Create failed: ' + err.message
    });
  }
});

exports.deleteProduct = asyncHandler(async (req, res) => {
  const product = await Product.findOne({ productId: req.params.id });


  if (!product) {
    return res.status(404).json({
      success: false,
      error: 'Product not found'
    });
  }

  // حذف الصور من مجلد uploads
  if (product.imageUrls && product.imageUrls.length) {
    product.imageUrls.forEach(url => {
      // تأكد الرابط يحتوي uploads
      if (url.includes('/uploads/')) {
        const filename = url.split('/uploads/')[1];
        const filePath = path.join(__dirname, '..', 'uploads', filename);

        fs.unlink(filePath, err => {
          if (err) {
            console.warn(`❗ Failed to delete image ${filename}:`, err.message);
          } else {
            console.log(`✅ Deleted image file: ${filename}`);
          }
        });
      } else {
        console.warn(`⚠️ URL doesn't contain /uploads/:`, url);
      }
    });
  }

  // حذف المنتج من الداتابيس
  await product.deleteOne();

  res.json({
    success: true,
    message: 'Product and its images deleted successfully'
  });
});


// Controller: productController.js
exports.updateProduct = asyncHandler(async (req, res) => {
  try {
    const { id } = req.params;

    const updates = { 
      ...req.body,
      lastUpdated: new Date()
    };
   
    

    // Handle number parsing like you do in addProduct
    if (updates.stock) updates.stock = Number(updates.stock);
    if (updates.price) updates.price = parseFloat(updates.price);
    if (updates.maxPrice) updates.maxPrice = parseFloat(updates.maxPrice);
    if (updates.discountAmount) updates.discountAmount = parseFloat(updates.discountAmount);
    if ('isOnSale' in updates) {
      updates.isOnSale = updates.isOnSale === 'true' || updates.isOnSale === true;
    }
    
    if (updates.recipientType) updates.recipientType = JSON.parse(updates.recipientType || '[]');
    if (updates.occasion) updates.occasion = JSON.parse(updates.occasion || '[]');
    if (updates.keywords) updates.keywords = JSON.parse(updates.keywords || '[]');

    const product = await Product.findByIdAndUpdate(id, updates, { new: true });


    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found'
      });
    }

    res.json({
      success: true,
      data: product
    });

  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Update failed: ' + err.message
    });
  }
});

///get product by id
exports.getProductById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false, error: 'Invalid product ID format' });
  }

  const product = await Product.findById(id);

  if (!product) {
    return res.status(404).json({ success: false, error: 'Product not found' });
  }

  res.json({ success: true, data: product });
});

///get product by owner
exports.getProductsByOwner = asyncHandler(async (req, res) => {
  const { ownerId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(ownerId)) {
    return res.status(400).json({ success: false, error: 'Invalid owner ID format' });
  }

  const products = await Product.find({ owner_id: ownerId }).sort({ createdAt: -1 });

  res.json({
    success: true,
    count: products.length,
    data: products
  });
});