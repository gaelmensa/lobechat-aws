AI tool: Claude (claude.ai), session date 2026-05-27

**How AI was used:**

I built the cost model myself using the AWS pricing pages and OpenRouter docs directly. The assumptions (messages per user per day, token counts, model mix) came from my own judgment about realistic usage patterns for the legal use case in Q1.

I used Claude to:
- Check the correct AWS eu-west-1 list prices for RDS db.r5.large Multi-AZ and t3.2xlarge — I had the right ballpark but wanted to verify the exact figures before putting them in a table.
- Understand how blended token rates work when mixing two models (Haiku 70% / Sonnet 30%) to make the formula explicit.
- Discuss which cost-cutting levers were most impactful and whether the savings claim (≥15%) was met — I had Haiku routing and Reserved Instances in mind but needed to quantify them.
- Format the final answer in Markdown with the cost tables, unit economics table, and pricing recommendation formula.

What I kept from the AI interaction: the exact AWS price figures (verified against the pricing pages), the blended rate formula, and the Markdown table structure.

What I wrote myself: the assumptions, the choice of model mix, the analysis of which cost drivers matter most, the lever descriptions and their UX trade-offs, and the pricing recommendation logic.
