# Credit Card Default SQL Analysis (MySQL)

**Summary:** I analyzed 30,000 credit card accounts in MySQL to see which
account behaviours are associated with default, then evaluated my findings to provide insights and propose strategic steps towards better prediction of default risk. This was a guided learning project with AI assistance (Anthropic's Claude), which helped plan the analysis, write and explain the SQL queries, and structure this README. I ran every query in MySQL, checked the results, and wrote the interpretation and hypotheses myself.

## Why this project
Through this project, I'm building familiarity with navigating SQL, and understanding queries and functions. As someone who is curious about credit strategy and risk assessment, I chose this dataset as a self-learning project to further my knowledge within this sector, and understand the core problems, and patterns of problem-solving that encapsulate analyst work in this field. 

## Business questions
1. What is the portfolio's overall default rate?
2. How does default vary by different credit limit bands, repayment status, and utilization rates?
3. Can any particular segments or trends be identified and further scrutinized based on this dataset to improve credit default rates and reduce risk?

## Data
- Source: Default of Credit Card Clients, UCI Machine Learning Repository
  (Yeh & Lien, 2009), downloaded from Kaggle. Not included in this repo.
- 30,000 credit card clients in Taiwan, April-September 2005. Amounts are
  in New Taiwan dollars (NT$). Target: defaulted next month (1 = yes).
- The analysis uses the September 2005 repayment status and bill (the most recent month) and the
  next-month default flag. Earlier months (April-August) were not analyzed.

## Tools
MySQL, MySQL Workbench, Claude

## Approach
1. Imported the CSV into a raw table, then built a clean table (`clients`)
   with clearer column names.
2. Validate the data, by querying to find duplicates, missing values, and odd codes.
3. Used SQL functions such as aggregation, group by, and case when functions. 


## Data notes
- 590 clients (about 2%) had negative September bills, likely credit balances. They remain in the analysis, with their balance treated as zero when calculating utilization.
- Repayment status values -2 and 0 aren't defined in the dataset
  documentation. I kept them separate and labelled them with their common
  interpretations, not official definitions. 
- MARRIAGE has an undocumented code 0 (54 clients). Marital status, along with sex and education
  categories were left out of the analysis left out because lenders generally avoid using
  characteristics like these in credit decisions

## Key findings
- Overall default rate: 22.1% (6,636 of 30,000).
- When evaluating repayment status, clients paying on time or revolving had a 12.8-16.8% default rate, compared to much higher default rates of 33.9% for clients paying one month late, 69.1% for two months late payments, and 71.9% at three or more. 
- When evaluating repayment status, clients that had had late payments of one or more months represented 22.7% of all clients, and accounted for 51.7% of total defaults.
- When evaluating default rates per different credit limit bands, default rates decrease as credit limit rises, from 36.1% for the under 50k band to 12% for the 400k+ band.
- Utilization was a weaker signal than repayment status, as default rose from 16.9% (under 30% utilization) to about 26-28% at 60%+, though zero-balance accounts also defaulted at 24.7%, which I couldn't explain.
- Open questions: zero-balance accounts defaulted at 24.7%, higher than accounts using under 30% of their limit (16.9%), and status -1 (paid on time) defaulted more than status 0 (16.8% vs 12.8%). I couldn't explain either from this data.

## Segment view
| Repayment tier | Utilization | Clients | % of clients | Default rate | Avg limit (NT$) |
|---|---|---|---|---|---|
| Low risk | under 30% | 11,852 | 39.5% | 13.5% | 224,279 |
| Low risk | 30-59% | 3,327 | 11.1% | 10.9% | 158,497 |
| Low risk | 60%+ | 8,003 | 26.7% | 15.5% | 119,261 |
| 1 month late | under 30% | 2,233 | 7.4% | 27.9% | 191,885 |
| 1 month late | 30-59% | 408 | 1.4% | 48.5% | 86,740 |
| 1 month late | 60%+ | 1,047 | 3.5% | 41.3% | 81,079 |
| 2+ months late | under 30% | 707 | 2.4% | 68.0% | 138,608 |
| 2+ months late | 30-59% | 572 | 1.9% | 76.6% | 105,927 |
| 2+ months late | 60%+ | 1,851 | 6.2% | 68.0% | 95,764 |

Notes: "Low risk" = on time, revolving or no use in September. Utilization = September bill ÷ credit limit, with negative bills set to 0. Default stayed 10.9-15.5% across usage levels in the low-risk tier and 68-77% in the 2+ months late tier. The one-month-late tier varied (27.9-48.5%), but its middle group was a small group of only 408 clients. 

## Hypotheses for a credit team 
- Since almost 50% of clients who defaulted were not late as of September, this could provide impetus to investigate earlier screening of clients for default risk without them having late payments.
- Disparity in default rates across different credit limit bands could be interpreted as the financial institution having more guardrails and screening measures for higher credit value clients, leading to less default risk within the upper bands comparatively.
- Since default risks did not show a distinctive trend across different utilization bands, further investigation could be done, by further segmenting utilization bands, collecting further data, or cross-examining it against other factors to show more insights. 

## Limitations
- This is a limited dataset pertaining to one national market, a short window, and data from 2005. This dataset therefore cannot be applied to make generalizations about global banking markets and credit behavior, nor can it confirm causality with the patterns and trends that have been identified through analysis.

## Next Steps
- Use all six months of data to extract further insights. 

## Files
All scripts are in the `sql/` folder and are meant to be run in order.

- `01_setup_import.sql`: creates the `credit_card_default` database and records how the CSV was imported into a raw table (`credit_raw`), with row-count and column checks to confirm the import.
- `02_clean_and_checks.sql`: builds the clean `clients` table with clearer column names (`CREATE TABLE ... AS SELECT`), then validates the data: duplicates, missing values, default split, undocumented codes and negative bills.
- `03_analysis.sql`: the analysis queries: portfolio snapshot, default rate by credit limit band, repayment status, and utilization, how concentrated defaults are among late payers, and the segment view (repayment tier × utilization, built with a CTE).
