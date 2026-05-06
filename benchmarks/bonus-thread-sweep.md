# Bonus — Thread sweep

Model: `tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf`  ·  GPU layers: `0`

| threads | tg128 (tok/s) |
|---:|---:|
| 1 | 21.2 |
| 2 | 37.3 |
| 4 | 53.3 |
| 8 | 54.2 |
| 16 | 46.3 |
| 32 | 40.6 |

**Best**: `-t 8` at 54.2 tok/s.

Look at the curve. If it peaks around your **physical** core count and drops as you go higher, that's the memory-bandwidth ceiling: extra threads fight over the same memory channels and slow each other down.
