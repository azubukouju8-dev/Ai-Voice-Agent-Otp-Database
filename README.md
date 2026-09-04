# AI Voice Agent — OTP Authentication with MySQL

A conversational voice agent that answers customer service calls, verifies caller identity with a one-time code, and retrieves account information from a live MySQL database.

Callers speak to the agent naturally over the phone. There are no menus, no hold queues, and no waiting for a human representative.

## What it does

The agent handles two kinds of callers.

Existing customers are verified before any account information is shared. The agent asks for the phone number registered to the account, sends a five-digit code to the email address on file, and confirms that code before proceeding. Once verified, it can read back the caller's balance, bonuses, referral earnings, current plan and account status.

Passwords, bank details and other sensitive fields are never disclosed, regardless of how the request is phrased.

New callers need no verification. The agent answers general questions about plans, deposits, withdrawals and how the platform works.

## Architecture
Caller → ElevenLabs agent → n8n webhooks → MySQL
                                        → SMTP (code delivery)

The agent handles the conversation. Three n8n workflows do the operational work, each exposed to the agent as a webhook tool.

## The workflows
### [start-verification.json](workflows/start-verification.json)

Issues the one-time code.

Webhook → look up customer → generate code → store it → send email → respond

Takes the phone number from the agent, finds the matching customer record, generates a random five-digit code, saves it to otp_codes with an expiry timestamp, and emails it to the address registered on the account.

### [check-otp.json](workflows/check-otp.json)

Validates the code.

Webhook → query code → If → mark used → respond

Checks three conditions: the code matches, it has not expired, and it has not been used before. On success the code is immediately marked as used so it cannot be replayed. Both branches return an explicit status to the agent.

### [mysql project.json](workflows/mysql%20project.json)

Retrieves the account data once the caller is verified.

Webhook → query → respond

## Setup
Import the three JSON files into n8n
Create a MySQL credential and assign it to each SQL node
Create an SMTP credential and assign it to the email node
Run schema.sql against your database to create the required tables
Publish each workflow and copy its production webhook URL
Register those URLs as tools in your ElevenLabs agent

Credentials are not included in the workflow exports — you will need to create your own.

## Phone number normalisation

Callers give numbers in inconsistent formats, and speech-to-text adds more variation. A number may arrive as +2348122005927, 08122005927, or with a leading space where a + was decoded from a URL query string.

Every lookup therefore strips non-numeric characters from both the stored value and the incoming value, then compares the final ten digits. Exact string matching against a phone column will fail unpredictably.

## Notes

Each workflow returns an explicit status rather than an empty response. This matters more than it sounds: in n8n, a query returning zero rows causes all downstream nodes to be skipped, and the execution is still marked successful. Without an explicit status, a failed lookup is indistinguishable from a successful one, and the agent will report success to the caller either way.

## Stack
ElevenLabs — conversational agent and telephony
n8n — workflow automation
MySQL — customer records and one-time codes
Gemini 2.5 Flash — conversation reasoning
SMTP — code delivery
