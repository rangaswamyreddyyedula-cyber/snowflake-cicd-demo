-- =====================================================================
-- 02 - Dummy data for the demo (all names are fictional)
-- Re-runnable: each table is emptied, then reloaded.
-- The data is deliberately a little "messy" (extra spaces, lower case,
-- one duplicate row) so the SILVER step has something to clean.
-- =====================================================================

TRUNCATE TABLE IF EXISTS BRONZE.EFRONT_FUNDS_RAW;
TRUNCATE TABLE IF EXISTS BRONZE.EFRONT_INVESTMENTS_RAW;
TRUNCATE TABLE IF EXISTS BRONZE.CHRONOGRAPH_VALUATIONS_RAW;

INSERT INTO BRONZE.EFRONT_FUNDS_RAW
    (FUND_ID, FUND_NAME, STRATEGY, VINTAGE_YEAR, CURRENCY, COMMITTED_CAPITAL, SOURCE_SYSTEM)
VALUES
    ('F001', 'Demo Buyout Fund I',          'Buyout',         2018, 'GBP', 1500000000, 'EFRONT'),
    ('F002', '  Demo Buyout Fund II',       'buyout',         2021, 'gbp', 2500000000, 'EFRONT'),
    ('F003', 'Demo Infrastructure Fund I',  'Infrastructure', 2019, 'EUR', 1200000000, 'EFRONT'),
    ('F004', 'Demo Growth Fund I ',         'growth',         2022, 'USD',  800000000, 'EFRONT');

INSERT INTO BRONZE.EFRONT_INVESTMENTS_RAW
    (INVESTMENT_ID, FUND_ID, COMPANY_NAME, SECTOR, COUNTRY_CODE, INVESTMENT_DATE, INVESTED_AMOUNT, STATUS, SOURCE_SYSTEM)
VALUES
    ('I001', 'F001', 'Alder Health Services',  'Healthcare',   'GB',  '2018-06-15', 120000000, 'Active',   'EFRONT'),
    ('I002', 'F001', 'Brightwater Utilities',  'Utilities',    'gb',  '2019-02-01',  95000000, 'Realised', 'EFRONT'),
    ('I003', 'F001', 'Cobalt Retail Group',    'Consumer',     'NL',  '2019-09-30',  80000000, 'Active',   'EFRONT'),
    ('I004', 'F002', 'Driftwood Software',     'technology ',  'DE',  '2021-11-12', 150000000, 'Active',   'EFRONT'),
    ('I004', 'F002', 'Driftwood Software',     'technology ',  'DE',  '2021-11-12', 150000000, 'Active',   'EFRONT'),
    ('I005', 'F002', 'Elmstone Logistics',     'Industrials',  ' FR', '2022-04-20', 110000000, 'active',   'EFRONT'),
    ('I006', 'F003', 'Fernhill Wind Farms',    'Energy',       'DK',  '2019-12-05', 200000000, 'Active',   'EFRONT'),
    ('I007', 'F003', 'Granite Toll Roads',     'Transport',    'ES',  '2020-07-18', 175000000, 'Active',   'EFRONT'),
    ('I008', 'F003', 'Harbourline Ports',      'transport',    'GB',  '2021-03-22', 140000000, 'Active',   'EFRONT'),
    ('I009', 'F004', 'Ironleaf Analytics',     'Technology',   'US',  '2022-08-09',  60000000, 'Active',   'EFRONT'),
    ('I010', 'F004', 'Juniper Care Homes',     'Healthcare',   'us',  '2023-01-25',  45000000, 'Active',   'EFRONT');

INSERT INTO BRONZE.CHRONOGRAPH_VALUATIONS_RAW
    (VALUATION_ID, INVESTMENT_ID, VALUATION_DATE, FAIR_VALUE, CURRENCY, SOURCE_SYSTEM)
VALUES
    ('V001', 'I001', '2025-12-31', 210000000, 'GBP', 'CHRONOGRAPH'),
    ('V002', 'I001', '2026-06-30', 228000000, 'GBP', 'CHRONOGRAPH'),
    ('V003', 'I002', '2025-12-31', 190000000, 'GBP', 'CHRONOGRAPH'),
    ('V004', 'I002', '2026-06-30', 205000000, 'gbp', 'CHRONOGRAPH'),
    ('V005', 'I003', '2025-12-31',  72000000, 'GBP', 'CHRONOGRAPH'),
    ('V006', 'I003', '2026-06-30',  70000000, 'GBP', 'CHRONOGRAPH'),
    ('V007', 'I004', '2025-12-31', 180000000, 'GBP', 'CHRONOGRAPH'),
    ('V008', 'I004', '2026-06-30', 195000000, 'GBP', 'CHRONOGRAPH'),
    ('V009', 'I005', '2025-12-31', 118000000, 'GBP', 'CHRONOGRAPH'),
    ('V010', 'I005', '2026-06-30', 126000000, 'GBP', 'CHRONOGRAPH'),
    ('V011', 'I006', '2025-12-31', 260000000, 'EUR', 'CHRONOGRAPH'),
    ('V012', 'I006', '2026-06-30', 272000000, 'EUR', 'CHRONOGRAPH'),
    ('V013', 'I007', '2025-12-31', 205000000, 'EUR', 'CHRONOGRAPH'),
    ('V014', 'I007', '2026-06-30', 214000000, 'eur', 'CHRONOGRAPH'),
    ('V015', 'I008', '2025-12-31', 150000000, 'EUR', 'CHRONOGRAPH'),
    ('V016', 'I008', '2026-06-30', 163000000, 'EUR', 'CHRONOGRAPH'),
    ('V017', 'I009', '2025-12-31',  66000000, 'USD', 'CHRONOGRAPH'),
    ('V018', 'I009', '2026-06-30',  75000000, 'USD', 'CHRONOGRAPH'),
    ('V019', 'I010', '2025-12-31',  44000000, 'USD', 'CHRONOGRAPH'),
    ('V020', 'I010', '2026-06-30',  48000000, 'USD', 'CHRONOGRAPH');
