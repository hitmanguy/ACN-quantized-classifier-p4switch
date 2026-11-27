# Task 2 seam (draft v0 — agree before coding)

## Pipeline
parser -> quantize -> 7 feature tables -> decision table -> policy table -> egress

## Metadata (struct meta_t)
- q_<feat>    : bit<b>  quantized value, b set at compile time from generated header
- code_<feat> : bit<8>  range code written by the feature table
- class_id    : bit<8>  written by the decision table

## Tables (names are fixed; tables.json must use them)
- tbl_pkt_len, tbl_proto, tbl_sport, tbl_dport, tbl_tcp_flags, tbl_ttl, tbl_tcp_win
  - key: meta.q_<feat>, ternary
  - action: set_code_<feat>(bit<8> code)
- tbl_decision
  - key: all 7 code_<feat> fields, ternary
  - action: set_class(bit<8> class_id)
- tbl_policy
  - key: meta.class_id, exact
  - actions: act_forward(), act_drop(), act_mark(bit<6> dscp), act_to_cpu()

## Modes (same P4, different tbl_policy entries)
- verify:   every class -> act_mark(dscp_of_class); harness reads DSCP per packet
- mitigate: benign -> forward, attacks -> drop

## Class IDs / DSCP (needs Task 1 + 3 to confirm class list)
benign=0/dscp 0, dos=1/dscp 8, portscan=2/dscp 16, bruteforce=3/dscp 24

## Defaults for absent fields
Per features.yaml (all 0). ICMP: sport/dport/tcp_flags/tcp_win = 0. UDP: tcp_flags/tcp_win = 0.

## Registers (stretch, later)
reg_pkt_count[65536], reg_last_ts[65536], index = crc16(5-tuple)

## Open questions
- Quantization method for pkt_len (clip_scale vs truncation; shift-friendly?)
- Final class list and ids
- Ternary spelling in tables.json (Task 3 documents it)
