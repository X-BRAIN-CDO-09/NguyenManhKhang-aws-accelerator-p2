# Grafana Loki Tempo

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu Grafana.
- Hiểu Loki.
- Hiểu Tempo.
- Hiểu Distributed Tracing.
- Biết cách Correlate Metrics, Logs và Traces.

---

# 1. Grafana là gì?

Grafana là nền tảng:

- Visualization
- Dashboard
- Alerting

Grafana không lưu dữ liệu.

Nó kết nối tới:

- Prometheus
- Loki
- Tempo
- Elasticsearch

---

# 2. Dashboard

Grafana hiển thị:

- CPU
- Memory
- Latency
- Error Rate
- Availability

---

# 3. Explore

Explore hỗ trợ điều tra sự cố.

Có thể xem:

- Metrics
- Logs
- Traces

trong cùng giao diện.

---

# 4. Loki là gì?

Loki là hệ thống Log Aggregation của Grafana Labs.

Mục tiêu:

Thu thập
↓
Lưu trữ
↓
Tìm kiếm Logs

---

# 5. Kiến trúc Loki

Application
↓
Promtail / OTel Collector
↓
Loki
↓
Grafana

---

# 6. Structured Logging

Best Practice:

```json
{
  "service":"payment",
  "level":"error",
  "message":"payment timeout"
}
```

Lợi ích:

- Parse dễ
- Query dễ
- Correlate tốt

---

# 7. Loki Labels

Nên dùng:

- namespace
- pod
- service
- environment

Không nên:

- request_id
- user_id
- session_id

Vì gây High Cardinality.

---

# 8. Tempo là gì?

Tempo là hệ thống Distributed Tracing.

Mục tiêu:

Theo dõi toàn bộ đường đi của Request.

---

# 9. Trace

Ví dụ:

User
↓
Frontend
↓
API Gateway
↓
Payment Service
↓
Database

Toàn bộ hành trình gọi là:

Trace

---

# 10. Span

Một bước trong Trace.

Ví dụ:

- HTTP Call
- DB Query
- Redis Query

---

# 11. Trace ID

Mỗi Request có một:

Trace ID

duy nhất.

Ví dụ:

7af8bc92

---

# 12. Context Propagation

Trace ID được truyền qua:

Frontend
↓
Gateway
↓
Backend
↓
Database

Nhờ đó toàn bộ request được liên kết.

---

# 13. Correlation

Metrics
↓
Latency tăng

↓

Trace
↓
Payment Service chậm

↓

Logs
↓
Database Timeout

↓

Root Cause

---

# 14. LGTM Stack

LGTM:

- Loki
- Grafana
- Tempo
- Mimir

Hoặc:

- Loki
- Grafana
- Tempo
- Prometheus

---

# 15. Kiến trúc Production

Application
↓
OTel SDK
↓
OTel Collector
↓
Prometheus

Loki

Tempo
↓
Grafana

---

# 16. Best Practices

## JSON Logs

Luôn ưu tiên Structured Logging.

## Trace ID

Logs nên chứa:

- trace_id
- request_id

## Sampling

Production thường:

- 1%
- 5%
- 10%

## Correlate MELT

Metrics
↓
Events
↓
Logs
↓
Traces

---

# Tổng kết

Grafana Stack:

Prometheus → Metrics

Loki → Logs

Tempo → Traces

Grafana → Visualization

Kết hợp lại tạo thành hệ thống Observability hoàn chỉnh cho Kubernetes và Cloud Native.