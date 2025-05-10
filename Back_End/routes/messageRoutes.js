// routes/messageRoutes.js
const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');

router.post('/send', messageController.sendMessage);
router.get('/admin/:ownerId', messageController.getMessagesWithOwner);
// routes/messageRoutes.js
router.get('/between/:userId1/:userId2', messageController.getMessagesBetweenUsers);

module.exports = router;
