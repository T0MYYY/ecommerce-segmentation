# E-Commerce Customer Segmentation for Targeted Promotion

Segmenting an e-commerce customer base into actionable tiers, validating the segments
out-of-time, and costing a tiered promotion plan for a CMO audience.

Course project, ADSP 31016 (Applied Data Science, University of Chicago), Autumn 2025.
Team *PlayingPandas*: Joyce Zhang, Tom Chen, Yingqi Chen, Bowen Cheng, Khalil He, Tony Li.

---

## Problem

A CMO wants to know which customers to spend promotion budget on. "High spenders" is not an
answer you can act on: it says nothing about why a customer spends, whether the behaviour will
persist, or what offer would move them. The project builds segments that are **stable across
time**, **interpretable to a marketing team**, and **assignable to new customers on arrival**.

## Data

Amazon purchase histories joined to a consumer survey, split into two non-overlapping windows:

| Window | Customers | Use |
|---|---:|---|
| 2018–19 | 4,669 | Build segments |
| 2020–21 | 4,939 | Out-of-time validation |

Survey responses: 5,027. The survey carries demographic and household attributes alongside
purchase behaviour.

**The data is not in this repository.** It was provided through the course. `docs/data_dictionary.xlsx`
documents the schema so the notebooks can be read without it.

## Approach

**1. Mixed-type clustering.** Customer records mix continuous spend behaviour with categorical
survey attributes, so plain k-means is the wrong tool. The main line uses **K-Prototypes**, which
handles both types in one distance function. A parallel k-means line (engineered binary features
for parenthood, relocation, income tier, plus category entropy) is kept for comparison.

**2. Choosing k against business readability, not silhouette alone.** Silhouette prefers k=3
(0.4678) over k=4 (0.4563). The gap is under 0.05, and k=4 maps onto a segmentation marketing
teams already reason in, so k=4 was chosen deliberately — the decision and its justification are
recorded in the notebook rather than left implicit.

**3. Thresholds from cluster boundaries, not medians.** Segment cut-points are derived from the
actual min/max boundaries between adjacent clusters, so the rule engine reproduces the clustering
rather than approximating it.

**4. Out-of-time validation.** Segments built on 2018–19 are re-scored on 2020–21 to see whether
they describe anything durable. This changed a conclusion: the relocating-customer segment was
expected to churn, but retained at 99% with spend up 85%. The recommendation moved from win-back
to category penetration — they were still buying, just not in the categories the business assumed.

**5. Deployment as rules, not a slide.** The final output is an assignment function that scores a
customer from their attributes at arrival, so the segmentation runs continuously instead of being
a one-off analysis.

## Results

- Four segments, each with a distinct spend profile and survey signature.
- The top segment is ~15% of customers and ~52% of revenue.
- Tiered promotion plans costed per segment: **$824K** projected annual uplift on the K-Prototypes
  segmentation, **$528K** on the k-means line. Both figures apply assumed per-segment lift rates to
  observed segment spend; the lift rates are assumptions, documented inline, not measured effects.

## Repository

```
notebooks/
  00_exploratory_analysis.ipynb            Spend, demographics, life-event signals
  00b_exploratory_analysis_extended.ipynb  Extended EDA
  01_kprototypes_segmentation.ipynb        K-Prototypes, k selection, rule engine
  02_kmeans_model_and_uplift.ipynb         K-means line, out-of-time validation, uplift costing
  preprocessing.R                          Data preparation
docs/
  CMO_presentation.pdf                     Final deliverable
  data_dictionary.xlsx                     Schema reference
```

Notebook outputs are cleared: the underlying survey contains respondent-level attributes that
should not be redistributed.

## Stack

Python (pandas, NumPy, scikit-learn, kmodes), R, matplotlib, seaborn.
