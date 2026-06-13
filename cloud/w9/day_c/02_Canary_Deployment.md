# Canary Deployment

## Khái niệm

Canary Deployment tách biệt:

- Deploy
- Release

Code được triển khai trước nhưng chỉ một phần người dùng được sử dụng.

---

## Kiến trúc

```text
             Traffic Router
              /         \
         90%             10%
           |               |
       Stable V1       Canary V2
```

---

## Quy trình Canary

### Phase 1

90% V1

10% V2

Quan sát:

- Error Rate
- Latency

### Phase 2

75% V1

25% V2

### Phase 3

50% V1

50% V2

### Phase 4

100% V2

0% V1

---

## Lợi ích

### Kiểm soát traffic

Có thể:

- 1%
- 5%
- 10%

Không phụ thuộc số Pod.

### Giảm Blast Radius

Nếu V2 lỗi:

- Chỉ một phần user bị ảnh hưởng

### Rollback cực nhanh

Chỉ cần thay đổi routing rule.

Không cần:

- Redeploy
- Restart Pod

---

## Rolling Update vs Canary

| Tiêu chí | Rolling Update | Canary |
|-----------|---------------|---------|
| Traffic Control | Không | Có |
| Risk | Trung bình | Thấp |
| Rollback | Chậm | Nhanh |
| Observability | Hạn chế | Tốt |
