const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  content: { type: String, required: true },
  sentAt: { type: Date, default: Date.now },
  triggeredBy: { type: String, default: 'system' },
  isSeen: { type: Boolean, default: false },
  status: {
  type: String,
  enum: ['pending', 'delivered','delivery'],
  default: 'pending'
}

});


module.exports = mongoose.model('Notification', notificationSchema);
