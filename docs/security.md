# ProcureGuard AI — Security and Access Control

## Overview

ProcureGuard AI uses database access controls, human approval workflows, recipient validation, and centralized error logging to reduce security and operational risks in procurement automation.

This document describes the implemented security architecture and recommended deployment safeguards.

## 1. Multi-Tenant Data Isolation

ProcureGuard AI supports multiple organizations within a shared PostgreSQL database.

Business records are associated with an `organization_id` to support organization-specific access and processing.

The database uses PostgreSQL Row Level Security (RLS) to restrict access according to organization membership and authorized roles.

Key authorization helpers include:

- `is_organization_member(organization_id)`
- `has_organization_role(organization_id, allowed_roles)`

RLS policies must be reviewed whenever new tables or application roles are introduced.

## 2. Role-Based Authorization

The organization reporting configuration uses the following access model:

| Operation | Authorized Roles |
|---|---|
| Read | Organization members |
| Create | OWNER, ADMIN, PROCUREMENT_MANAGER |
| Update | OWNER, ADMIN, PROCUREMENT_MANAGER |
| Delete | OWNER, ADMIN |

These rules are enforced through PostgreSQL RLS policies for authenticated application users.

## 3. Protected System Configuration

The `system_settings` table stores platform-level configuration such as notification destinations.

It has RLS enabled without ordinary authenticated-user access policies.

Trusted backend access is required to manage this configuration.

Configuration values must not be confused with secrets: passwords, access tokens, and API keys should be stored in an appropriate secrets manager or credential store.

## 4. Supplier Dispute Draft Protection

The `supplier_dispute_drafts` table has RLS enabled with no ordinary application-user policies in the verified database configuration.

Supplier dispute records are handled through trusted workflow database access.

Privileged database connections must be protected because they may bypass RLS.

## 5. n8n Credential Security

The system integrates with Gmail, PostgreSQL, and AI services.

Credentials must be configured using n8n's credential management features or a supported secret-management mechanism.

Security practices include:

- Never committing database passwords or API keys to GitHub.
- Removing credential bindings from public workflow exports.
- Restricting access to production n8n instances.
- Applying least-privilege access wherever possible.
- Rotating credentials if accidental exposure is detected.
- Separating development and production configurations.

## 6. Human Approval Safeguards

Sensitive procurement decisions are routed through human review workflows.

These include:

- Product match review
- Procurement anomaly review
- Supplier dispute approval
- Supplier email approval

Approval records provide a controlled decision state before downstream operations proceed.

A submitted review form should not be treated as proof of identity by itself. Production deployments must enforce reviewer authentication and authorization at an appropriate access-control layer.

## 7. Supplier Email Safety

Supplier email delivery is controlled through a separate review workflow.

Safeguards include:

- Human approval before sending
- Recipient validation
- Blocking test-domain recipients
- Database-backed email state
- Controlled claiming before delivery
- Failure handling and recovery

Email sending should be tested with authorized, non-production recipients before production activation.

## 8. Error Handling and Auditability

The system records operational errors in `processing_errors`.

Audit records provide traceability for important procurement and approval activities.

The Global Error Handler centralizes failure logging and supports critical alert notifications using protected system configuration.

Logs should not expose passwords, authentication tokens, or unnecessary personal information.

## 9. Dashboard View Security

The following PostgreSQL views use `security_invoker = true`:

- `organization_dashboard_summary`
- `supplier_risk_summary`
- `anomaly_detail_view`

This setting causes underlying table permissions and RLS policies to be evaluated using the querying user's privileges.

## 10. Public Repository Security

The GitHub repository contains sanitized workflow exports, database migrations, and documentation.

The public repository must not contain:

- Production credentials
- API keys or OAuth tokens
- Real supplier invoice documents
- Private customer information
- Production database connection strings
- Organization-specific configuration records

Before deployment, administrators must review credentials, permissions, workflow triggers, recipient settings, and database access controls.

## Security Limitations

RLS does not automatically restrict privileged database roles that bypass it.

Public workflow templates do not provide authentication or authorization automatically.

Production readiness requires environment-specific access controls, secure deployment configuration, credential management, and ongoing monitoring.
