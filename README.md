# ProcureGuard AI

**AI-Powered Procurement Automation, Invoice Intelligence & Price Leakage Detection**

ProcureGuard AI is a multi-organization procurement automation system built with **n8n, Supabase PostgreSQL, Gmail, and AI**.

It automates supplier invoice ingestion, detects procurement anomalies, manages human approvals, generates supplier dispute drafts, and delivers automated procurement reports.

The project demonstrates how AI automation, database engineering, and human-in-the-loop workflows can be combined to improve procurement operations.

---

## Key Features

- **AI Invoice Processing:** Extract structured invoice data from supplier PDF attachments.
- **Price Leakage Detection:** Identify differences between expected and invoiced prices.
- **Anomaly Detection:** Detect pricing, quantity, duplicate invoice, missing purchase order, and product-matching issues.
- **Human-in-the-Loop Approvals:** Review product matches, anomalies, supplier disputes, and outgoing emails.
- **AI Supplier Dispute Drafts:** Generate supplier communication drafts based on reviewed procurement discrepancies.
- **Email Safety Controls:** Require approval and validate recipients before sending supplier emails.
- **Automated Procurement Reports:** Generate organization-specific summaries of invoice activity, anomalies, and operational issues.
- **Error Monitoring and Recovery:** Log workflow failures, escalate critical errors, and support controlled email recovery.
- **Multi-Tenant Architecture:** Support multiple organizations with database-backed access controls.

## Technology Stack

| Technology | Purpose |
|---|---|
| n8n | Automation and workflow orchestration |
| Supabase | PostgreSQL database and access controls |
| PostgreSQL / SQL | Business rules, constraints, anomaly detection, reporting |
| Gmail | Invoice ingestion and approved email delivery |
| AI models | Invoice extraction, report summaries, supplier dispute drafting |
| GitHub | Version control and technical documentation |

## System Architecture

```text
Supplier Invoice Email
         |
         v
Gmail Trigger
         |
         v
PDF Processing + Duplicate Detection
         |
         v
AI Invoice Extraction
         |
         v
Supplier / Purchase Order / Product Matching
         |
         v
Supabase PostgreSQL
         |
         v
Procurement Anomaly Detection
         |
         v
Human Review & Approval
         |
         v
AI Supplier Dispute Draft
         |
         v
Supplier Email Approval
         |
         v
Recipient Safety Check
         |
         v
Approved Supplier Email
```

Supporting workflows handle daily procurement reporting, centralized error monitoring, and supplier email recovery.

For details, see [System Architecture](docs/architecture.md).

## Eight n8n Workflows

| Workflow | Purpose |
|---|---|
| Invoice Processing | Ingest invoices, extract data, match records, and detect anomalies |
| Product Match Approval | Resolve uncertain product matches through human review |
| Anomaly Review | Confirm, dismiss, or resolve procurement anomalies |
| Supplier Dispute Approval | Approve dispute actions and generate AI email drafts |
| Supplier Email Review | Approve and safely send supplier communication |
| Supplier Email Recovery | Handle controlled email retry and resolution operations |
| Daily Procurement Report | Generate organization-specific procurement summaries |
| Global Error Handler | Centralize error logging and critical notifications |

All eight sanitized workflow exports are available in the [`n8n/`](n8n/) directory.

Read the [Workflow Documentation](docs/workflows.md) for more information.

## Database Design

The Supabase PostgreSQL database contains **18 tables**, including:

- Organizations and organization members
- Suppliers, products, and supplier-product agreements
- Product aliases and price history
- Purchase orders and purchase order items
- Invoices and invoice items
- Procurement anomalies and approvals
- Supplier dispute drafts
- Audit logs and processing errors
- Organization report settings
- System settings

The project also includes three dashboard views:

- `organization_dashboard_summary`
- `supplier_risk_summary`
- `anomaly_detail_view`

Database migration files are available in [`supabase/migrations/`](supabase/migrations/).

## Security and Reliability

ProcureGuard AI includes several security and operational safeguards:

- PostgreSQL Row Level Security (RLS)
- Organization membership and role-based policies
- Human approval before sensitive actions
- Supplier recipient safety checks
- Database-backed workflow state
- Duplicate detection and report-delivery controls
- Centralized error logging
- Controlled email recovery
- Security-invoker dashboard views
- Sanitized public n8n workflow exports

The public repository does not intentionally include production credentials or private procurement data.

See [Security and Access Control](docs/security.md).

## Testing and Validation

Development testing covered:

- PostgreSQL constraints and relationships
- Multi-organization data isolation
- RLS and role-based permissions
- Invoice ingestion and anomaly detection
- Human approval workflows
- Supplier dispute draft generation
- Email recipient safety checks
- Daily reporting and duplicate-delivery controls
- Error handling and recovery

### Example: Price Variance Detection

A controlled invoice test used the following values:

| Metric | Value |
|---|---:|
| Product | Fine Wheat Flour 25kg |
| Quantity | 20 |
| Expected unit price | PKR 2,400 |
| Invoiced unit price | PKR 2,700 |
| Price variance | 12.5% |
| Estimated financial impact | PKR 6,000 |

The workflow detected a HIGH-severity price anomaly and routed the invoice for review.

**Validation note:** The additional public migration files have not yet been verified together through a fresh database reset. Further environment-specific deployment testing is required.

Read [Testing and Validation](docs/testing.md).

## Repository Structure

```text
procureguard-ai/
├── README.md
├── n8n/
│   ├── README.md
│   └── 8 sanitized workflow JSON files
├── supabase/
│   ├── README.md
│   └── migrations/
│       └── 24 SQL migration files
└── docs/
    ├── README.md
    ├── architecture.md
    ├── workflows.md
    ├── security.md
    └── testing.md
```

## Getting Started

This repository provides a reference implementation and sanitized workflow templates. It is not a one-click production deployment.

1. Clone the repository.
2. Set up a development Supabase project.
3. Review and apply the database migrations in timestamp order in a safe development environment.
4. Import the sanitized n8n workflow JSON files.
5. Configure PostgreSQL, Gmail, and AI credentials in n8n.
6. Configure organization-specific reporting and system notification settings.
7. Configure the Global Error Handler for the applicable workflows.
8. Review form access controls and email approval safeguards.
9. Test with sample procurement data and authorized test recipients before activating workflows.

**Important:** Do not apply the repository migrations blindly to an existing production database. Do not commit credentials, real invoice documents, or private supplier information.

## Documentation

- [System Architecture](docs/architecture.md)
- [n8n Workflow Documentation](docs/workflows.md)
- [Security and Access Control](docs/security.md)
- [Testing and Validation](docs/testing.md)
- [n8n Workflow Exports](n8n/)
- [Supabase Database](supabase/)

## Project Status

**Portfolio / Development Reference Implementation**

Core workflow development and controlled QA scenarios have been completed. Public repository packaging is in progress, and additional clean-install and deployment validation remains.

## Use Cases

ProcureGuard AI demonstrates automation patterns applicable to:

- Procurement and purchasing teams
- Supplier invoice reconciliation
- Accounts payable review
- Procurement cost monitoring
- Human-approved AI communication
- Multi-organization workflow automation

## License

No open-source license has been specified. All rights remain reserved unless a license is added.

---

**ProcureGuard AI — Turning supplier invoices into actionable procurement intelligence.**
