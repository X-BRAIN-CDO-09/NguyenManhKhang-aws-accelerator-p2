# Deployment Strategies Fundamentals

## Mục tiêu

Hiểu các chiến lược triển khai ứng dụng phổ biến trước khi học Progressive Delivery.

---

## 1. Traditional Deployment (Big Bang / Recreate)

### Cơ chế

Phiên bản cũ bị dừng hoàn toàn trước khi phiên bản mới được triển khai.

```text
Version 1
   ↓
Version 2
```

### Nhược điểm

#### Downtime

Có khoảng thời gian hệ thống không phục vụ được request.

#### Blast Radius = 100%

Nếu phiên bản mới lỗi, toàn bộ người dùng bị ảnh hưởng.

#### Rollback chậm

Muốn quay lại phiên bản cũ phải triển khai lại lần nữa.

---

## 2. Rolling Update

Chiến lược mặc định của Kubernetes Deployment.

```text
10 Pods V1

8 V1 + 2 V2

5 V1 + 5 V2

10 Pods V2
```

### Ưu điểm

- Zero Downtime
- Tự động thay thế Pod
- Đơn giản

### Hạn chế

#### Traffic phụ thuộc số lượng Pod

Ví dụ:

- 9 Pod V1
- 1 Pod V2

Traffic ≈ 90% / 10%

Không thể:

- Chạy 10 Pod V2
- Nhưng chỉ nhận 1% traffic

#### Khó phát hiện lỗi ngầm

Ví dụ:

- Memory Leak
- Latency tăng chậm

Deployment có thể hoàn thành trước khi lỗi xuất hiện.

---

## So sánh

| Tiêu chí | Traditional | Rolling Update |
|-----------|------------|----------------|
| Downtime | Có | Không |
| Rollback | Chậm | Trung bình |
| Kiểm soát Traffic | Không | Không |
| Độ an toàn | Thấp | Trung bình |
