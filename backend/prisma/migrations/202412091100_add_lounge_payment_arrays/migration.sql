-- Add support for multiple bank accounts and mobile wallets on lounges
ALTER TABLE "lounges"
  ADD COLUMN IF NOT EXISTS "bankAccounts" JSONB,
  ADD COLUMN IF NOT EXISTS "wallets" JSONB;
