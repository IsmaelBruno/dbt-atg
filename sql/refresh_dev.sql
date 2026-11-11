BEGIN;

CREATE SCHEMA IF NOT EXISTS dev;

DROP TABLE IF EXISTS dev.tank_measurements__next;

CREATE TABLE dev.tank_measurements__next AS
SELECT *
FROM public.tank_measurements;

ALTER TABLE dev.tank_measurements__next
  ADD CONSTRAINT tank_measurements__next_pkey PRIMARY KEY (id);

CREATE INDEX tank_measurements__next_depot_tank_report_idx
  ON dev.tank_measurements__next (depot_code, tank_id_raw, report_time, id);

ANALYZE dev.tank_measurements__next;

DO $$
BEGIN
  IF to_regclass('dev.tank_measurements') IS NOT NULL THEN
    ALTER TABLE dev.tank_measurements RENAME TO tank_measurements__old;
  END IF;

  ALTER TABLE dev.tank_measurements__next RENAME TO tank_measurements;

  CREATE OR REPLACE VIEW dev.v_tank_measurements AS
    SELECT *
    FROM dev.tank_measurements;

  IF to_regclass('dev.tank_measurements__old') IS NOT NULL THEN
    DROP TABLE dev.tank_measurements__old;
  END IF;
END
$$;

ALTER TABLE dev.tank_measurements
  RENAME CONSTRAINT tank_measurements__next_pkey TO tank_measurements_pkey;

ALTER INDEX dev.tank_measurements__next_depot_tank_report_idx
  RENAME TO tank_measurements_depot_tank_report_idx;

COMMIT;
