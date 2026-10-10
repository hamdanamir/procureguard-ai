-- ProcureGuard AI dashboard views
-- Reconstructed from exported live view definitions.
-- No production data or credentials included.
-- Apply only to a database where underlying tables already exist.

CREATE OR REPLACE VIEW public.anomaly_detail_view
WITH (security_invoker = true)
AS
SELECT a.organization_id,
    o.name AS organization_name,
    a.id AS anomaly_id,
    a.anomaly_type,
    a.severity,
    a.status AS anomaly_status,
    a.description AS anomaly_description,
    a.expected_value,
    a.actual_value,
    a.variance_amount,
    a.variance_percent,
    a.estimated_financial_impact,
    a.detected_at,
    a.reviewed_at,
    a.resolved_at,
    a.resolution_notes,
    a.supplier_id,
    s.supplier_code,
    s.supplier_name,
    a.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.currency,
    i.total AS invoice_total,
    i.processing_status AS invoice_processing_status,
    a.product_id,
    p.product_name,
    a.purchase_order_id,
    po.po_number,
    a.evidence,
    a.created_at,
    a.updated_at
   FROM anomalies a
     JOIN organizations o ON o.id = a.organization_id
     JOIN suppliers s ON s.id = a.supplier_id AND s.organization_id = a.organization_id
     JOIN invoices i ON i.id = a.invoice_id AND i.organization_id = a.organization_id
     LEFT JOIN products p ON p.id = a.product_id AND p.organization_id = a.organization_id
     LEFT JOIN purchase_orders po ON po.id = a.purchase_order_id AND po.organization_id = a.organization_id
  WHERE o.status = 'ACTIVE'::text;

CREATE OR REPLACE VIEW public.organization_dashboard_summary
WITH (security_invoker = true)
AS
WITH invoice_metrics AS (
         SELECT invoices.organization_id,
            count(*) AS total_invoices,
            count(*) FILTER (WHERE invoices.created_at >= (now() - '30 days'::interval)) AS invoices_last_30_days,
            count(*) FILTER (WHERE invoices.processing_status = 'REVIEW_REQUIRED'::text) AS invoices_review_required,
            count(*) FILTER (WHERE invoices.processing_status = 'FAILED'::text) AS invoices_failed
           FROM invoices
          GROUP BY invoices.organization_id
        ), anomaly_metrics AS (
         SELECT anomalies.organization_id,
            count(*) AS total_anomalies,
            count(*) FILTER (WHERE anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text])) AS active_anomalies,
            count(*) FILTER (WHERE (anomalies.severity = ANY (ARRAY['HIGH'::text, 'CRITICAL'::text])) AND (anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text]))) AS high_risk_anomalies,
            COALESCE(sum(anomalies.estimated_financial_impact) FILTER (WHERE anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text])), 0::numeric) AS estimated_financial_exposure
           FROM anomalies
          GROUP BY anomalies.organization_id
        ), approval_metrics AS (
         SELECT approvals.organization_id,
            count(*) FILTER (WHERE approvals.status = 'PENDING'::text) AS pending_approvals
           FROM approvals
          GROUP BY approvals.organization_id
        ), error_metrics AS (
         SELECT processing_errors.organization_id,
            count(*) FILTER (WHERE processing_errors.status = ANY (ARRAY['OPEN'::text, 'RETRYING'::text])) AS open_processing_errors
           FROM processing_errors
          WHERE processing_errors.organization_id IS NOT NULL
          GROUP BY processing_errors.organization_id
        )
 SELECT o.id AS organization_id,
    o.name AS organization_name,
    COALESCE(im.total_invoices, 0::bigint) AS total_invoices,
    COALESCE(im.invoices_last_30_days, 0::bigint) AS invoices_last_30_days,
    COALESCE(im.invoices_review_required, 0::bigint) AS invoices_review_required,
    COALESCE(im.invoices_failed, 0::bigint) AS invoices_failed,
    COALESCE(am.total_anomalies, 0::bigint) AS total_anomalies,
    COALESCE(am.active_anomalies, 0::bigint) AS active_anomalies,
    COALESCE(am.high_risk_anomalies, 0::bigint) AS high_risk_anomalies,
    COALESCE(am.estimated_financial_exposure, 0::numeric) AS estimated_financial_exposure,
    COALESCE(apm.pending_approvals, 0::bigint) AS pending_approvals,
    COALESCE(em.open_processing_errors, 0::bigint) AS open_processing_errors
   FROM organizations o
     LEFT JOIN invoice_metrics im ON im.organization_id = o.id
     LEFT JOIN anomaly_metrics am ON am.organization_id = o.id
     LEFT JOIN approval_metrics apm ON apm.organization_id = o.id
     LEFT JOIN error_metrics em ON em.organization_id = o.id
  WHERE o.status = 'ACTIVE'::text;

CREATE OR REPLACE VIEW public.supplier_risk_summary
WITH (security_invoker = true)
AS
WITH invoice_metrics AS (
         SELECT invoices.organization_id,
            invoices.supplier_id,
            count(*) AS total_invoices,
            count(*) FILTER (WHERE invoices.created_at >= (now() - '30 days'::interval)) AS invoices_last_30_days
           FROM invoices
          GROUP BY invoices.organization_id, invoices.supplier_id
        ), anomaly_metrics AS (
         SELECT anomalies.organization_id,
            anomalies.supplier_id,
            count(*) AS total_anomalies,
            count(*) FILTER (WHERE anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text])) AS active_anomalies,
            count(*) FILTER (WHERE (anomalies.severity = ANY (ARRAY['HIGH'::text, 'CRITICAL'::text])) AND (anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text]))) AS high_risk_anomalies,
            COALESCE(sum(anomalies.estimated_financial_impact) FILTER (WHERE anomalies.status = ANY (ARRAY['OPEN'::text, 'UNDER_REVIEW'::text, 'CONFIRMED'::text])), 0::numeric) AS estimated_financial_exposure,
            max(anomalies.detected_at) AS last_anomaly_at
           FROM anomalies
          GROUP BY anomalies.organization_id, anomalies.supplier_id
        )
 SELECT s.organization_id,
    o.name AS organization_name,
    s.id AS supplier_id,
    s.supplier_code,
    s.supplier_name,
    s.status AS supplier_status,
    COALESCE(im.total_invoices, 0::bigint) AS total_invoices,
    COALESCE(im.invoices_last_30_days, 0::bigint) AS invoices_last_30_days,
    COALESCE(am.total_anomalies, 0::bigint) AS total_anomalies,
    COALESCE(am.active_anomalies, 0::bigint) AS active_anomalies,
    COALESCE(am.high_risk_anomalies, 0::bigint) AS high_risk_anomalies,
    COALESCE(am.estimated_financial_exposure, 0::numeric) AS estimated_financial_exposure,
    am.last_anomaly_at
   FROM suppliers s
     JOIN organizations o ON o.id = s.organization_id
     LEFT JOIN invoice_metrics im ON im.organization_id = s.organization_id AND im.supplier_id = s.id
     LEFT JOIN anomaly_metrics am ON am.organization_id = s.organization_id AND am.supplier_id = s.id
  WHERE o.status = 'ACTIVE'::text;
