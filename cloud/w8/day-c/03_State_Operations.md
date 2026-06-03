# Terraform State Operations

## 1. Tại Sao Cần State Operations?

Terraform quản lý hạ tầng thông qua:

```text
terraform.tfstate
```

State lưu:

* Địa chỉ logic của resource
* ID thực tế trên Cloud
* Metadata
* Dependency

Trong thực tế, hạ tầng thường thay đổi:

* Có tài nguyên tạo thủ công
* Đổi tên resource
* Tách dự án
* Chuyển ownership

Terraform cung cấp các thao tác:

* import
* state mv
* state rm
* moved
* removed

---

# 2. Import Resource Có Sẵn

## Bài toán

Một S3 Bucket đã tồn tại trên AWS.

Ví dụ:

```text
tf-company-backup
```

Bucket được tạo bằng Console.

Terraform chưa quản lý nó.

---

## Cách cũ

```bash
terraform import aws_s3_bucket.data tf-company-backup
```

Hoạt động được nhưng:

* Không lưu lịch sử
* Khó review
* Không phù hợp CI/CD

---

## Cách mới (Terraform 1.5+)

### Khai báo Import Block

```hcl
import {
  to = aws_s3_bucket.adopted
  id = "tf-company-backup"
}
```

---

### Sinh cấu hình tự động

```bash
terraform plan \
-generate-config-out=generated.tf
```

Terraform:

1. Đọc cấu hình thực tế
2. Sinh code Terraform
3. Lưu vào generated.tf

---

### Apply

```bash
terraform apply
```

Kết quả:

```text
1 imported
0 added
0 destroyed
```

Tài nguyên vẫn giữ nguyên trên AWS.

Terraform chỉ bắt đầu quản lý nó.

---

# 3. State Move (state mv)

## Bài toán

Ban đầu:

```hcl
resource "aws_s3_bucket" "adopted" {}
```

Sau này muốn đổi tên:

```hcl
resource "aws_s3_bucket" "data" {}
```

Terraform hiểu nhầm:

```text
Destroy adopted
Create data
```

Điều này cực kỳ nguy hiểm.

---

## Giải pháp

```bash
terraform state mv \
aws_s3_bucket.adopted \
aws_s3_bucket.data
```

Terraform sửa:

```text
State Mapping
```

thay vì sửa hạ tầng.

---

## Kết quả

Trước:

```text
aws_s3_bucket.adopted
```

Sau:

```text
aws_s3_bucket.data
```

Bucket thật không thay đổi.

---

# 4. Moved Block (Terraform 1.1+)

Thay thế state mv bằng code.

```hcl
moved {
  from = aws_s3_bucket.adopted
  to   = aws_s3_bucket.data
}
```

Terraform tự cập nhật State.

Ưu điểm:

* Lưu lịch sử
* Có thể review Git
* Tương thích CI/CD

---

# 5. State Remove (state rm)

## Bài toán

Muốn Terraform ngừng quản lý resource.

Nhưng không muốn xóa resource thật.

---

Ví dụ:

```bash
terraform state rm aws_s3_bucket.data
```

Terraform:

```text
Xóa khỏi State
```

nhưng:

```text
KHÔNG xóa trên AWS
```

---

## Trường hợp sử dụng

* Bàn giao cho team khác
* Tách State
* Quản lý thủ công

---

# 6. Rủi Ro Resource Mồ Côi

Sau state rm:

Terraform không còn biết resource tồn tại.

Ví dụ:

```text
AWS vẫn còn bucket
Terraform không thấy bucket
```

Bucket tiếp tục:

* Chiếm dung lượng
* Tính phí

Nếu quên:

→ phát sinh chi phí ngoài ý muốn.

---

# 7. Removed Block (Terraform 1.7+)

Thay thế state rm.

```hcl
removed {
  from = aws_s3_bucket.data

  lifecycle {
    destroy = false
  }
}
```

---

## Ý nghĩa

```text
Remove from State
Keep on Cloud
```

Terraform Apply:

* Resource biến mất khỏi State
* AWS resource vẫn tồn tại

---

# 8. So Sánh Các Thao Tác

| Thao tác | State | Cloud     |
| -------- | ----- | --------- |
| import   | Thêm  | Không đổi |
| state mv | Sửa   | Không đổi |
| moved    | Sửa   | Không đổi |
| state rm | Xóa   | Không đổi |
| removed  | Xóa   | Không đổi |
| destroy  | Xóa   | Xóa       |

---

# 9. Best Practices

### Ưu tiên

```text
moved
removed
```

thay vì:

```text
state mv
state rm
```

---

### Luôn backup State trước khi thao tác

```bash
cp terraform.tfstate backup.tfstate
```

---

### Kiểm tra State

```bash
terraform state list
```

---

### Xem chi tiết

```bash
terraform state show aws_s3_bucket.data
```

---

# 10. Tổng Kết

| Tính năng | Mục đích                 |
| --------- | ------------------------ |
| import    | Tiếp quản hạ tầng có sẵn |
| state mv  | Đổi tên resource         |
| moved     | Refactor bằng code       |
| state rm  | Bỏ quản lý               |
| removed   | Bỏ quản lý bằng code     |
| destroy   | Xóa hạ tầng              |
