-- Project: Credit card default analysis
-- File: 01_setup_import.sql
-- Data: UCI Default of Credit Card Clients (Yeh & Lien, 2009), Taiwan, Apr-Sep 2005
-- Note: table credit_raw was imported with the Workbench Table Data Import Wizard
use credit_card_default;
select count(*) from credit_raw;
select * from credit_raw limit 10;
describe credit_raw;