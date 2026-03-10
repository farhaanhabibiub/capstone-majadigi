const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { createVerificationToken, hashToken } = require('../utils/token');
const { sendVerificationEmail } = require('../services/mailService');

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isValidPhone(phone) {
  return /^\d{10,15}$/.test(phone);
}

function isValidPassword(password) {
  return /^(?=.*[A-Za-z])(?=.*\d).{8,}$/.test(password);
}

function escapeHtml(text = '') {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function renderVerificationPage({
  title,
  message,
  success = true,
  actionUrl = '',
  actionLabel = 'Buka Aplikasi',
}) {
  const safeTitle = escapeHtml(title);
  const safeMessage = escapeHtml(message);
  const safeActionUrl = escapeHtml(actionUrl);
  const safeActionLabel = escapeHtml(actionLabel);
  const accent = success ? '#0065ff' : '#e53935';

  return `
    <!doctype html>
    <html lang="id">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>${safeTitle}</title>
      <style>
        body {
          margin: 0;
          padding: 0;
          background: #f2f4f8;
          font-family: Arial, sans-serif;
          display: flex;
          align-items: center;
          justify-content: center;
          min-height: 100vh;
        }
        .card {
          width: 100%;
          max-width: 420px;
          background: #ffffff;
          border-radius: 18px;
          padding: 28px 24px;
          box-shadow: 0 12px 40px rgba(0,0,0,0.08);
          text-align: center;
        }
        .icon {
          width: 72px;
          height: 72px;
          margin: 0 auto 18px;
          border-radius: 50%;
          background: ${accent};
          color: #fff;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 34px;
          font-weight: bold;
        }
        h1 {
          margin: 0 0 10px;
          font-size: 22px;
          color: #202020;
        }
        p {
          margin: 0 0 22px;
          font-size: 14px;
          line-height: 1.6;
          color: #666;
        }
        .btn {
          display: inline-block;
          padding: 12px 18px;
          background: #0065ff;
          color: white;
          text-decoration: none;
          border-radius: 10px;
          font-weight: bold;
        }
        .note {
          margin-top: 14px;
          font-size: 12px;
          color: #999;
        }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="icon">${success ? '✓' : '!'}</div>
        <h1>${safeTitle}</h1>
        <p>${safeMessage}</p>
        ${safeActionUrl ? `<a class="btn" href="${safeActionUrl}">${safeActionLabel}</a>` : ''}
        <div class="note">Majadigi Authentication Service</div>
      </div>
    </body>
    </html>
  `;
}

function buildVerificationUrl(rawToken) {
  return `${process.env.APP_BASE_URL}/api/auth/verify-email?token=${encodeURIComponent(rawToken)}`;
}

async function register(req, res) {
  try {
    let { name, email, phone, password } = req.body;

    name = String(name || '').trim();
    email = String(email || '').trim().toLowerCase();
    phone = String(phone || '').trim();
    password = String(password || '');

    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'Semua field wajib diisi',
      });
    }

    if (name.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Nama minimal 3 karakter',
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'Format email tidak valid',
      });
    }

    if (!isValidPhone(phone)) {
      return res.status(400).json({
        success: false,
        message: 'Nomor telepon harus 10 sampai 15 digit',
      });
    }

    if (!isValidPassword(password)) {
      return res.status(400).json({
        success: false,
        message: 'Password minimal 8 karakter dan harus mengandung huruf serta angka',
      });
    }

    const existingUser = await User.findOne({ email });

    if (existingUser && existingUser.status === 'active') {
      return res.status(409).json({
        success: false,
        message: 'Email sudah terdaftar dan aktif',
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const { rawToken, tokenHash } = createVerificationToken();

    const ttlHours = Number(process.env.EMAIL_TOKEN_TTL_HOURS || 24);
    const expiresAt = new Date(Date.now() + ttlHours * 60 * 60 * 1000);

    let user;

    if (existingUser) {
      existingUser.name = name;
      existingUser.phone = phone;
      existingUser.passwordHash = passwordHash;
      existingUser.status = 'pending';
      existingUser.isEmailVerified = false;
      existingUser.verificationTokenHash = tokenHash;
      existingUser.verificationTokenExpiresAt = expiresAt;
      existingUser.verifiedAt = null;

      user = await existingUser.save();
    } else {
      user = await User.create({
        name,
        email,
        phone,
        passwordHash,
        status: 'pending',
        isEmailVerified: false,
        verificationTokenHash: tokenHash,
        verificationTokenExpiresAt: expiresAt,
      });
    }

    const verificationUrl = buildVerificationUrl(rawToken);

    await sendVerificationEmail({
      to: user.email,
      name: user.name,
      verificationUrl,
    });

    return res.status(existingUser ? 200 : 201).json({
      success: true,
      message: 'Email verifikasi berhasil dikirim',
      data: {
        email: user.email,
        status: user.status,
      },
    });
  } catch (error) {
    console.error('register error:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal melakukan registrasi',
    });
  }
}

