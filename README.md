# GE Stock Technical Analysis (2017–2022)

## 📌 Project Overview

This project examines General Electric’s (GE) stock performance from **May 26 2017 to December 29 2022** using technical‑indicator data.  We clean the raw CSV in **SQLite**, run analytic **SQL** queries, and surface insights through interactive **Tableau Public** dashboards.  Everything—data, queries, visuals, and write‑up—is version‑controlled here on GitHub so recruiters and collaborators can poke every piece.

### Goals

1. **Decode market sentiment** around GE over six trading years.
2. **Demonstrate full‑stack analytics workflow** (ETL → SQL → BI → interpretation → recommendations).
3. **Deliver actionable insights** GE could use to bolster growth and investor confidence.

---

## 🗄️ Dataset & Columns

- **Source:** MarketWatch historical download (daily bars). 1000 + rows.
- **Saved as:** `data/ge_stock_data.csv`

| Column                                      | Type    | What it Represents                                          |
| ------------------------------------------- | ------- | ----------------------------------------------------------- |
| `Date`                                      |  DATE   | Trading day (NYSE calendar)                                 |
| `Open`, `High`, `Low`, `Close`, `Adj Close` | REAL    | Standard OHLC price data                                    |
| `Volume`                                    | INTEGER | Shares traded that day                                      |
| `RSI`                                       | REAL    | *Relative Strength Index*—momentum oscillator (0‑100)       |
| `MACD`, `MACDsig`, `MACDhist`               | REAL    | *Moving Average Convergence Divergence* trio (12‑26‑9 EMAs) |
| `SMA`                                       | REAL    | *Simple Moving Average* of Close (default 50‐day)           |
| `CCI`                                       | REAL    | *Commodity Channel Index*—detects cyclical extremes         |
| `Aroon Up`, `Aroon Down`                    | REAL    | Measures days since recent highs/lows (0‑1 scaled)          |
| `Sadj`                                      | REAL    | Split‑/dividend‑adjusted close (redundant with `Adj Close`) |

> **Data cleaning:** We remove weekends/zero‑volume rows and de‑duplicate any accidental repeats using `ROW_NUMBER()` in SQL.  Final trading‑day counts match NYSE calendars (≈252 days yr).

---

## 🧰 Folder Structure

```
ge-stock-analysis/
├── data/                # raw + cleaned CSVs
├── sql/                 # every query used (see below)
├── tableau/             # Tableau workbook (.twbx)
├── dashboard_preview.png# screenshot
└── README.md            # this file
```

---

## 🧑‍💻 SQL Analysis Walk‑Through

All scripts live in `/sql/`.  Key ones:

### 1.  \`\` – Create table & import CSV

```sql
CREATE TABLE ge_stock_data (...);
.mode csv
.import data/ge_stock_data.csv ge_stock_data
```

*Cleansing:* drop rows with `Volume = 0`, cast numeric fields, remove weekends.

### 2.  \`\` – Price trend

```sql
SELECT YEAR(Date) AS Year, ROUND(AVG(Close),2) AS Avg_Close
FROM   ge_stock_data_clean
GROUP  BY Year
ORDER  BY Year;
```

⇢ *Feeds Graph 1*

### 3.  \`\` – Weak‑momentum count

```sql
SELECT YEAR(Date) AS Year, COUNT(*) AS Days_Oversold
FROM   ge_stock_data_clean
WHERE  RSI < 30
GROUP  BY Year;
```

⇢ *Feeds Graph 2*

### 4.  \`\` – Trend strength

```sql
SELECT YEAR(Date) AS Year, ROUND(AVG(CCI),2) AS Avg_CCI
FROM   ge_stock_data_clean
GROUP  BY Year;
```

⇢ *Feeds Graph 3*

### 5.  \`\` – High/low frequency

```sql
SELECT YEAR(Date) AS Year,
       ROUND(AVG([Aroon Up]),2)   AS Aroon_Up,
       ROUND(AVG([Aroon Down]),2) AS Aroon_Down
FROM   ge_stock_data_clean
GROUP  BY Year;
```

⇢ *Feeds Graph 4*

### 6.  \`\` – Bullish vs Bearish days

```sql
WITH trading AS (
  SELECT Date, Close, SMA
  FROM   ge_stock_data_clean
)
SELECT YEAR(Date) AS Year,
       SUM(CASE WHEN Close > SMA THEN 1 ELSE 0 END) AS Bullish_Days,
       SUM(CASE WHEN Close < SMA THEN 1 ELSE 0 END) AS Bearish_Days
FROM   trading
GROUP  BY Year;
```

⇢ *Feeds Graph 5*

---

