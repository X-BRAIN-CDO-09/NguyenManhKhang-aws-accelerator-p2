# Remote State Trên AWS S3 Và Native Locking

## 1. Tại Sao Local State Không Đủ?

Khi làm cá nhân:

```text
terraform.tfstate
```

lưu trên máy là đủ.

Nhưng trong môi trường Team sẽ xuất hiện nhiều vấn đề.

### Không chia sẻ được

Đồng nghiệp không có state file.

Terraform mất khả năng quản lý hạ tầng.

---

### Nguy cơ lộ dữ liệu

State file chứa:

* Password
* Access Key
* ARN
* Endpoint

Dưới dạng Plain Text.

Nếu commit lên Git:

```text
Rò rỉ thông tin hệ thống
```

---

### Xung đột ghi đồng thời

Hai kỹ sư chạy:

```bash
terraform apply
```

cùng lúc.

State có thể bị ghi đè.

Dẫn tới:

* Drift
* Corrupt State
* Hạ tầng sai lệch

---

## 2. Remote State Là Gì?

Lưu State ở nơi tập trung.

Ví dụ:

```text
AWS S3
```

Ưu điểm:

* Chia sẻ cho team
* Sao lưu tập trung
* Mã hóa dữ liệu
* Khóa trạng thái

---

# 3. Bài Toán Bootstrap

Muốn lưu State lên S3.

Nhưng S3 phải tồn tại trước.

Đây gọi là:

```text
Chicken & Egg Problem
```

Giải pháp:

### Bước 1

Tạo S3 bằng Local State.

### Bước 2

Dùng S3 đó làm Backend.

---

# 4. Tạo State Bucket Chuẩn

## Bucket

```hcl
resource "aws_s3_bucket" "state" {
  bucket_prefix = "tf-state-"
}
```

---

## Versioning

```hcl
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

Mục đích:

* Khôi phục State cũ
* Chống lỗi ghi đè

---

## Encryption

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

Mục đích:

```text
Mã hóa dữ liệu khi lưu trữ
```

---

## Chặn Public Access

```hcl
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

# 5. Cấu Hình S3 Backend

```hcl
terraform {

  backend "s3" {

    bucket = "terraform-state"

    key = "app/terraform.tfstate"

    region = "ap-southeast-1"

    encrypt = true

    use_lockfile = true
  }
}
```

---

## Ý Nghĩa Các Thuộc Tính

### bucket

Tên bucket chứa state.

### key

Đường dẫn file state.

Ví dụ:

```text
app/terraform.tfstate
```

### region

Vùng AWS.

### encrypt

Bật mã hóa.

### use_lockfile

Khóa trạng thái native trên S3.

---

# 6. Native Locking

Terraform mới không còn khuyến nghị:

```text
S3 + DynamoDB
```

Thay bằng:

```hcl
use_lockfile = true
```

---

# 7. Cách use_lockfile Hoạt Động

Terraform tạo:

```text
terraform.tfstate.tflock
```

Nếu file chưa tồn tại:

```text
Lock thành công
```

Terraform được phép Apply.

Nếu file tồn tại:

```text
PreconditionFailed
```

Terraform từ chối chạy.

---

# 8. Lock Conflict

Ví dụ:

```text
Error acquiring state lock
```

Thông tin hiển thị:

* Ai đang giữ lock
* Thời gian tạo lock
* Loại operation

Ví dụ:

```text
Who: ops@workstation
Operation: Apply
```

---

# 9. Force Unlock

Nếu tiến trình bị crash:

```bash
terraform force-unlock LOCK_ID
```

Terraform xóa lock thủ công.

---

# 10. DynamoDB vs use_lockfile

| Tiêu chí  | DynamoDB      | use_lockfile |
| --------- | ------------- | ------------ |
| Dịch vụ   | S3 + DynamoDB | Chỉ S3       |
| Chi phí   | Cao hơn       | Thấp hơn     |
| Cấu hình  | Phức tạp      | Đơn giản     |
| Tương lai | Deprecated    | Khuyến nghị  |

---

# 11. Best Practices

* Luôn dùng Remote State.
* Bật Versioning.
* Bật Encryption.
* Chặn Public Access.
* Dùng use_lockfile.
* Không commit state lên Git.
* Mỗi môi trường nên có State riêng.
