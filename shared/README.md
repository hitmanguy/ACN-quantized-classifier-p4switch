# shared/ — the contract between tasks

Everything in `shared/interfaces/` is the **only** point of contact between tasks.
Agree on these files first; from then on everyone builds and tests against them with
stub data, so nobody waits on anyone else.

| File | Owner | Used by |
|---|---|---|
| `features.yaml` | Task 1 | Tasks 2 and 3 |
| `model.json` | Task 1 | Task 3 |
| `tables.json` | Task 3 | Task 2 (the loader) |
| `results.csv` | Task 4 | Everyone appends rows |

**Versioning rule:** every file carries a `version` / header field. If a format must
change, the owner announces it in the sync and bumps the version. Never silently edit
a frozen file.

## Schemas (keep the examples valid — they are what you parse against)

`model.json` — node schema:
- internal node: `{"feature": <name from features.yaml>, "threshold": <number>, "left": <node>, "right": <node>}`
- leaf: `{"class": <class label>}`
- top level also has `bit_config` (feature → bits), `dataset`, `depth`.

`tables.json` — table schema:
- `{"name": ..., "match_type": "ternary" | "exact", "key": <field>, "entries": [{"match": ..., "action": ..., "params": {...}, "priority": <int>}], "size_hint": <int>}`
- Ternary `match` entries use `value` + `mask` pairs per key bit-field; Task 3 documents
  the exact spelling in `task3/README.md` and Task 2's loader must accept it.

