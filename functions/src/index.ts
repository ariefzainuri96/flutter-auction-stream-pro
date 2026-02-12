import * as dotenv from "dotenv";
import * as logger from "firebase-functions/logger";

// 1. Change imports to use "v2"
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {RtcRole, RtcTokenBuilder, RtmTokenBuilder} from "agora-token";

import {defineSecret} from "firebase-functions/params";

// Load environment variables if you are running locally
dotenv.config();

// const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

const agoraIdProd = defineSecret("AGORA_ID_PROD");
const agoraCertProd = defineSecret("AGORA_CERT_PROD");
const agoraIdDev = defineSecret("AGORA_ID_DEV");
const agoraCertDev = defineSecret("AGORA_CERT_DEV");

// 3. Update the function signature to use "request"
export const generateAgoraToken = onCall((request) => {
  // 4. Extract data and auth from the single "request" object
  const {data} = request;

  // Now "auth" and "data" work exactly as you expect!
  //   if (!auth && !isEmulator) {
  //     throw new HttpsError(
  //       "unauthenticated",
  //       "User must be logged in to generate a token.",
  //     );
  //   }

  console.log("Received request to generate Agora token with data:", data);

  const isProd = data.env === "prod";
  const appId = isProd ? agoraIdProd : agoraIdDev;
  const appCert = isProd ? agoraCertProd : agoraCertDev;

  if (!appId.value() || !appCert.value()) {
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

  // Set Expiration (5 hour)
  const expirationTimeInSeconds = 3600;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId.value(),
      appCert.value(),
      channelName,
      uid,
      role,
      privilegeExpiredTs,
      privilegeExpiredTs,
    );

    const rtmToken = RtmTokenBuilder.buildToken(
      appId.value(),
      appCert.value(),
      uid.toString(),
      privilegeExpiredTs,
    );

    logger.info("Token generated successfully", {
      uid: uid,
      channel: channelName,
    });

    console.log("Generated RTC Token:", token);
    console.log("Generated RTM Token:", rtmToken);

    return {rtcToken: token, rtmToken: rtmToken};
  } catch (err) {
    logger.error("Token generation failed", err);
    throw new HttpsError("internal", "Could not generate token");
  }
});
