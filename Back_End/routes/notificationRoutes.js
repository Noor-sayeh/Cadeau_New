const express = require('express');
const router = express.Router();
const FcmToken = require('../models/FcmToken');
const User = require('../models/User');
const Notification = require('../models/notification'); // إضافة نموذج الإشعارات
const admin = require('../firebase'); // أو حسب المسار الصحيح لملف firebase.js

router.post('/send', async (req, res) => {
  const { content, target } = req.body;

  try {
    let tokens = [];

    // تحديد من سيرسل له الإشعار
    if (target === 'owners') {
      const owners = await User.find({ role: 'Owner' });
      const ownerIds = owners.map((o) => o._id.toString());

      const matchedTokens = await FcmToken.find({
        userId: { $in: ownerIds },
        token: { $nin: [null, ''] },
      });

      tokens = matchedTokens.map(t => t.token);
    } else {
      const allTokens = await FcmToken.find({ token: { $nin: [null, ''] } });
      tokens = allTokens.map(t => t.token);
    }

    // إذا لم تكن هناك توكنات
    if (tokens.length === 0) {
      return res.status(400).json({ message: 'No tokens available' });
    }

    // رسالة الإشعار
    const message = {
      notification: {
        title: '📢 Cadeau Admin Message',
        body: content,
      }
    };

    // إرسال الإشعار لكل توكن بشكل فردي
    let successCount = 0;
    let failureCount = 0;

    for (let token of tokens) {
      try {
        message.token = token; // إضافة التوكن إلى الرسالة
        const response = await admin.messaging().send(message);

        if (response.successCount === 1) {
          successCount++;
          
          // حفظ الإشعار في قاعدة البيانات بعد إرساله بنجاح
          const user = await FcmToken.findOne({ token }); // إيجاد المستخدم بناءً على التوكن
          if (user) {
            await Notification.create({
              userId: user.userId, // تخزين معرف المستخدم الذي استلم الإشعار
              content: content, // تخزين محتوى الإشعار
              sentAt: new Date(), // تخزين وقت الإرسال
              isSeen: false, // تحديد أن المستخدم لم يشاهد الإشعار بعد
            });
          }
        } else {
          failureCount++;
        }
      } catch (err) {
        failureCount++;
        console.error('❌ Error sending to token:', token, err.message);
      }
    }

    res.json({
      message: `✅ Sent to ${successCount} devices, failed: ${failureCount}`,
    });

  } catch (err) {
    console.error('❌ Firebase send error:', err.message);
    res.status(500).json({ error: 'Failed to send notifications' });
  }
});
// تحديث حالة الإشعار عند مشاهدته
router.post('/mark-as-seen', async (req, res) => {
  const { notificationId } = req.body;

  try {
    const notification = await Notification.findById(notificationId);
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    notification.isSeen = true; // تحديث حالة الإشعار
    await notification.save();

    res.json({ message: 'Notification marked as seen' });
  } catch (err) {
    console.error('❌ Error marking notification as seen:', err.message);
    res.status(500).json({ error: 'Failed to mark notification as seen' });
  }
});


module.exports = router;
