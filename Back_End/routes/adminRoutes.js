const express = require('express');
const router = express.Router();  // Define the router here
const adminController = require('../controllers/adminController');  // Import the controller

// Define the route for approving the owner
router.patch('/admin/approve/:id', adminController.approveOwner);
router.get('/admin-info', adminController.getAdminInfo);
router.put('/:id/update', adminController.updateAdminInfo);

// Reset admin password by ID
router.post('/:id/reset-password', adminController.resetAdminPassword);
//updateAdminPassword

// Export the router to use in your server.js or other files
module.exports = router;
