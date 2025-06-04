const express = require('express');
const router = express.Router();
const Order = require('../models/Orders');
const Notification = require('../models/notification');


router.put('/:orderId/status', async (req, res) => {
  try {
    const { status } = req.body;
    const updated = await Order.findByIdAndUpdate(req.params.orderId, { status }, { new: true });
    if (!updated) return res.status(404).json({ error: 'Order not found' });
    res.json(updated);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
router.post('/mark-delivered', async (req, res) => {
  const { notificationId } = req.body;
  try {
    await Notification.findByIdAndUpdate(notificationId, { status: 'delivered' });
    res.json({ message: 'Marked as delivered' });
  } catch (error) {
    res.status(500).json({ error: 'Error updating status' });
  }
});

router.post('/create', async (req, res) => {
  try {
   
    const newOrder = new Order(req.body);
    await newOrder.save();

    await Notification.create({
  userId: null,
  content: `Order ${order._id} from user ${order.userId} is still pending delivery.`,
  triggeredBy: 'system',
  status: 'pending'  // 👈 Add this field
});


  

    res.status(201).json({ message: 'Order created successfully', order: newOrder });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to create order' });
  }
  
});

router.get('/user/:userId', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId }).sort({ createdAt: -1 });
    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: 'Failed to fetch orders' });
  }
});

module.exports = router;