// controllers/messageController.js
const Message = require('../models/Message');

const mongoose = require('mongoose');

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
  // Get unread message counts for admin (grouped by sender)
exports.getUnreadForAdmin = async (req, res) => {
  const adminId = '68037c897aea2125f35f30a0'; // make sure this is the correct static admin ID

  try {
    const unreadCounts = await Message.aggregate([
      {
        $match: {
          receiverId: new mongoose.Types.ObjectId(adminId),
          seen: false,
        },
      },
      {
        $group: {
          _id: '$senderId',
          count: { $sum: 1 },
        },
      },
    ]);

    res.json(
  unreadCounts.map(entry => ({
    _id: entry._id.toString(),
    count: entry.count
  }))
);
// Output: [{ _id: senderId, count: 3 }, ...]
  } catch (err) {
    console.error('Error fetching unread messages:', err);
    res.status(500).json({ error: 'Failed to get unread messages' });
  }
};

exports.markMessagesSeen = async (req, res) => {
  const { senderId, receiverId } = req.body;

  try {
    await Message.updateMany(
      { senderId, receiverId, seen: false },
      { $set: { seen: true } }
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Could not mark messages seen' });
  }
};

// Get unread messages for a specific owner (grouped by sender)
exports.getUnreadForOwner = async (req, res) => {
  const { ownerId } = req.params;

  try {
    const unreadCounts = await Message.aggregate([
      {
        $match: {
          receiverId: new mongoose.Types.ObjectId(ownerId),
          seen: false,
        },
      },
      {
        $group: {
          _id: '$senderId',
          count: { $sum: 1 },
        },
      },
    ]);

    res.json(
      unreadCounts.map(entry => ({
        _id: entry._id.toString(),
        count: entry.count
      }))
    );
  } catch (err) {
    console.error('Error fetching unread messages for owner:', err);
    res.status(500).json({ error: 'Failed to get unread messages for owner' });
  }
};
