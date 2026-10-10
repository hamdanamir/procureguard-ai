# ProcureGuard AI — System Architecture

## Overview

ProcureGuard AI is an AI-powered procurement automation system built using n8n, Supabase PostgreSQL, Gmail, and AI-powered invoice extraction.

The system processes supplier invoices, identifies potential procurement discrepancies, supports human approval workflows, and produces automated procurement reports.

## Architecture Diagram

```text
Supplier Invoice Email
         |
         v
Gmail Trigger (n8n)
         |
         v
PDF Download & Duplicate Check
         |
         v
AI Invoice Data Extraction
         |
         v
Supplier & Purchase Order Matching
         |
         v
Supabase PostgreSQL
         |
         v
Product Matching & Anomaly Detection
         |
         v
Human Review and Approval
         |
         v
Supplier Dispute Draft Generation
         |
         v
Supplier Email Approval & Safety Checks
         |
         v
Approved Supplier Communication
```

## Core Components

### 1. Invoice Processing

The invoice processing workflow monitors a designated Gmail label, downloads invoice attachments, extracts structured invoice information using AI, and stores invoice records in PostgreSQL.

It supports duplicate detection, supplier matching, purchase order matching, and product matching.

### 2. Anomaly Detection

ProcureGuard evaluates procurement data to identify discrepancies such as price variances, quantity variances, missing purchase orders, unknown products, and potential duplicate invoices.

Detected anomalies are stored for review with supporting evidence and estimated financial impact where applicable.

### 3. Human Approval System

The system provides separate approval workflows for product matching, anomaly reviews, supplier disputes, and supplier email communication.

Sensitive actions require appropriate review before proceeding.

### 4. Supplier Communication

AI generates supplier dispute email drafts based on approved anomaly findings.

A separate human approval process and recipient safety checks control whether an email can be sent.

### 5. Automated Reporting

A scheduled workflow generates organization-specific procurement reports using stored report preferences.

Reports summarize invoice activity, anomalies, approvals, and processing errors.

### 6. Error Handling and Recovery

A centralized error handler records workflow failures in the processing_errors table and supports critical alert notifications.

A separate supplier email recovery workflow supports controlled recovery of failed email operations.

## Database Architecture

The PostgreSQL database contains 18 tables covering:

- Organizations and membership
- Suppliers and products
- Supplier-product agreements
- Purchase orders and invoices
- Invoice line items and price history
- Procurement anomalies
- Human approvals
- Supplier dispute drafts
- Audit logs and processing errors
- Organization reporting configuration
- Platform configuration

## Security Architecture

- Row Level Security for tenant-aware database access
- Role-based authorization for organization operations
- Human approval gates for supplier communications
- Credentials managed outside public workflow exports
- Audit logging for operational traceability
- Controlled recovery and error handling
- Security-invoker dashboard views

## Technology Stack

| Technology | Purpose |
|---|---|
| n8n | Workflow orchestration |
| Supabase PostgreSQL | Data storage and business rules |
| Gmail | Invoice ingestion and approved communication |
| AI models | Invoice extraction and dispute drafting |
| SQL | Validation, anomaly analysis, and reporting |
| GitHub | Version control and technical documentation |

## Deployment Notes

The public repository contains sanitized workflow templates and database migrations.

Deployments require environment-specific configuration, authorized database access, n8n credentials, and appropriate Gmail and AI integrations.

Production credentials, real supplier data, and organization-specific email addresses must not be committed to the repository.
