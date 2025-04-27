const express = require('express');
const router = express.Router();  // Define the router here
const adminController = require('../controllers/adminController');  // Import the controller

// Define the route for approving the owner
router.patch('/admin/approve/:id', adminController.approveOwner);

// Export the router to use in your server.js or other files
module.exports = router;
