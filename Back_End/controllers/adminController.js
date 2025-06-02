// controllers/adminController.js
const User = require('../models/User');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const Review = require('../models/Review');
require('dotenv').config();
const Order = require('../models/Orders');
exports.approveOwner = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await User.findByIdAndUpdate(id, { status: 'approved' }, { new: true });
    res.status(200).json({ message: 'Owner approved', user: updated });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed' });
  }
};

exports.rejectOwner = async (req, res) => {
  try {
    const { id } = req.params;
    await User.findByIdAndDelete(id);
    res.status(200).json({ message: 'Owner rejected and removed' });
  } catch (err) {
    res.status(500).json({ error: 'Rejection failed' });
  }
};


exports.getAdminInfo = async (req, res) => {
  try {
    const admin = await User.findOne({ role: 'admin' }).select('name email');
    if (!admin) {
      return res.status(404).json({ message: 'Admin not found' });
    }
    res.status(200).json(admin);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};


exports.getAdminStats = async (req, res) => {
  try {
    const totalOrders = await Order.countDocuments();
    const totalUsers = await User.countDocuments({
      role: { $in: ['Customer', 'customer'] }
    });

    const totalOwners = await User.countDocuments({
      role: { $in: ['Owner', 'owner'] }
    });

    const revenueResult = await Order.aggregate([
      {
        $group: {
          _id: null,
          total: { $sum: { $ifNull: ['$totalAmount', 0] } }
        }
      }
    ]);

    const totalRevenue = revenueResult[0]?.total ?? 0;

    res.json({
      users: totalUsers,
      owners: totalOwners,
      totalRevenue: totalRevenue.toFixed(2),
        orders: totalOrders,
    });
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch stats', error: err });
  }
};



exports.resetAdminPassword = async (req, res) => {
  try {
    const { oldPassword, newPassword, confirmPassword } = req.body;
    const adminId = req.params.id;

    if (newPassword !== confirmPassword) {
      return res.status(400).json({ message: 'New passwords do not match' });
    }

    const admin = await User.findOne({ _id: adminId, role: 'admin' });
    if (!admin) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    // ❗ Plain text comparison (only works if password is NOT hashed)
    if (admin.password !== oldPassword) {
      return res.status(401).json({ message: 'Old password is incorrect' });
    }

    admin.password = newPassword;
    await admin.save();

    res.status(200).json({ message: 'Password updated successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to update password', error: err.message });
  }
};

// Get all reviews (admin use with product owner name)
exports.getAllReviews = async (req, res) => {
  try {
    const reviews = await Review.find()
      .populate('user', 'name avatar') // معلومات المستخدم
      .populate({
        path: 'product',
        select: 'name owner_id',
        populate: {
          path: 'owner_id',
          select: 'name' // اسم صاحب المنتج فقط
        }
      })
      .sort({ createdAt: -1 });

    const formatted = reviews.map((r) => ({
      _id: r._id,
      rating: r.rating,
      comment: r.comment,
      createdAt: r.createdAt,
      userName: r.user.name,
      userAvatar: r.user.avatar,
      productName: r.product?.name || '',
      productOwnerName: r.product?.owner_id?.name || '',
    }));

    res.json({
      success: true,
      count: formatted.length,
      data: formatted,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      error: 'Failed to fetch reviews: ' + err.message
    });
  }
};


exports.updateAdminInfo = async (req, res) => {
  try {
    const { name, email, password } = req.body; // Fixed to reflect password field
    const adminId = req.params.id;

    // Check if the admin exists
    const admin = await User.findOne({ _id: adminId, role: 'admin' });
    if (!admin) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    // Update admin's name and email (if provided)
    admin.name = name || admin.name;
    admin.email = email || admin.email;

    // If password is provided, hash it and update it
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      admin.password = hashedPassword;
    }

    // Save updated admin info
    await admin.save();

    res.status(200).json({ message: 'Admin info updated successfully', admin });
  } catch (err) {
    res.status(500).json({ message: 'Failed to update admin info', error: err.message });
  }
};

async function updateAdminPassword() {
  const user = await User.findOne({ email: "admin@example.com" });
  if (user) {
    user.password = await bcrypt.hash("newSecurePassword123", 10);
    await user.save();
    console.log("✅ Admin password updated.");
  }
}
updateAdminPassword();