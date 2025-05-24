// routes/cupRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

const cupSchema = new mongoose.Schema({
    userId: String,
  name: String, // اسم الكوب المختار
  cupColor: String,
  sticker: String,
  description: { type: String, default: "Customized cup" },
  price: { type: Number, default: 100 },
  quantity: Number,
  date: { type: Date, default: Date.now },
});

const CupChoice = mongoose.model("CupChoice", cupSchema);

router.post("/saveCupChoice", async (req, res) => {
  try {
    const choice = new CupChoice(req.body);
    await choice.save();
    res.status(200).json({ message: "✅ تم الحفظ" });
  } catch (err) {
    res.status(500).json({ message: "❌ فشل الحفظ" });
  }
});

module.exports = router;
