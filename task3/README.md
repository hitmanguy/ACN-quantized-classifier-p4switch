# Task 3 — Tree-to-Table Compiler & Correctness Proof

Full spec: `ACN_Task_Distribution.pdf`, section 6.

## Goal
Turn *any* trained tree (model.json) into a correct, compact set of switch table
entries, and prove the tables behave exactly like the Python tree. Your entry
counts feed Task 4's cost model and optimizer.

## Environment (Linux, pure Python)
```bash
pip install scikit-learn numpy pytest PyYAML
# You import Task 1's quantizer + model.json; you do not run a switch.
```
**Start now with toy trees:** train small trees on the Iris dataset, export to
model.json in the agreed format. Don't wait for Task 1.

## Work items, in order
1. **Tree parsing** (`task3/src/tree_parse.py`). Read model.json, collect every
   split threshold per feature → range boundaries → short integer codes per range.
2. **Range-to-ternary conversion** (`task3/src/range2tcam.py`). One range over w
   bits can need up to 2^w − 2 ternary entries, usually far fewer. Count the
   *real* TCAM entries per feature table — this is the number that goes into results.csv.
3. **Decision table generation** (`task3/src/decision.py`). One entry per leaf over
   the range codes; don't-care bits for untested features; merge neighbouring
   same-class leaves; priorities correct. Output must match the
   `shared/interfaces/tables.json` schema exactly (your loader is Task 2's — keep the contract).
4. **Golden model + correctness proof** (`task3/src/emulator.py`, `task3/tests/`).
   Pure-Python emulator of the generated tables. Show identical answers to
   scikit-learn on the whole test set, and on *every* input for small bit-widths.
   Wrap in pytest so the proof is one command: `pytest task3/tests`.
5. **Entry-cost report** (`task3/src/cost.py`). Entries per table, total TCAM
   bits (entries × key width), estimated pipeline stages (tables/stage merging).
   Expose `entry_cost(tables) -> report` so Task 4 can import it.
6. **Prefix-aligned savings.** Using your entry counts, measure how many entries
   Task 1's prefix-aligned trees save vs normally trained trees at equal accuracy.

## CLI deliverable
```bash
python -m task3.src.compile shared/interfaces/model.json -o task3/output/tables.json
# writes: tables.json + entry-cost report; prints stage estimate
```

## Layout
```
task3/
  src/          tree_parse, range2tcam, decision, emulator, cost, compile (CLI)
  tests/        pytest equivalence tests + property checks
  output/       compiled tables.json + cost reports per experiment
```

## Done when
Emulator matches scikit-learn 100% on all test sets, and Task 4 can compile any
tree and read its entry cost (`entry_cost()`) without messaging you.
