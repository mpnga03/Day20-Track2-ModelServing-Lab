# Reflection - Lab 20 (Báo Cáo Cá Nhân)

**Họ tên:** Mac Phương Nga  
**Cohort:** A20-K2  
**Ngày submit:** 2026-05-06

---

## 1. Hardware spec (từ `00-setup/detect-hardware.py`)

- **OS:** Windows 10 (AMD64)
- **CPU:** AMD Ryzen 7 7735HS with Radeon Graphics
- **Cores:** 8 physical / 16 logical
- **CPU extensions:** AVX2 (theo log runtime của llama.cpp)
- **RAM:** 27.3 GB
- **Accelerator:** CPU only
- **llama.cpp backend đã chọn:** CPU
- **Recommended model tier:** Llama-3.2-3B-Instruct (Q4_K_M)

**Setup story:** Ban đầu `llama-cpp-python` trên Windows gặp lỗi cài đặt/server dependency. Em chuyển sang dùng native `llama-server.exe` (build từ source) để có endpoint `/metrics`, sau đó chạy được smoke test + locust + metrics recording.

---

## 2. Track 01 - Quickstart numbers (từ `benchmarks/01-quickstart-results.md`)

| Model | Load (ms) | TTFT P50/P95 (ms) | TPOT P50/P95 (ms) | E2E P50/P95/P99 (ms) | Decode rate (tok/s) |
|---|--:|--:|--:|--:|--:|
| tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf | 692 | 98 / 120 | 22.5 / 37.0 | 1330 / 1544 / 1557 | 44.4 |
| tinyllama-1.1b-chat-v1.0.Q2_K.gguf | 140 | 150 / 200 | 16.8 / 17.0 | 1215 / 1242 / 1245 | 59.5 |

**Một quan sát:** Q2_K decode nhanh hơn (59.5 tok/s so với 44.4 tok/s) và load nhanh hơn, nhưng chất lượng output kém ổn định hơn. Q4_K_M chậm hơn một ít nhưng text tốt hơn để dùng cho trả lời học thuật.

---

## 3. Track 02 - llama-server load test

| Concurrency | Total RPS | TTFB P50 (ms) | E2E P95 (ms) | E2E P99 (ms) | Failures |
|--:|--:|--:|--:|--:|--:|
| 10 | 1.21 | 6500 | 9200 | 10000 | 0 |
| 50 | 1.26 | 15000 | 24000 | 28000 | 0 |

**KV-cache observation:** Bản `llama-server.exe` trên máy em không export `llamacpp:kv_cache_usage_ratio` (record = 0.00), nên em dùng proxy metric: `requests_processing` peak = 4 và `requests_deferred` peak = 46 (file `benchmarks/02-server-metrics.csv`). Điều này cho thấy hệ thống bị queue khi concurrency 50.

---

## 4. Track 03 - Milestone integration

- **N16 (Cloud/IaC):** stub: localhost only (native llama-server trên port 8080)
- **N17 (Data pipeline):** stub: in-memory toy docs
- **N18 (Lakehouse):** stub: none (không dùng Delta/Iceberg trong demo này)
- **N19 (Vector + Feature Store):** stub: keyword retrieval từ `TOY_DOCS` (không dùng vector DB/Feast ngoài)

**Nơi tốn nhiều ms nhất trong pipeline** (từ `pipeline.py`):

- embed: 0 ms (stub, không chạy embed model)
- retrieve: ~0.0 ms
- llama-server: ~5521 ms trung bình (3 query: 6108.4 / 4418.3 / 6037.1)

**Reflection:** Bottleneck nằm ở bước inference LLM, retrieval gần như không đáng kể vì đang là stub keyword overlap. Kết quả khớp kỳ vọng: khi retrieval rất nhẹ, phần lớn latency đến từ prefill/decode của model trên CPU.

---

## 5. Bonus - The single change that mattered most

**Change:** Tuning số thread bằng sweep (`BONUS-llama-cpp-optimization/benchmarks/thread-sweep.py`), từ `-t 1` lên `-t 8`.

**Before vs after:**

```text
before: -t 1  -> 21.2 tok/s
after:  -t 8  -> 54.2 tok/s
speedup: ~2.56x
```

**Tại sao nó work:** CPU-only inference của model nhỏ trên laptop bị giới hạn bởi memory bandwidth và scheduling. Khi tăng từ 1 thread lên mức gần số core vật lý, token throughput tăng mạnh do tận dụng được song song prefill/decode. Sau điểm tối ưu (8 thread), hiệu năng giảm khi oversubscribe (16, 32) vì tranh chấp cache/bandwidth và overhead context switching.

---

## 6. (Optional) Điều ngạc nhiên nhất

Dù RAM 27.3 GB và hardware gợi ý model 3B, TinyLlama vẫn là lựa chọn ổn định để chạy full rubric trên Windows CPU-only (đặc biệt khi cần native metrics endpoint).

---

## 7. Self-graded checklist

- [x] `hardware.json` đã commit
- [x] `models/active.json` đã commit
- [x] `benchmarks/01-quickstart-results.md` đã commit
- [x] `benchmarks/02-server-metrics.csv` đã commit
- [x] `benchmarks/bonus-thread-sweep.md` đã commit
- [x] Ít nhất 6 screenshots trong `submission/screenshots/`
- [x] `python scripts/verify.py` exit 0
- [x] Repo trên GitHub ở chế độ **public**
- [x] Đã paste public repo URL vào VinUni LMS
