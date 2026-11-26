# Task 1 — Dataset Pipeline & Quantization-Aware Tree Training

Full spec: `ACN_Task_Distribution.pdf`, section 4. This README is your starter checklist.

## Goal
Produce trained decision trees that only use header-only features, and measure how accuracy
changes as each feature loses bits. Deliver the cleaned datasets, trained models, and the
**accuracy oracle** that Task 4's optimizer will call.

## Environment (Linux, anything — laptop or the shared VM)
```bash
pip install scikit-learn pandas numpy matplotlib scapy dpkt pyarrow PyYAML pytest
sudo apt install -y tshark        # only needed if you export pcap fields with tshark
```
Put raw datasets in `shared/data/` (CIC-IDS2017 from unbw.ca/cicdatasets, or UNSW-NB15).
**Do not commit datasets** — they are gitignored.

## Work items, in order
1. **Per-packet feature extraction from raw pcaps.** Do NOT use the ready-made flow CSVs
   (they contain stats a switch can't compute). Parse raw pcaps with scapy/dpkt
   (`tshark -T fields` for bulk export). Extract: packet length, protocol, src/dst port,
   TCP flags, TTL, TCP window size. One Parquet file per dataset → `task1/output/`.
2. **Packet labelling.** Datasets label flows, not packets. Map packets → flows by
   5-tuple + time window, both directions. Spot-check ~50 flows by hand.
3. **Leakage-free evaluation.** 3–5 classes (e.g. benign, DoS, port scan, brute force).
   Split by capture day or by flow — **never random packets**. Handle imbalance
   (class weights/sampling). Report **macro-F1**, not just accuracy.
4. **Quantizer module** (`task1/src/quantizer.py`, reusable). Two methods: truncation
   (top b bits) and clip-then-scale. Compare both on a quick accuracy check.
   Task 4 uses this via the oracle — keep it importable.
5. **Prefix-aligned training (the novel part).** Custom split search for depth-limited
   trees where thresholds sit only on multiples of 2^k (bit-aligned). Compare against
   train-then-round. Measure accuracy + distinct-ranges-per-feature.
6. **Experiments.** (a) full-precision baseline; (b) uniform 16/8/6/4-bit; (c)
   prefix-aligned at same widths; (d) depth 3–8; (e) cross-dataset test.
   Every run → one row appended to `shared/interfaces/results.csv`.
7. **Accuracy oracle** (`task1/src/oracle.py`):
   `evaluate(bit_config) -> accuracy` — clean, documented, importable from task4/.

## Deliverables
- extractor + labelling scripts; cleaned per-packet datasets (Parquet)
- quantizer module, prefix-aligned trainer, exported `model.json` files
- accuracy/macro-F1 vs bits plots; cross-dataset result
- `shared/interfaces/features.yaml` filled in and frozen (you own it)

## Done when
Baseline macro-F1 on both datasets, accuracy-vs-bits curve complete, and Task 4 can call
`oracle.evaluate(bit_config)` without messaging you.

## Conventions (see shared/README.md for the frozen versions)
- Thresholds in model.json are quantized integers; left if `value < threshold`.
- Packet length = `ipv4.totalLen` (tshark `ip.len`), not frame length.
- `tcp_flags` is fixed at 8 bits (`sweep: false` in features.yaml).

## Entry points
- `task1/src/quantizer.py`  — `truncate`, `clip_scale`
- `task1/src/oracle.py`     — `evaluate(bit_config)` (stub for now)
- `pytest task1/tests`
(Add `extract.py`, `label.py`, `tree.py`, `experiments.py` here as they get built.)
