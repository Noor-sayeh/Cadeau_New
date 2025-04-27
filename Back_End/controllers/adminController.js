// controllers/adminController.js
const User = require('../models/User');

exports.approveOwner = async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await User.findByIdAndUpdate(id, { status: 'approved' }, { new: true });
    res.status(200).json({ message: 'Owner approved', user: updated });
  } catch (err) {
    res.status(500).json({ error: 'Approval failed' });
  }
};

exports.rejectOwner = async (req, res) => {
  try {
    const { id } = req.params;
    await User.findByIdAndDelete(id);
    res.status(200).json({ message: 'Owner rejected and removed' });
  } catch (err) {
    res.status(500).json({ error: 'Rejection failed' });
  }
};