async function resendVerification(req, res) {
  try {
    let { email } = req.body;
    email = String(email || '').trim().toLowerCase();

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email wajib diisi',
      });
    }

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan',
      });
    }

    if (user.status === 'active' || user.isEmailVerified) {
      return res.status(400).json({
        success: false,
        message: 'Email sudah terverifikasi',
      });
    }

    const { rawToken, tokenHash } = createVerificationToken();
    const ttlHours = Number(process.env.EMAIL_TOKEN_TTL_HOURS || 24);

    user.verificationTokenHash = tokenHash;
    user.verificationTokenExpiresAt = new Date(Date.now() + ttlHours * 60 * 60 * 1000);

    await user.save();

    const verificationUrl = buildVerificationUrl(rawToken);

    await sendVerificationEmail({
      to: user.email,
      name: user.name,
      verificationUrl,
    });

    return res.status(200).json({
      success: true,
      message: 'Tautan verifikasi berhasil dikirim ulang',
    });
  } catch (error) {
    console.error('resendVerification error:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengirim ulang tautan verifikasi',
    });
  }
}

async function verifyEmail(req, res) {
  try {
    const rawToken = String(req.query.token || '');

    if (!rawToken) {
      return res
        .status(400)
        .send(
          renderVerificationPage({
            title: 'Tautan Tidak Valid',
            message: 'Token verifikasi tidak ditemukan.',
            success: false,
          })
        );
    }

    const tokenHash = hashToken(rawToken);

    const user = await User.findOne({
      verificationTokenHash: tokenHash,
      verificationTokenExpiresAt: { $gt: new Date() },
      status: 'pending',
    });

    if (!user) {
      return res
        .status(400)
        .send(
          renderVerificationPage({
            title: 'Tautan Kadaluarsa',
            message: 'Tautan verifikasi tidak valid atau sudah kadaluarsa.',
            success: false,
          })
        );
    }

    user.status = 'active';
    user.isEmailVerified = true;
    user.verifiedAt = new Date();
    user.verificationTokenHash = null;
    user.verificationTokenExpiresAt = null;

    await user.save();

    const actionUrl =
      process.env.MOBILE_LOGIN_DEEP_LINK || process.env.WEB_LOGIN_URL || '';

    return res.status(200).send(
      renderVerificationPage({
        title: 'Email Berhasil Diverifikasi',
        message: 'Akun Anda sudah aktif. Silakan kembali ke aplikasi dan masuk.',
        success: true,
        actionUrl,
        actionLabel: 'Buka Majadigi',
      })
    );
  } catch (error) {
    console.error('verifyEmail error:', error);
    return res
      .status(500)
      .send(
        renderVerificationPage({
          title: 'Verifikasi Gagal',
          message: 'Terjadi kesalahan pada server saat memverifikasi email.',
          success: false,
        })
      );
  }
}

module.exports = {
  register,
  resendVerification,
  verifyEmail,
};