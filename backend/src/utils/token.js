const crypto = require('crypto');

function createVerificationToken() {
  const rawToken = crypto.randomBytes(32).toString('hex');
  const tokenHash = crypto.createHash('sha256').update(rawToken).digest('hex');

  return {
    rawToken,
    tokenHash,
  };
}

function hashToken(rawToken) {
  return crypto.createHash('sha256').update(rawToken).digest('hex');
}

module.exports = {
  createVerificationToken,
  hashToken,
};