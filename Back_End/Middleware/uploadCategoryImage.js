// In uploadCategoryImage.js
const multer = require('multer');
const path = require('path');

const categoryStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/categories/'); // a separate folder
  },
  filename: function (req, file, cb) {
    const uniqueName = Date.now() + '-' + file.originalname;
    cb(null, uniqueName);
  }
});
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif/;
  
    const extName = path.extname(file.originalname).toLowerCase();
  
    console.log(`🧐 File received: ${file.originalname}`);
    console.log(`📂 Extension: ${extName}`);
  
    const isExtValid = allowedTypes.test(extName);
  
    if (isExtValid) {
      cb(null, true); // ✅ امتداد صحيح، اقبل الملف
    } else {
      console.warn(`🚫 Rejected file: ${file.originalname} (ext: ${extName})`);
      cb(new Error('Only image files are allowed!'), false); // ❌ امتداد خاطئ
    }
  };
const uploadCategoryImage = multer({ storage: categoryStorage, fileFilter });

module.exports = uploadCategoryImage;
