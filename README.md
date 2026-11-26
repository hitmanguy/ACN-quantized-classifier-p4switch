# ACN — Quantized Traffic Classification in a P4 Switch

A short project description.

## What this project is about

We train a small **decision tree** in Python to tell normal traffic apart from attacks,
then run that model **inside a network switch** instead of on a server. The switch is
programmed in **P4**, so it classifies every packet as it passes and immediately
forwards, drops, or tags it — no per-packet trip to a controller.

## Core idea

A switch is great at table lookups but can't run code. So a trained tree (comparisons
like "packet length < 120?") is **compiled into match-action tables**: feature tables
map each quantized value to a short range code, and one decision table maps the code
combination to a class and action.

The study question: **how few bits can each feature use before accuracy gets too bad?**
Fewer bits → fewer distinct values → smaller switch tables. We measure the
accuracy-vs-memory trade-off across 16 / 8 / 6 / 4-bit features.

## What we build

- A P4 switch (BMv2 in Mininet) that classifies and mitigates attack traffic in the data plane.
- A tree-to-table compiler with a proof that the switch behaves exactly like the Python model.
- A mixed-precision bit-width optimizer and the final accuracy-vs-memory recommendation.

## In short

**Goal:** stop attacks in the switch, fast. **Study:** how small can the tables be
before classification quality falls off — and where is the sweet spot.
