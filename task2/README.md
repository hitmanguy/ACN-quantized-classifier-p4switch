# Task 2 — P4 Switch Data Plane & Control Path

Full spec: `ACN_Task_Distribution.pdf`, section 5. This README is your starter checklist.

## Goal
A P4 program that extracts features, quantizes them, classifies every packet with tables
(no controller round-trip) and acts on the result — plus the control software, the
controller baseline, and the replay-and-verify harness.

## The two lanes (agree on the seam FIRST, one meeting)
This task is split between two people. Pin these before anyone writes code:
table names, metadata fields, DSCP mark values, register layout. After that you
work independently.

- **Lane A — the P4 program** (`task2/p4/`): parser, in-switch quantization,
  classification pipeline, registers.
- **Lane B — infrastructure** (`task2/topology/`, `task2/loader.py` later in
  `task2/controller/`, `task2/harness/`): Mininet topology, P4Runtime loader,
  controller baseline, replay-and-verify harness. Lane B is also the natural
  lead for Task 4 (the verification + demo steps run on this harness).

## Environment (Linux — use the P4 tutorials VM)
```bash
# p4lang/tutorials docker image ships: p4c, BMv2 (simple_switch_grpc), Mininet, P4Runtime
p4c --version && mncli --version    # verify
sudo apt install -y tshark tcpreplay wireshark
pip install scapy p4runtime pygrpc
```

## Work items, in order
1. **Test network.** Mininet topology: benign hosts, attacker hosts, victim server,
   ≥2 switches, BMv2 simple_switch_grpc. Verify each piece: ping → hello-world P4
   tutorial → your own minimal program through p4c.
2. **Parser + feature extraction.** Ethernet/IPv4/TCP/UDP/ICMP. Missing fields
   (e.g. ICMP ports) get a *defined default* — match `shared/interfaces/features.yaml`
   exactly and document every default.
3. **In-switch quantization.** Bit-slice each feature to b bits (top b bits),
   compile-time setting. Same source must build 16/8/6/4-bit versions —
   use `const` or a script-generated header, never four hand-edited copies.
4. **Classification pipeline.** One ternary table per feature → range code in
   metadata → one decision table on the combined codes. Actions: forward / drop /
   mark (DSCP) / send-to-controller. Mirrors the proposal's Figure 1.
5. **P4Runtime loader.** Python: reads `shared/interfaces/tables.json`, validates
   widths + priorities against features.yaml, installs everything. This is the
   only link from Task 3's output to the switch.
6. **Verification harness.** Replay labelled test packets (tcpreplay/scapy),
   read back the switch's decision per packet (DSCP or counters), diff against
   ground-truth labels, print a mismatch list.
7. **Controller baseline.** Second mode: first packets of each new flow go to a
   controller that runs the Python model and installs a drop rule for the flow.
   Measure time-to-mitigation, in-switch vs controller → results.csv.
8. **Stateful flow features (stretch).** 5-tuple-hash register arrays: packet
   count + last-seen timestamp → inter-arrival-time feature. Document collision rate.

## possible Layout
```
task2/
  p4/          P4_16 source
  topology/    Mininet scripts
  controller/  controller baseline code
  harness/     replay-and-verify code
  logs/        BMv2/Mininet logs from runs
```

## Deliverables
- P4 source, Mininet topology scripts, P4Runtime loader, controller baseline,
  replay-and-verify harness
- time-to-mitigation comparison: in-switch vs controller
- rows in `shared/interfaces/results.csv` for every switch run

## Done when
Header-only features: switch decisions match the Python model on 100% of replayed
packets; any flow-feature mismatch is explained (hash collisions); the controller
comparison is measured.
