const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Notification = require('../models/notification');
const Order = require('../models/Orders'); // ✅ REQUIRED for scan-pending-orders route

// Admin sends notification
router.post('/send', async (req, res) => {
  const { content, target, userIds } = req.body;

  try {
    let users = [];

    if (target === 'owners') {
  if (Array.isArray(userIds) && userIds.length > 0) {
    users = await User.find({ _id: { $in: userIds }, role: /^owner$/i });
  } else {
    users = await User.find({ role: /^owner$/i });
  }
} else if (target === 'users') {
  users = await User.find({ role: /^customer$/i }); // ✅ يدعم "customer" و"Customer"
} else {
      return res.status(400).json({ error: 'Invalid target group' });
    }

    if (users.length === 0) {
      return res.status(404).json({ error: 'No users found for this target' });
    }

    const notifications = users.map(user => ({
      userId: user._id,
      content,
      triggeredBy: 'admin'
    }));

    await Notification.insertMany(notifications);

    res.status(200).json({ message: `Notification sent to ${users.length} users.` });
  } catch (error) {
    console.error('❌ Error sending notification:', error.message);
    res.status(500).json({ error: 'Failed to send notifications' });
  }
});

// تعديل route: GET /api/notifications
router.get('/', async (req, res) => {
  try {
    // 1. Scan for pending orders
    const pendingOrders = await Order.find({ status: 'pending' });
    for (const order of pendingOrders) {
      const exists = await Notification.findOne({
        content: { $regex: order._id.toString(), $options: 'i' },
      });

      if (!exists) {
        await Notification.create({
          userId: null,
          content: `Order ${order._id} from user ${order.userId} is still pending delivery.`,
          triggeredBy: 'system',
          status: 'pending',
        });
      }
    }

    // 2. Fetch and populate notifications
    const notifications = await Notification.find()
      .sort({ sentAt: -1 })
      .populate('userId', 'name');

    // 3. Enhance each with real order status and order details
    const enhanced = await Promise.all(
      notifications.map(async (notif) => {
        const notifObj = notif.toObject(); // make it modifiable

        const match = notif.content.match(/Order (\w+)/);
        if (match && match[1]) {
          const order = await Order.findById(match[1]).lean();
          if (order) {
            notifObj.orderStatus = order.status;
            notifObj.orderDetails = order;
          }
        }

        return notifObj;
      })
    );

    res.status(200).json(enhanced);
  } catch (err) {
    console.error('❌ Error in GET /notifications:', err.message);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});




// Get notifications for user
router.get('/:userId', async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.params.userId }).sort({ sentAt: -1 });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});
router.post('/mark-delivered', async (req, res) => {
  const { notificationId } = req.body;

  try {
    const notification = await Notification.findById(notificationId);
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    // 1. Extract the order ID from the content
    const match = notification.content.match(/Order (\w+)/);
    if (!match || !match[1]) {
      return res.status(400).json({ error: 'Order ID not found in notification content' });
    }

    const orderId = match[1];

    // 2. Update the order
    const updatedOrder = await Order.findByIdAndUpdate(orderId, { status: 'delivery' }, { new: true });
    if (!updatedOrder) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // 3. Update the notification
    notification.status = 'delivered';
    await notification.save();
    await Notification.create({
  userId: updatedOrder.userId,
  content: `Your order ${orderId} is now out for delivery.`,
  triggeredBy: 'system',
  status: 'delivery'
});
    res.json({ message: 'Order and notification marked as delivered' });
  } catch (error) {
    console.error('❌ Error updating order and notification:', error.message);
    res.status(500).json({ error: 'Failed to update status' });
  }
});







// Mark one as seen
router.post('/mark-all-seen', async (req, res) => {
  try {
    await Notification.updateMany({ isSeen: false }, { $set: { isSeen: true } });
    res.json({ message: 'All notifications marked as seen' });
  } catch (err) {
    res.status(500).json({ error: 'Error updating notifications' });
  }
});
router.get('/scan-pending-orders', async (req, res) => {
  const pendingOrders = await Order.find({ status: 'pending' });
  for (const order of pendingOrders) {
    const exists = await Notification.findOne({
      content: { $regex: order._id.toString(), $options: 'i' },
    });

    if (!exists) {
      await Notification.create({
        userId: null,
        content: `Order ${order._id} from user ${order.userId} is still pending delivery.`,
        triggeredBy: 'system',
      });
    }
  }

  res.status(200).json({ message: 'Pending order scan complete' });
});


module.exports = router;
