ALTER TABLE public.anomalies
DROP CONSTRAINT anomalies_anomaly_type_check;

ALTER TABLE public.anomalies
ADD CONSTRAINT anomalies_anomaly_type_check
CHECK (
    anomaly_type = ANY (
        ARRAY[
            'PRICE_VARIANCE'::text,
            'QUANTITY_VARIANCE'::text,
            'DUPLICATE_INVOICE'::text,
            'MISSING_PO'::text,
            'UNKNOWN_PRODUCT'::text,
            'UNEXPECTED_CHARGE'::text,
            'PRODUCT_MATCH_REVIEW'::text
        ]
    )
);