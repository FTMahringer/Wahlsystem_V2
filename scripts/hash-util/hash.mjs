/**
 * Generates a peppered password hash.
 * Usage: node hash.mjs <password> <pepper> <algorithm> <strength>
 *
 * When pepper is non-empty, applies HMAC-SHA256(password, pepper) first,
 * matching PepperedPasswordEncoder logic on the Spring Boot side.
 */
import bcrypt from "bcryptjs";
import crypto from "crypto";

const [
  ,
  ,
  password = "admin123",
  pepper = "",
  algorithm = "bcrypt",
  strengthStr = "12",
] = process.argv;
const strength = parseInt(strengthStr, 10);

if (algorithm !== "bcrypt") {
  throw new Error(
    `Unsupported algorithm "${algorithm}" in hash-util. Expected bcrypt.`,
  );
}

let toHash = password;
if (pepper) {
  toHash = crypto
    .createHmac("sha256", pepper)
    .update(password)
    .digest("base64");
}

const hash = bcrypt.hashSync(toHash, strength);
process.stdout.write(hash);
