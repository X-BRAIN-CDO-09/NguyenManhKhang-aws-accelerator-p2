# OpenTelemetry Fundamentals

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu OpenTelemetry là gì.
* Hiểu vai trò của OTel trong hệ sinh thái Observability.
* Hiểu Instrumentation.
* Hiểu OTel SDK, API và Collector.
* Chuẩn bị cho OTel Collector Architecture.

---

# 1. OpenTelemetry là gì?

OpenTelemetry (OTel) là tiêu chuẩn mã nguồn mở dùng để:

```text
Thu thập
Xử lý
Xuất
```

dữ liệu Observability.

---

OTel hỗ trợ:

```text
Metrics

Logs

Traces
```

---

# 2. Vấn đề trước khi có OpenTelemetry

Mỗi công cụ dùng agent riêng.

Ví dụ:

```text
Prometheus Agent

Jaeger Agent

Zipkin Agent

NewRelic Agent
```

---

Kết quả:

```text
Khó quản lý

Tốn tài nguyên

Vendor Lock-in
```

---

# 3. OpenTelemetry Solution

```text
Application
↓
OTel SDK
↓
OTel Collector
↓
Prometheus

Loki

Tempo

Jaeger
```

---

Một lần Instrument.

Nhiều nơi nhận dữ liệu.

---

# 4. Instrumentation là gì?

Instrumentation là quá trình thêm khả năng quan sát vào ứng dụng.

---

Ví dụ:

```text
Request Count

Latency

Errors
```

---

# 5. Auto Instrumentation

OTel tự động thu thập.

Ví dụ:

```text
Java Agent

.NET Agent

Python Agent
```

---

Ưu điểm:

```text
Nhanh
Ít code
```

---

# 6. Manual Instrumentation

Developer viết code.

Ví dụ:

```java
Span span = tracer.spanBuilder("checkout").startSpan();
```

---

Ưu điểm:

```text
Chi tiết hơn
```

---

# 7. OTel API

API chuẩn để tạo:

```text
Metrics
Logs
Traces
```

---

Ví dụ:

```text
Counter
Histogram
Span
```

---

# 8. OTel SDK

SDK thực thi API.

Chức năng:

```text
Collect

Process

Export
```

---

# 9. OTel Collector

Thành phần quan trọng nhất.

Vai trò:

```text
Receiver

Processor

Exporter
```

---

Collector giúp:

```text
Tách ứng dụng khỏi backend Observability
```

---

# 10. Lợi ích của OpenTelemetry

## Vendor Neutral

Không phụ thuộc nhà cung cấp.

---

## Chuẩn hóa

Một chuẩn cho toàn ngành.

---

## Cloud Native

Tích hợp Kubernetes tốt.

---

## Dễ mở rộng

Một Collector xuất dữ liệu đến nhiều hệ thống.

---

# 11. Kiến trúc tổng quát

```text
Application
↓
OTel SDK
↓
OTel Collector
↓
Prometheus

Loki

Tempo

Grafana
```

---

# Tổng kết

OpenTelemetry là tiêu chuẩn Observability hiện đại.

Nó cung cấp:

* API
* SDK
* Collector

để thu thập:

```text
Metrics
Logs
Traces
```

và là nền tảng bắt buộc trước khi học OTel Collector Architecture.
