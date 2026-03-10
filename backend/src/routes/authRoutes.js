const express = require('express');
const {
  register,
  resendVerification,
  verifyEmail,
} = require('../controllers/authController');

const router = express.Router();

router.post('/register', register);
router.post('/resend-verification', resendVerification);
router.get('/verify-email', verifyEmail);

module.exports = router;