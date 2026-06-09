# MELT And Three Pillars

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu Three Pillars of Observability.
* Hiểu MELT Framework.
* Biết khi nào sử dụng Metrics, Logs, Traces.
* Hiểu mối quan hệ giữa chúng.

---

# 1. Three Pillars of Observability

Ba trụ cột truyền thống:

```text
Metrics
Logs
Traces
```

---

# 2. Metrics

Metrics là dữ liệu dạng số.

Ví dụ:

```text
CPU = 70%

RAM = 4GB

Latency = 120ms

Requests = 500/s
```

---

Ưu điểm:

* Nhanh
* Nhẹ
* Dễ Alert

---

Nhược điểm:

```text
Thiếu ngữ cảnh
```

---

# 3. Logs

Logs là bản ghi chi tiết.

Ví dụ:

```json
{
  "user":"123",
  "action":"checkout",
  "status":"success"
}
```

---

Logs trả lời:

```text
Điều gì đã xảy ra?
```

---

Ưu điểm:

* Chi tiết
* Điều tra lỗi tốt

---

Nhược điểm:

* Khối lượng lớn
* Tốn lưu trữ

---

# 4. Traces

Trace theo dõi đường đi của request.

Ví dụ:

```text
User
↓
Frontend
↓
API Gateway
↓
Order Service
↓
Database
```

---

Trace cho biết:

```text
Request mất thời gian ở đâu?
```

---

# 5. Events

Framework hiện đại bổ sung:

```text
Events
```

Ví dụ:

```text
Deploy New Version

Scale Cluster

Database Failover
```

---

# 6. MELT Framework

M:

```text
Metrics
```

---

E:

```text
Events
```

---

L:

```text
Logs
```

---

T:

```text
Traces
```

---

# 7. Khi nào dùng Metrics?

Ví dụ:

```text
CPU cao?
Latency tăng?
```

Metrics là lựa chọn đầu tiên.

---

# 8. Khi nào dùng Logs?

Ví dụ:

```text
Tại sao Login thất bại?
```

Logs cung cấp chi tiết.

---

# 9. Khi nào dùng Traces?

Ví dụ:

```text
Request chậm
```

Trace giúp xác định:

```text
Service nào chậm
```

---

# 10. Kết hợp MELT

Ví dụ:

```text
Metrics
↓
Latency tăng
```

---

```text
Trace
↓
Database query chậm
```

---

```text
Logs
↓
Missing Index
```

---

```text
Event
↓
Deploy mới diễn ra
```

---

Nguyên nhân được xác định nhanh chóng.

---

# Tổng kết

MELT là nền tảng của Observability hiện đại:

```text
Metrics
Events
Logs
Traces
```

Mỗi thành phần giải quyết một vấn đề khác nhau và phải được sử dụng cùng nhau.
