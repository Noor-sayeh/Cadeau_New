const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.post('/users', userController.createUser);  // Signup
router.post('/login', userController.loginUser);   // Login
router.get('/users', userController.getAllUsers);  // Get all users
router.delete('/users/:id', userController.deleteUser);  // Delete user by ID

module.exports = router;
