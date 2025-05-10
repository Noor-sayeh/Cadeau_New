// controllers/messageController.js
const Message = require('../models/Message');

// Send message
// Send message
exports.sendMessage = async (req, res) => {
  const { senderId, receiverId, content } = req.body;
  const mongoose = require('mongoose');

  try {
    const message = new Message({
      senderId: new mongoose.Types.ObjectId(senderId),
      receiverId: new mongoose.Types.ObjectId(receiverId),
      content,
    });
    await message.save();
    res.status(201).json(message);
  } catch (err) {
    console.error('Send message error:', err);
    res.status(500).json({ error: 'Send failed' });
  }
};


// Get messages between admin and one owner
exports.getMessagesWithOwner = async (req, res) => {
  const adminId = '68037c897aea2125f35f30a0'; // Replace with actual admin id (maybe from token)
  const ownerId = req.params.ownerId;
  try {
    
const messages = await Message.find({
  $or: [
    { senderId: adminId, receiverId: ownerId },
    { senderId: ownerId, receiverId: adminId },
  ],
}).sort({ timestamp: 1 });

    res.json(messages);
  } catch (err) {
    res.status(500).json({ error: 'Could not fetch messages' });
  }
};
// Get messages between any two users
exports.getMessagesBetweenUsers = async (req, res) => {
    const { userId1, userId2 } = req.params;
    const mongoose = require('mongoose');
  
    try {
      const id1 = new mongoose.Types.ObjectId(userId1);
      const id2 = new mongoose.Types.ObjectId(userId2);
  
      const messages = await Message.find({
        $or: [
          { senderId: id1, receiverId: id2 },
          { senderId: id2, receiverId: id1 },
        ],
      }).sort({ timestamp: 1 });
  
      res.json(messages);
    } catch (err) {
      console.error('Error fetching messages:', err);
      res.status(500).json({ error: 'Invalid user ID or fetch failed' });
    }
  };
  