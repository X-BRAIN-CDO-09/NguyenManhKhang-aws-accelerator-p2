# Prometheus And Metrics

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu Prometheus Architecture.
- Hiểu TSDB.
- Hiểu Metric Types.
- Hiểu PromQL.
- Hiểu Alerting.

---

# 1. Prometheus là gì?

Prometheus là hệ thống:

Monitoring
+
Metrics Storage
+
Alerting

Hiện là tiêu chuẩn Metrics trong Kubernetes.

---

# 2. Kiến trúc Prometheus

Target
↓
Scrape
↓
Prometheus
↓
TSDB
↓
PromQL
↓
Grafana

---

# 3. Pull Model

Prometheus sử dụng Pull Model.

Prometheus chủ động gọi:

/metrics

trên ứng dụng.

---

# 4. Exporter

Exporter chuyển dữ liệu thành Metrics.

Ví dụ:

- Node Exporter
- MySQL Exporter
- Redis Exporter
- Kafka Exporter

---

# 5. Time Series Database

Prometheus lưu:

- Metric Name
- Labels
- Timestamp
- Value

Ví dụ:

http_requests_total

method=GET

status=200

value=1234

---

# 6. Metric Types

Prometheus có 4 loại Metrics.

---

# 7. Counter

Chỉ tăng.

Ví dụ:

http_requests_total

Thường dùng:

- Requests
- Errors
- Events

---

# 8. Gauge

Có thể tăng hoặc giảm.

Ví dụ:

- CPU Usage
- Memory Usage
- Active Users

---

# 9. Histogram

Dùng cho Latency.

Ví dụ:

http_request_duration_seconds

Cho phép tính:

- P50
- P90
- P95
- P99

---

# 10. Summary

Tương tự Histogram.

Khác biệt:

Summary tính Quantile phía Client.

Histogram tính phía Server.

---

# 11. Labels

Labels tạo chiều dữ liệu.

Ví dụ:

http_requests_total

method=GET

status=200

Cho phép:

- Filter
- Group
- Aggregate

---

# 12. Cardinality

Sai lầm phổ biến:

- user_id
- request_id
- session_id

làm Labels.

Hậu quả:

- Tăng RAM
- Tăng CPU
- Tăng Storage

---

# 13. PromQL

Ngôn ngữ truy vấn của Prometheus.

---

# 14. Query cơ bản

```promql
http_requests_total
```

---

# 15. Rate

```promql
rate(http_requests_total[5m])
```

Ý nghĩa:

Requests/second

---

# 16. Sum

```promql
sum(rate(http_requests_total[5m]))
```

---

# 17. Average

```promql
avg(cpu_usage)
```

---

# 18. P95 Latency

```promql
histogram_quantile(
  0.95,
  sum(rate(http_request_duration_seconds_bucket[5m]))
  by (le)
)
```

---

# 19. Alerting

Ví dụ:

```promql
rate(http_requests_total{status=~"5.."}[5m])
```

Khi vượt ngưỡng:

Prometheus
↓
Alertmanager
↓
Slack / Telegram

---

# 20. Best Practices

- Dùng Histogram cho Latency
- Không dùng user_id làm Label
- Dùng rate() cho Counter
- Theo dõi 4 Golden Signals

---

# 21. Four Golden Signals

- Latency
- Traffic
- Errors
- Saturation

---

# Tổng kết

Cần nhớ:

- Counter
- Gauge
- Histogram
- PromQL
- Labels
- Cardinality
- Alerting