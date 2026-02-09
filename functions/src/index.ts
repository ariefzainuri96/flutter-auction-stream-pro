import * as dotenv from "dotenv";
import * as logger from "firebase-functions/logger";

// 1. Change imports to use "v2"
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {RtcRole, RtcTokenBuilder} from "agora-token";

// Load environment variables if you are running locally
dotenv.config();

const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

// 3. Update the function signature to use "request"
export const generateAgoraToken = onCall((request) => {
  // 4. Extract data and auth from the single "request" object
  const {data, auth} = request;

  // Now "auth" and "data" work exactly as you expect!
  if (!auth && !isEmulator) {
    throw new HttpsError(
      "unauthenticated",
      "User must be logged in to generate a token.",
    );
  }

  const isProd = data.env === "prod";

  const appId = isProd ? process.env.AGORA_ID_PROD : process.env.AGORA_ID_DEV;
  const appCert = isProd ?
    process.env.AGORA_CERT_PROD :
    process.env.AGORA_CERT_DEV;

  if (!appId || !appCert) {
    throw new HttpsError(
      "unauthenticated",
      "Agora App ID or Agora App Certificate is not configured properly.",
    );
  }

  const channelName = data.channelName;
  const uid = data.uid || 0;
  const role =
        data.role === "publisher" ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  if (!channelName) {
    throw new HttpsError(
      "invalid-argument",
      "The function must be called with a 'channelName'.",
    );
  }

  // Set Expiration (1 hour)
  const expirationTimeInSeconds = 3600;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appCert,
      channelName,
      uid,
      role,
      privilegeExpiredTs,
      privilegeExpiredTs,
    );

    logger.info("Token generated successfully", {
      uid: uid,
      channel: channelName,
    });

    return {token: token};
  } catch (err) {
    logger.error("Token generation failed", err);
    throw new HttpsError("internal", "Could not generate token");
  }
});
