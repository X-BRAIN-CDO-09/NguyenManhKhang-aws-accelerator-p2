# OTel Collector Architecture

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu kiến trúc OpenTelemetry Collector.
- Hiểu Receiver, Processor, Exporter.
- Hiểu Agent Mode và Gateway Mode.
- Biết cách xây dựng Pipeline Observability.
- Hiểu Best Practices khi triển khai Collector trong Kubernetes.

---

# 1. OpenTelemetry Collector là gì?

OpenTelemetry Collector là thành phần trung tâm của hệ sinh thái OpenTelemetry.

Vai trò:

Receive → Process → Export

Collector giúp:

Application
↓
Collector
↓
Observability Backend

thay vì:

Application
↓
Prometheus

Application
↓
Jaeger

Application
↓
Loki

---

# 2. Tại sao cần Collector?

Không dùng Collector:

Application
├── Prometheus Exporter
├── Jaeger Exporter
├── Loki Exporter
└── Vendor Agent

Hậu quả:

- Khó quản lý
- Khó thay đổi Backend
- Vendor Lock-in
- Tăng tài nguyên tiêu thụ

Có Collector:

Application
↓
OTLP
↓
Collector
↓
Multiple Backends

---

# 3. Kiến trúc Collector

Collector gồm 3 thành phần:

Receiver
↓
Processor
↓
Exporter

---

# 4. Receiver

Receiver là điểm nhận dữ liệu.

Nhiệm vụ:

- Metrics
- Logs
- Traces

Ví dụ:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:
```

Các Receiver phổ biến:

| Receiver | Mục đích |
|-----------|-----------|
| OTLP | OTel SDK |
| Prometheus | Scrape Metrics |
| Jaeger | Traces |
| Zipkin | Traces |
| FluentForward | Logs |

---

# 5. Processor

Processor xử lý dữ liệu trước khi export.

Ví dụ:

- Filter
- Transform
- Batch
- Sample

---

# 6. Batch Processor

Processor quan trọng nhất.

```yaml
processors:
  batch:
```

Mục đích:

Gom dữ liệu
↓
Giảm số request
↓
Tăng hiệu năng

---

# 7. Memory Limiter

Ngăn Collector dùng quá nhiều RAM.

```yaml
processors:
  memory_limiter:
    limit_mib: 512
```

Lợi ích:

- Tránh OOMKilled

---

# 8. Attributes Processor

Thêm metadata.

```yaml
processors:
  attributes:
```

Ví dụ:

- environment=production
- team=platform

---

# 9. Sampling Processor

Không phải mọi Trace đều cần lưu.

Ví dụ:

10000 requests/s

Lưu toàn bộ:

→ Chi phí rất cao

Sampling:

- 1%
- 5%
- 10%

---

# 10. Exporter

Exporter gửi dữ liệu ra ngoài.

```yaml
exporters:
  prometheus:
  loki:
  tempo:
  otlp:
```

---

# 11. Pipeline

Ví dụ:

```yaml
service:
  pipelines:
    metrics:
      receivers:
      processors:
      exporters:
```

Luồng:

Receiver
↓
Processor
↓
Exporter

---

# 12. Pipeline hoàn chỉnh

Application
↓
OTLP Receiver
↓
Batch Processor
↓
Prometheus Exporter
↓
Prometheus

---

# 13. Agent Mode

Mỗi Node chạy một Collector.

Node 1 → Collector

Node 2 → Collector

Node 3 → Collector

Ưu điểm:

- Giảm Network Hop
- Thu thập dữ liệu cục bộ

---

# 14. Gateway Mode

Collector tập trung.

Apps
↓
Collectors
↓
Gateway Collector
↓
Backend

Ưu điểm:

- Quản lý dễ
- Dễ scale

---

# 15. Agent + Gateway

Kiến trúc Production phổ biến nhất.

Application
↓
Agent Collector
↓
Gateway Collector
↓
Prometheus
Loki
Tempo

---

# 16. Kubernetes Deployment

Agent:

DaemonSet

Gateway:

Deployment

---

# 17. Best Practices

- Luôn dùng Batch Processor
- Luôn bật Memory Limiter
- Ưu tiên OTLP
- Tách Agent và Gateway cho Production

---

# Tổng kết

Collector là trái tim của OpenTelemetry.

Kiến trúc:

Receiver
↓
Processor
↓
Exporter

Là nền tảng trước khi học Prometheus và Grafana Stack.