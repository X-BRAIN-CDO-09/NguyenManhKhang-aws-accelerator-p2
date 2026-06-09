# Observability Fundamentals

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu Observability là gì.
* Phân biệt Monitoring và Observability.
* Hiểu tại sao hệ thống Cloud Native cần Observability.
* Hiểu khái niệm Unknown Unknown.
* Nắm được tư duy cốt lõi của SRE và Platform Engineering.

---

# 1. Observability là gì?

Observability là khả năng hiểu được trạng thái bên trong của một hệ thống dựa trên dữ liệu mà hệ thống đó tạo ra.

Nói đơn giản:

```text
Nếu hệ thống gặp sự cố,
bạn có thể trả lời:

Điều gì đang xảy ra?
Tại sao nó xảy ra?
Làm sao để khắc phục?
```

---

# 2. Tại sao cần Observability?

Trong hệ thống Monolithic truyền thống:

```text
Application
↓
Database
```

việc tìm lỗi khá đơn giản.

---

Trong kiến trúc hiện đại:

```text
Frontend
↓
API Gateway
↓
Microservices
↓
Redis
↓
Kafka
↓
Database
```

một request có thể đi qua hàng chục thành phần.

---

Khi xảy ra lỗi:

```text
User
↓
Timeout
```

Câu hỏi là:

```text
Lỗi ở đâu?
API?
Database?
Network?
Cache?
```

Monitoring truyền thống thường không trả lời được.

---

# 3. Monitoring là gì?

Monitoring là việc:

```text
Thu thập dữ liệu
↓
Hiển thị Dashboard
↓
Tạo Alert
```

Ví dụ:

* CPU
* RAM
* Disk
* Network

---

Monitoring giúp trả lời:

```text
Điều gì đang xảy ra?
```

Ví dụ:

```text
CPU = 95%
```

Nhưng không giải thích được:

```text
Tại sao CPU lại 95%?
```

---

# 4. Observability là gì?

Observability đi xa hơn Monitoring.

Observability trả lời:

```text
What happened?
Why did it happen?
How can we fix it?
```

---

Ví dụ

Monitoring:

```text
API latency = 3s
```

Observability:

```text
API latency = 3s

↓

Database query mất 2.5s

↓

Nguyên nhân:
Missing Index
```

---

# 5. Unknown Unknowns

Đây là lý do Observability ra đời.

---

Known Problems

```text
CPU cao
Disk đầy
```

---

Unknown Problems

```text
Lỗi chưa từng xảy ra
```

Ví dụ:

```text
Service A

↓

Kafka

↓

Service B

↓

Database

↓

Timeout
```

Không ai biết lỗi nằm ở đâu.

Observability giúp lần theo toàn bộ đường đi.

---

# 6. Ba câu hỏi quan trọng

Khi vận hành hệ thống:

### Điều gì xảy ra?

```text
Request tăng đột biến
```

---

### Tại sao xảy ra?

```text
Marketing Campaign
```

---

### Hậu quả là gì?

```text
Database quá tải
```

---

# 7. Quan hệ với DevOps và SRE

DevOps:

```text
Build
Deploy
Operate
```

---

SRE:

```text
Reliability
Availability
Performance
```

---

Observability là nền tảng của SRE.

Nếu không quan sát được hệ thống:

```text
Không thể cải thiện độ tin cậy
```

---

# 8. Mục tiêu cuối cùng

Observability không phải:

```text
Dashboard đẹp
```

Mà là:

```text
Giảm MTTR
```

MTTR:

```text
Mean Time To Recovery
```

Tức:

```text
Thời gian từ lúc lỗi xảy ra
đến lúc sửa xong
```

---

# Tổng kết

Observability giúp:

* Hiểu hệ thống
* Điều tra nguyên nhân lỗi
* Giảm thời gian khắc phục sự cố
* Hỗ trợ DevOps và SRE

Nó là nền tảng trước khi học:

* Metrics
* Logs
* Traces
* OpenTelemetry
* SLI/SLO
* Error Budget
