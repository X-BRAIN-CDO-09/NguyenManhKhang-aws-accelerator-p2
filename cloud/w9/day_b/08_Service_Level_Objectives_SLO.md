# Service Level Objectives (SLO)

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu SLO là gì.
- Hiểu cách xây dựng SLO.
- Biết cách chọn mục tiêu phù hợp.
- Hiểu vì sao không nên đặt 100%.

---

# 1. SLO là gì?

SLO (Service Level Objective) là mục tiêu chất lượng mà hệ thống phải đạt được.

Ví dụ:

SLI hiện tại:

99.92%

SLO:

99.90%

→ Đạt

---

# 2. SLI vs SLO

SLI:

Đang đạt bao nhiêu?

SLO:

Phải đạt tối thiểu bao nhiêu?

---

# 3. Ví dụ thực tế

Availability:

SLI:

99.93%

SLO:

99.90%

---

Latency:

SLI:

95% < 250ms

SLO:

95% < 300ms

---

# 4. Tại sao không đặt 100%?

100% Availability gần như không tồn tại.

Vì:

- Hardware Failure
- Software Bug
- Network Failure
- Human Error

---

# 5. Chi phí của 100%

99%

→ Dễ đạt

99.9%

→ Khó hơn

99.99%

→ Rất đắt

99.999%

→ Cực kỳ đắt

---

# 6. Mức SLO phổ biến

| SLO | Độ phổ biến |
|-------|------------|
| 99% | Internal App |
| 99.9% | SaaS phổ thông |
| 99.95% | Production |
| 99.99% | Critical System |
| 99.999% | Banking/Telecom |

---

# 7. SLO theo loại dịch vụ

Internal Dashboard

99%

---

Business API

99.9%

---

Payment

99.99%

---

Banking Core

99.999%

---

# 8. Composite SLO

Ví dụ:

Availability

99.9%

AND

Latency

95% < 300ms

---

# 9. SLO và Alerting

Không alert theo CPU.

Alert theo:

SLI gần vi phạm SLO.

Ví dụ:

Availability giảm xuống:

99.92%

→ Cảnh báo

---

# 10. Best Practices

- Chọn SLO theo nhu cầu kinh doanh.
- Không đặt quá cao.
- Không đặt quá thấp.
- Dựa trên dữ liệu thực tế.

---

# Tổng kết

SLO là mục tiêu chất lượng dịch vụ.

Các mức phổ biến:

- 99%
- 99.9%
- 99.95%
- 99.99%