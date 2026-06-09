# Burn Rate

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu Burn Rate.
- Biết cách tính Burn Rate.
- Hiểu Multi-Window Alerting.
- Biết cách cảnh báo sớm vi phạm SLO.

---

# 1. Burn Rate là gì?

Burn Rate là tốc độ tiêu hao Error Budget.

Nói đơn giản:

"Chúng ta đang đốt Error Budget nhanh đến mức nào?"

---

# 2. Công thức

Burn Rate

=

Actual Error Rate
/
Allowed Error Rate

---

# 3. Ví dụ

SLO:

99.9%

Allowed Error:

0.1%

---

Thực tế:

0.1%

Burn Rate = 1

---

# 4. Burn Rate = 1

Error Budget sẽ hết đúng kế hoạch.

Ví dụ:

30 ngày

↓

Hết sau 30 ngày

---

# 5. Burn Rate = 2

Tiêu hao nhanh gấp đôi.

↓

Hết sau 15 ngày

---

# 6. Burn Rate = 10

Tiêu hao nhanh gấp 10 lần.

↓

Hết sau 3 ngày

---

# 7. Burn Rate = 14.4

Google SRE thường dùng.

↓

Error Budget hết trong khoảng 50 giờ.

---

# 8. Tại sao Burn Rate quan trọng?

Availability hiện tại:

99.95%

Có vẻ ổn.

---

Nhưng:

Burn Rate = 20

↓

Sẽ sớm vi phạm SLO.

---

# 9. Multi-Window Alerting

Google SRE khuyến nghị:

Window ngắn:

5 phút

---

Window dài:

1 giờ

---

Hoặc:

30 phút + 6 giờ

---

# 10. Ví dụ Alert

Critical:

Burn Rate > 14.4

---

Warning:

Burn Rate > 2

---

# 11. Lợi ích

- Phát hiện sớm sự cố.
- Tránh vi phạm SLO.
- Giảm Alert Noise.

---

# 12. Best Practices

Alert theo:

- Burn Rate
- Error Budget

Thay vì:

- CPU
- Memory

---

# Tổng kết

Burn Rate là chỉ số quan trọng nhất sau Error Budget.

Cần nhớ:

Burn Rate = 1

→ Bình thường

Burn Rate > 1

→ Đang đốt ngân sách lỗi nhanh hơn kế hoạch

Burn Rate >> 1

→ Sắp vi phạm SLO