const bcrypt = require('bcrypt');
const mongoose = require('mongoose');
const User = require('./models/User'); // adjust path if needed

console.log("MongoDB URI:", process.env.MONGO_URI);
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ Connected to MongoDB Atlas"))
    .catch(err => console.error("❌ MongoDB Connection Error:", err));

async function hashAdminPassword() {
  const admin = await User.findOne({ role: 'admin' });
  if (admin && !admin.password.startsWith('$2b$')) {
    const hashed = await bcrypt.hash(admin.password, 10);
    admin.password = hashed;
    await admin.save();
    console.log('Admin password hashed.');
  } else {
    console.log('Admin already has hashed password or not found.');
  }
  mongoose.connection.close();
}

hashAdminPassword();
