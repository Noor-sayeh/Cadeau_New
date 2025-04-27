const nodemailer = require('nodemailer');

// Create a transporter object using your email service (example using Gmail)
const transporter = nodemailer.createTransport({
  service: 'gmail', // Using Gmail as the email service
  auth: {
    user: process.env.EMAIL_USER, // The email from which the email will be sent
    pass: process.env.EMAIL_PASS  // The password or app password for the email account
  }
});

// Function to send email to admin when an owner signs up
const sendEmailToAdmin = (ownerData) => {
  // Dynamically create the approval and denial URLs using the owner ID
  const approveLink = `http://localhost:5000/api/owners/approve?ownerId=${ownerData._id}`;
  const denyLink = `http://localhost:5000/api/owners/deny?ownerId=${ownerData._id}`;
  
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: process.env.ADMIN_EMAIL,
    subject: 'New Owner Signup Approval Request',
    html: `
      <h3>A new owner has signed up and is awaiting approval</h3>
      <p><strong>Name:</strong> ${ownerData.name}</p>
      <p><strong>Email:</strong> ${ownerData.email}</p>
      <p><strong>ID Number:</strong> ${ownerData.idNumber}</p>
      <p><strong>Phone:</strong> ${ownerData.phoneNumber}</p>
      <p><strong>Age:</strong> ${ownerData.age}</p>
      <p><strong>Description:</strong> ${ownerData.description}</p>
      <br/>
      <!-- Links for admin to approve or deny the new owner -->
      <a href="${approveLink}" style="padding: 10px 20px; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px;">Approve</a>
      &nbsp;
      <a href="${denyLink}" style="padding: 10px 20px; background-color: #f44336; color: white; text-decoration: none; border-radius: 5px;">Deny</a>
    `
  };

  // Send the email
  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.log('Error sending email:', error);
    } else {
      console.log('Email sent: ' + info.response);
    }
  });
};

module.exports = sendEmailToAdmin;