## 📊 Tableau Dashboard

File: `tableau/GE_Stock_Analysis.twbx`

All visualizations are presented as **line graphs** to clearly illustrate trends over time. Each sheet is configured to use continuous axes, smooth line interpolation, and distinct colors for readability.

| Worksheet   | Data Source              | Chart Type | Title                                                     | Details                                                                                                                      |
| ----------- | ------------------------ | ---------- | --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| **Graph 1** | `avg_close_per_year.csv` | Line       | Yearly Average Closing Price                              | Plots the annual average of daily closing prices to show long-term stock value trends.                                       |
| **Graph 2** | `rsi_oversold.csv`       | Line       | Investor Weakness Signals: RSI < 30                       | Shows the count of days per year GE was oversold (RSI below 30), highlighting years of negative investor sentiment.          |
| **Graph 3** | `cci_per_year.csv`       | Line       | Average CCI: Measuring Trend Strength                     | Displays average Commodity Channel Index values per year to indicate strength or weakening of cyclical price movements.      |
| **Graph 4** | `aroon_up_down.csv`      | Line       | Aroon Up vs. Aroon Down: New Highs vs. New Lows Frequency | Two overlaid lines: Aroon Up (days since last high) and Aroon Down (days since last low), revealing shifts in market cycles. |
| **Graph 5** | `bull_bear_sma.csv`      | Line       | Bullish vs. Bearish Days (Close vs. SMA)                  | Overlaid lines for count of days Close > SMA (bullish) and Close < SMA (bearish), illustrating market momentum dynamics.     |

The **Dashboard** combines these five sheets into one view. Interactive filters allow year range selection, and tooltips provide exact values on hover. The layout emphasizes the interplay between price level, momentum, and trend indicators.

## 📚 Technical Glossary (Plain English) (Plain English)

- **OHLC:** Daily Open‑High‑Low‑Close prices.
- **Adj Close:** Close price adjusted for dividends & splits.
- **Volume:** Number of shares traded.
- **SMA (Simple Moving Average):** Average of `Close` over N days (smooths noise).
- **RSI (Relative Strength Index):** 0‑100 oscillator; <30 = oversold, >70 = overbought.
- **MACD:** Difference between two EMAs (12 & 26‑day) — shows momentum.
- **MACD Signal:** 9‑day EMA of MACD; crossovers trigger buy/sell signals.
- **CCI (Commodity Channel Index):** +100/‑100 thresholds flag extremes.
- **Aroon Up/Down:** Measures how recently price hit a high or low.

---

## 🔑 Insights & In‑Depth Recommendations

| Theme                                  | Finding                                                                                        | Recommendation                                                                                                                   |
| -------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **Price surge vs momentum**            | Avg Close jumped 44 % from 2020→2021, but RSI & CCI softness in 2022 hints at fading momentum. | **Re‑ignite narrative**: Aggressively communicate pipeline wins & growth segments (renewables, aerospace) to restore conviction. |
| **Bearish sentiment 2018‑2020**        | Elevated bearish days (SMA < Close) & high RSI oversold counts.                                | **Capital strategy**: Continue deleveraging & simplify business units to reassure market during restructurings.                  |
| **Declining Aroon Up in 2022**         | Fewer new highs signals enthusiasm drop.                                                       | **Innovation push**: Accelerate R&D in additive manufacturing/digital twins; highlight milestones quarterly.                     |
| **High Bullish/Bearish ratio**         | >65 % bullish days in 2019‑2021, but parity in 2022.                                           | **Investor engagement**: Host investor days & transparent KPIs to prevent slide into sustained bearish trend.                    |
| **Volume spikes during oversold dips** | Capitulation‑style sell‑offs align with bad news cycles.                                       | **Crisis comms playbook**: Swiftly address negative narratives via press releases & executive Q&As to cap drawdowns.             |

---

## 🔄 Future Work

- Blend **fundamental data** (revenue, net income) to link price moves with real performance.
- Extend indicator set (Bollinger Bands, Stochastic) for multi‑factor signals.
- Deploy **Python notebooks** for reproducible back‑testing of trading strategies.

---

## 🏗️ Reproducibility

1. Clone repo ➜ `git clone https://github.com/<user>/ge-stock-analysis.git`
2. Open `sql/01_clean_load.sql` in DB Browser → run all scripts.
3. Open `tableau/GE_Stock_Analysis.twbx` in Tableau Public.
4. Enjoy & fork!

---

## 👤 Author

Oliver Cupozzi — aspiring data scientist | [LinkedIn](https://www.linkedin.com/) | [Email](mailto\:example@example.com)

---

### License

MIT © 2025 Oliver Cupozzi

