# Error Budget

## Mục tiêu học tập

Sau bài học này bạn sẽ:

- Hiểu Error Budget.
- Biết cách tính Error Budget.
- Hiểu mối quan hệ giữa Reliability và Velocity.
- Biết cách sử dụng Error Budget trong SRE.

---

# 1. Error Budget là gì?

Error Budget là phần lỗi được phép xảy ra.

Công thức:

Error Budget

=

100%

-

SLO

---

# 2. Ví dụ

SLO:

99.9%

Error Budget:

0.1%

---

# 3. Ý nghĩa

Hệ thống không cần hoàn hảo.

Cho phép:

0.1%

request thất bại.

---

# 4. Ví dụ theo Request

1.000.000 request/tháng

SLO:

99.9%

---

Error Budget:

0.1%

=

1000 request lỗi

---

# 5. Ví dụ theo Downtime

99%

→ 7h12m/tháng

99.9%

→ 43m12s/tháng

99.95%

→ 21m36s/tháng

99.99%

→ 4m19s/tháng

---

# 6. Reliability vs Velocity

Muốn Reliability cao:

↓

Deploy ít

↓

Ít rủi ro

---

Muốn Velocity cao:

↓

Deploy nhiều

↓

Rủi ro tăng

---

Error Budget cân bằng hai yếu tố này.

---

# 7. Khi Budget còn nhiều

Cho phép:

- Deploy nhanh
- Release Feature
- Experiment

---

# 8. Khi Budget gần hết

Tạm dừng:

- Feature mới
- Thay đổi lớn

Ưu tiên:

- Bug Fix
- Stability

---

# 9. Error Budget Policy

Ví dụ:

Budget > 50%

→ Bình thường

---

Budget < 25%

→ Review

---

Budget < 10%

→ Freeze Release

---

# 10. Lợi ích

- Giảm tranh cãi giữa Dev và Ops.
- Có cơ sở dữ liệu để quyết định.
- Tập trung vào trải nghiệm người dùng.

---

# Tổng kết

Error Budget:

100%

-

SLO

Là khái niệm trung tâm của SRE hiện đại.