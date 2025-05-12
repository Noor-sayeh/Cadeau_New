// routes/messageRoutes.js
const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');

router.post('/send', messageController.sendMessage);
router.get('/admin/:ownerId', messageController.getMessagesWithOwner);
// routes/messageRoutes.js
router.get('/between/:userId1/:userId2', messageController.getMessagesBetweenUsers);
router.get('/unread/admin', messageController.getUnreadForAdmin);
router.post('/mark-seen', messageController.markMessagesSeen);
router.get('/unread/owner/:ownerId', messageController.getUnreadForOwner);
module.exports = router;
