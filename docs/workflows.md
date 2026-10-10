# ProcureGuard AI — n8n Workflow Documentation

## Overview

ProcureGuard AI uses eight interconnected n8n workflows to automate procurement invoice processing, anomaly detection, human approvals, supplier communication, reporting, and operational recovery.

The system combines AI-assisted extraction with PostgreSQL-based business rules and human decision-making.

## Workflow 1 — Invoice Processing

**Workflow:** `ProcureGuard AI - Invoice Processing`

**Trigger:** Gmail Trigger

**Purpose:** Automatically ingest supplier invoices and identify procurement discrepancies.

### Processing Flow

1. Monitor the configured Gmail invoice label.
2. Retrieve incoming email attachments.
3. Generate a document hash for duplicate detection.
4. Extract invoice data using AI.
5. Identify the supplier and associated purchase order.
6. Store invoice and invoice-item records.
7. Match invoice products against the product catalog.
8. Detect pricing, quantity, and other procurement anomalies.
9. Update the invoice processing status.

**Outputs:** Invoices, invoice items, anomalies, and processing status updates.

## Workflow 2 — Product Match Approval

**Workflow:** `ProcureGuard AI - Product Match Approval`

**Trigger:** n8n Form Trigger

**Purpose:** Allow human reviewers to resolve uncertain product matches.

### Processing Flow

1. Receive a product-match review submission.
2. Validate the requested decision.
3. Apply the authorized product-match decision.
4. Update the relevant procurement records.
5. Record the review outcome.

**Outputs:** Reviewed product matches and updated processing records.

## Workflow 3 — Anomaly Review

**Workflow:** `ProcureGuard AI - Anomaly Review`

**Trigger:** n8n Form Trigger

**Purpose:** Support human review of detected procurement anomalies.

### Processing Flow

1. Receive a review request.
2. Validate the anomaly and submitted decision.
3. Apply the CONFIRM, DISMISS, or RESOLVE decision.
4. Record an audit event.
5. Reevaluate the related invoice status.
6. Initiate supplier dispute approval when applicable.

**Outputs:** Updated anomalies, audit logs, and dispute approval requests.

## Workflow 4 — Supplier Dispute Approval

**Workflow:** `ProcureGuard AI - Supplier Dispute Approval`

**Trigger:** n8n Form Trigger

**Purpose:** Control the generation of supplier dispute communications.

### Processing Flow

1. Receive an approval decision.
2. Validate the associated procurement anomaly and approval record.
3. Process the APPROVE or REJECT decision.
4. Generate a supplier dispute email draft using AI when approved.
5. Save the draft in PostgreSQL.
6. Create or reuse the supplier email approval request.

**Outputs:** Approval decisions, supplier dispute drafts, and email approval requests.

## Workflow 5 — Supplier Email Review

**Workflow:** `ProcureGuard AI - Supplier Email Review`

**Trigger:** n8n Form Trigger

**Purpose:** Prevent unapproved or unsafe supplier emails from being sent.

### Processing Flow

1. Receive a human email approval decision.
2. Validate the draft and approval state.
3. Check the recipient and sending conditions.
4. Block test-domain or otherwise unsafe recipients.
5. Claim an eligible draft for sending.
6. Send the approved email through Gmail.
7. Record the result or failure.

**Outputs:** Sent or blocked email decisions, status updates, and operational records.

## Workflow 6 — Supplier Email Recovery

**Workflow:** `ProcureGuard AI - Supplier Email Recovery`

**Trigger:** n8n Form Trigger

**Purpose:** Provide controlled recovery of supplier email operations.

### Processing Flow

1. Receive a recovery request.
2. Validate the target draft and its current state.
3. Verify the requested RETRY or RESOLVE operation.
4. Reject inconsistent or unsafe recovery attempts.
5. Apply the permitted recovery action.
6. Record the recovery outcome.

**Outputs:** Updated email recovery state and related operational records.

## Workflow 7 — Daily Procurement Report

**Workflow:** `ProcureGuard AI - Daily Procurement Report`

**Trigger:** Schedule Trigger

**Purpose:** Generate organization-specific procurement summaries.

### Processing Flow

1. Run on an hourly schedule.
2. Load organization reporting preferences from PostgreSQL.
3. Determine which organizations are due for a report.
4. Retrieve invoice, anomaly, approval, and error metrics.
5. Generate an AI-assisted procurement summary.
6. Build the report email.
7. Check for duplicate delivery.
8. Send eligible reports through Gmail.

**Outputs:** Procurement report emails and delivery records.

## Workflow 8 — Global Error Handler

**Workflow:** `ProcureGuard AI - Global Error Handler`

**Trigger:** Error Trigger

**Purpose:** Centralize workflow error tracking and critical notifications.

### Processing Flow

1. Receive an n8n workflow error event.
2. Normalize the error details.
3. Save the error to `processing_errors`.
4. Determine whether critical escalation is required.
5. Load the configured system alert recipient.
6. Send a critical notification when appropriate.

**Outputs:** Error records and critical alert notifications.

## Workflow Relationships

```text
Invoice Processing
       |
       +--> Product Match Approval
       |
       +--> Anomaly Review
                  |
                  v
          Supplier Dispute Approval
                  |
                  v
          Supplier Email Review
                  |
                  +--> Approved Email Delivery
                  |
                  +--> Supplier Email Recovery

Daily Procurement Report
       |
       +--> Organization Reports

Global Error Handler
       |
       +--> Error Logging and Critical Alerts
```

These relationships describe the business process. Individual workflows may be initiated independently through their configured triggers and review forms.

## Deployment and Configuration

Before importing and activating these workflows:

1. Configure the required Gmail, PostgreSQL, and AI credentials in n8n.
2. Apply the required Supabase database schema.
3. Configure organization-specific report recipients and reporting preferences.
4. Configure the system alert recipient in the protected database settings.
5. Verify the form triggers and access restrictions.
6. Configure the Global Error Handler for the applicable workflows.
7. Test using non-production invoice data and safe recipient addresses.
8. Activate the workflows only after validating the environment.

The public workflow JSON files are sanitized templates. They are not intended to run without environment-specific configuration.

## Operational Safeguards

- Human approval before sensitive supplier communications
- Duplicate invoice and report-delivery controls
- Recipient safety checks
- Database-backed workflow state
- Controlled recovery actions
- Centralized error logging
- Organization-aware data access
- Separation of public workflow definitions from private credentials
