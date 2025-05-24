const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();
const ownerRoutes = require('./routes/ownerRoutes');
const adminRoutes = require('./routes/adminRoutes'); // ✅ If using admin approve/reject
const productsRoutes = require('./routes/productsRoutes');
const msgRoutes = require('./routes/messageRoutes');
const path = require('path');
const boxRoutes = require('./routes/boxRoutes');
const app = express();
app.use(express.json());
app.use(cors());

// Connect to MongoDB
console.log("MongoDB URI:", process.env.MONGO_URI);
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ Connected to MongoDB Atlas"))
    .catch(err => console.error("❌ MongoDB Connection Error:", err));

// Import routes
const fcmRoutes = require('./routes/FCMRouter'); // ← أو حسب اسم الملف عندك
app.use('/api/fcm', fcmRoutes);

const cupRoutes = require('./routes/cupRoutes');
app.use("/api/cups", cupRoutes);

app.use('/api/box', boxRoutes);
app.use('/api/notifications', require('./routes/notificationRoutes'));
const categoryRoutes = require('./routes/categories');
app.use('/api/categories', categoryRoutes);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/messages', msgRoutes);
const userRoutes = require('./routes/userRoutes');
app.use('/api', userRoutes);
app.use('/api/owners', ownerRoutes);
app.use('/api/admin', adminRoutes); // optional
app.use('/api', productsRoutes);
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`🚀 Server running on 0.0.0.0:${PORT}`));
