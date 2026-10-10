-- ProcureGuard AI: supplier dispute email drafts.
-- Schema-only migration; no production records or credentials.
-- Apply only to a database where this table does not already exist.
CREATE TABLE public.supplier_dispute_drafts (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL,
    approval_id uuid NOT NULL,
    anomaly_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    supplier_id uuid NOT NULL,
    recipient_email text NOT NULL,
    email_subject text NOT NULL,
    email_body text NOT NULL,
    status text NOT NULL DEFAULT 'DRAFT',
    generated_by text NOT NULL DEFAULT 'AI',
    reviewed_by text,
    reviewed_at timestamptz,
    sent_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    email_approval_id uuid,
    CONSTRAINT supplier_dispute_drafts_pkey PRIMARY KEY (id),
    CONSTRAINT supplier_dispute_drafts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id),
    CONSTRAINT supplier_dispute_drafts_approval_id_fkey FOREIGN KEY (approval_id) REFERENCES public.approvals(id),
    CONSTRAINT supplier_dispute_drafts_anomaly_id_fkey FOREIGN KEY (anomaly_id) REFERENCES public.anomalies(id),
    CONSTRAINT supplier_dispute_drafts_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id),
    CONSTRAINT supplier_dispute_drafts_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id),
    CONSTRAINT supplier_dispute_drafts_email_approval_id_fkey FOREIGN KEY (email_approval_id) REFERENCES public.approvals(id),
    CONSTRAINT supplier_dispute_drafts_recipient_not_blank CHECK (btrim(recipient_email) <> ''),
    CONSTRAINT supplier_dispute_drafts_subject_not_blank CHECK (btrim(email_subject) <> ''),
    CONSTRAINT supplier_dispute_drafts_body_not_blank CHECK (btrim(email_body) <> ''),
    CONSTRAINT supplier_dispute_drafts_status_check CHECK (status IN ('DRAFT', 'PENDING_REVIEW', 'APPROVED', 'SENDING', 'REJECTED', 'SENT', 'FAILED'))
);

ALTER TABLE public.supplier_dispute_drafts ENABLE ROW LEVEL SECURITY;
-- No RLS policies exist on this table in the verified source database.
-- Privileged backend database access is configured separately.
