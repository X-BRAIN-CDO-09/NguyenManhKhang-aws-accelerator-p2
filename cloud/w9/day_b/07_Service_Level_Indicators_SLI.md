# Service Level Indicators (SLI)

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu SLI là gì.
- Biết cách xây dựng SLI đúng.
- Hiểu User-Centric Metrics.
- Hiểu Four Golden Signals.
- Biết các SLI phổ biến trong Production.

---

# 1. SLI là gì?

SLI (Service Level Indicator) là chỉ số đo lường chất lượng thực tế của một dịch vụ.

Nói đơn giản:

SLI trả lời:

"Hệ thống hiện đang hoạt động tốt đến mức nào?"

---

# 2. Mối quan hệ giữa SLI và SLO

SLI:

Đo lường thực tế.

Ví dụ:

99.92%

---

SLO:

Mục tiêu cần đạt.

Ví dụ:

99.90%

---

Nếu:

SLI > SLO

→ Đạt mục tiêu

Nếu:

SLI < SLO

→ Vi phạm mục tiêu

---

# 3. User-Centric SLI

Sai lầm phổ biến:

Đo:

- CPU
- RAM
- Disk

Người dùng không quan tâm CPU bao nhiêu.

Người dùng quan tâm:

- Login được không?
- Thanh toán được không?
- API có phản hồi không?

---

# 4. Availability SLI

Khả năng phục vụ request thành công.

Công thức:

Successful Requests
/
Total Requests

Ví dụ:

999000
/
1000000

=

99.9%

---

PromQL:

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

---

# 5. Latency SLI

Đo tốc độ phản hồi.

Ví dụ:

95% request < 300ms

---

PromQL:

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket[5m]))
  by (le)
)
```

---

# 6. Error Rate SLI

Đo tỷ lệ lỗi.

Công thức:

5xx Requests
/
Total Requests

---

PromQL:

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

---

# 7. Throughput SLI

Khả năng xử lý request.

Ví dụ:

500 requests/s

1000 requests/s

---

PromQL:

```promql
sum(rate(http_requests_total[5m]))
```

---

# 8. Four Golden Signals

Theo Google SRE:

- Latency
- Traffic
- Errors
- Saturation

---

# 9. Ví dụ SLI thực tế

Login Service

Availability:

99.95%

Latency:

95% < 200ms

Error Rate:

< 0.1%

---

Payment Service

Availability:

99.99%

Latency:

95% < 500ms

Error Rate:

< 0.05%

---

# 10. Best Practices

Đo trải nghiệm người dùng.

Ưu tiên:

- Availability
- Latency
- Error Rate

Không dùng:

- CPU
- RAM

làm SLI chính.

---

# Tổng kết

SLI là số liệu phản ánh trải nghiệm thực tế của người dùng.

Các SLI quan trọng:

- Availability
- Latency
- Error Rate
- Throughput