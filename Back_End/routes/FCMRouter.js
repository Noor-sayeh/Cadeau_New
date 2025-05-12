const FcmToken = require('../models/FcmToken');
const express = require('express');
const router = express.Router();

router.post('/store-token', async (req, res) => {
  const { userId, fcmToken } = req.body;

  try {
     if (userId === '68037c897aea2125f35f30a0') {
      console.log('✅ Saving token for static admin.');
      
      // التأكد من أن التوكن ليس فارغاً
      if (!fcmToken) {
        return res.status(400).json({ error: 'FCM token is required for admin' });
      }

      // محاولة إيجاد التوكن في قاعدة البيانات
      const existingAdminToken = await FcmToken.findOne({ userId });

      if (existingAdminToken) {
        // إذا كان التوكن موجوداً بالفعل، قم بتحديثه
        existingAdminToken.token = fcmToken;
        existingAdminToken.updatedAt = new Date();
        await existingAdminToken.save();
        return res.json({ message: 'Admin token updated successfully' });
      }

      // إذا لم يكن هناك توكن موجود، قم بإنشائه
      await FcmToken.create({ userId, token: fcmToken });
      return res.json({ message: 'Admin token saved successfully' });
    }
    const existing = await FcmToken.findOne({ userId });

    if (existing) {
      existing.token = fcmToken;
      existing.updatedAt = new Date();
      await existing.save();
      return res.json({ message: 'Token updated successfully' });
    }

    await FcmToken.create({ userId, token: fcmToken });
    res.json({ message: 'Token saved successfully' });
  } catch (err) {
    console.error('❌ Error saving token:', err.message);
    res.status(500).json({ error: 'Failed to save token' });
  }
});
module.exports = router;
