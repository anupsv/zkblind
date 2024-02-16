import { bytesToBigInt, fromHex } from "@zk-email/helpers/dist/binaryFormat";
import { generateCircuitInputs } from "@zk-email/helpers/dist/input-helpers";

export const STRING_PRESELECTOR = "email was meant for @";
export const MAX_HEADER_PADDED_BYTES = 1024; // NOTE: this must be the same as the first arg in the email in main args circom
export const MAX_BODY_PADDED_BYTES = 1536; // NOTE: this must be the same as the arg to sha the remainder number of bytes in the email in main args circom

export type IBlindCircuitInputs = ReturnType<typeof generateBlindVerifierCircuitInputs>;

function trimStrByStr(str: string, substr: string) {
  const index = str.indexOf(substr);
  if (index === -1) return str;
  return str.slice(index + substr.length, str.length);
}
export function generateBlindVerifierCircuitInputs({
  rsaSignature,
  rsaPublicKey,
  body,
  bodyHash,
  message, // the message that was signed (header + bodyHash)
  ethereumAddress,
  semCommitment,
}: {
  body: Buffer;
  message: Buffer;
  bodyHash: string;
  rsaSignature: BigInt;
  rsaPublicKey: BigInt;
  ethereumAddress: string;
  semCommitment: string
}) {
  const emailVerifierInputs = generateCircuitInputs({
    rsaSignature,
    rsaPublicKey,
    body,
    bodyHash,
    message,
    shaPrecomputeSelector: STRING_PRESELECTOR,
    maxMessageLength: MAX_HEADER_PADDED_BYTES,
    maxBodyLength: MAX_BODY_PADDED_BYTES,
  });

  let raw_header = Buffer.from(message).toString();
  const email_from_idx = raw_header.length - trimStrByStr(trimStrByStr(raw_header, "from:"), "<").length;

  const bodyRemaining = emailVerifierInputs.in_body_padded!.map(c => Number(c)); // Char array to Uint8Array
  const selectorBuffer = Buffer.from(STRING_PRESELECTOR);
  const usernameIndex = Buffer.from(bodyRemaining).indexOf(selectorBuffer) + selectorBuffer.length;

  const address = bytesToBigInt(fromHex(ethereumAddress)).toString();

  return {
    ...emailVerifierInputs,
    blind_username_idx: usernameIndex.toString(),
    address,
    email_from_idx: email_from_idx,
    semCommitment: semCommitment
  };
}