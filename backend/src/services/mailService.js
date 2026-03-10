const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

async function sendVerificationEmail({ to, name, verificationUrl }) {
  const appName = 'Majadigi';

  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 560px; margin: 0 auto; padding: 24px; background: #ffffff;">
      <h2 style="margin: 0 0 16px; color: #202020;">Verifikasi Email ${appName}</h2>
      <p style="font-size: 14px; color: #444; line-height: 1.6;">Halo ${name},</p>
      <p style="font-size: 14px; color: #444; line-height: 1.6;">
        Terima kasih sudah mendaftar di ${appName}. Klik tombol di bawah ini untuk memverifikasi email Anda:
      </p>

      <div style="margin: 24px 0;">
        <a
          href="${verificationUrl}"
          style="display: inline-block; background: #0065ff; color: #ffffff; text-decoration: none; padding: 12px 20px; border-radius: 10px; font-weight: bold;"
        >
          Verifikasi Email
        </a>
      </div>

      <p style="font-size: 13px; color: #666; line-height: 1.6;">
        Jika tombol tidak berfungsi, salin tautan berikut ke browser:
      </p>
      <p style="font-size: 12px; color: #0065ff; word-break: break-all;">
        ${verificationUrl}
      </p>

      <p style="font-size: 12px; color: #999; line-height: 1.6;">
        Tautan ini berlaku selama ${process.env.EMAIL_TOKEN_TTL_HOURS || 24} jam.
      </p>
    </div>
  `;

  const text = `
Halo ${name},

Terima kasih sudah mendaftar di ${appName}.
Klik tautan berikut untuk memverifikasi email Anda:

${verificationUrl}

Tautan ini berlaku selama ${process.env.EMAIL_TOKEN_TTL_HOURS || 24} jam.
`;

  await transporter.sendMail({
    from: process.env.MAIL_FROM || process.env.GMAIL_USER,
    to,
    subject: 'Verifikasi Email Majadigi',
    html,
    text,
  });
}

module.exports = {
  sendVerificationEmail,
};