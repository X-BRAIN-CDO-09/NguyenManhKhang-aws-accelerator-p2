# Secrets Management Trong Terraform

## 1. Vấn Đề Của Secret Trong Terraform

Terraform thường xử lý:

* Password
* Token
* API Key
* Secret Key
* Database Connection String

Ví dụ:

```hcl
variable "db_password" {
  type = string
}
```

Nếu không xử lý đúng:

```text
Secret sẽ bị lưu trong State
```

---

# 2. Sensitive Attribute

## Khai báo

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

---

## Output Sensitive

```hcl
output "password" {
  value     = var.db_password
  sensitive = true
}
```

---

## Kết quả

CLI hiển thị:

```text
(sensitive value)
```

thay vì giá trị thực.

---

## Hiểu lầm phổ biến

Nhiều người nghĩ:

```text
sensitive = true
```

đã bảo mật hoàn toàn.

Điều này sai.

---

## Thực tế

State vẫn chứa:

```json
{
  "db_password": "SuperSecret123"
}
```

dưới dạng plaintext.

---

# 3. State Vẫn Là Điểm Rò Rỉ

Bất kỳ ai đọc được:

```text
terraform.tfstate
```

đều có thể xem:

* Password
* Token
* Connection String

Vì vậy:

```text
Sensitive chỉ che trên màn hình
Không bảo vệ State
```

---

# 4. Ephemeral Resource (Terraform 1.10+)

## Mục tiêu

Đọc secret nhưng không lưu vào State.

---

## Cách cũ

```text
Vault
 ↓
Data Source
 ↓
State
```

Secret bị lưu lại.

---

## Cách mới

```text
Vault
 ↓
Ephemeral
 ↓
Memory
 ↓
Apply
```

Không lưu State.

---

## Đặc điểm

Ephemeral:

* Chỉ tồn tại trong phiên chạy
* Chỉ nằm trong RAM
* Bị hủy sau Apply

---

## Lợi ích

```text
No Secret In State
```

---

# 5. Write-Only Arguments (_wo)

Terraform 1.11+

---

## Mục tiêu

Gửi Secret lên Cloud.

Nhưng không lưu Secret trong State.

---

## Ví dụ

```hcl
secret_string_wo = var.password

secret_string_wo_version = 1
```

---

## Cơ chế

Terraform:

```text
Password
    ↓
Provider API
    ↓
AWS
```

Sau đó:

```text
Discard Secret
```

---

## State Lưu Gì?

State:

```json
{
  "secret_string_wo": null,
  "secret_string_wo_version": 1
}
```

Không lưu giá trị thật.

---

# 6. Khi Muốn Đổi Password

Tăng version.

Ví dụ:

```hcl
secret_string_wo_version = 2
```

Terraform hiểu:

```text
Rotate Secret
```

và ghi lại giá trị mới.

---

# 7. Mô Hình Bảo Mật Chuẩn

## Sai

```text
Hardcode Password
       ↓
Terraform
       ↓
State
```

---

## Đúng

```text
AWS Secrets Manager
          ↓
Ephemeral
          ↓
Write Only Argument
          ↓
AWS Resource
```

State không chứa Secret.

---

# 8. Variable, Local, Output

## Variable

Đầu vào.

```hcl
variable "environment" {}
```

Nguồn dữ liệu:

1. terraform.tfvars
2. TF_VAR_xxx
3. -var

---

## Local

Biến trung gian.

```hcl
locals {
  bucket_name = "${var.project}-${var.environment}"
}
```

Giúp:

* Tái sử dụng
* Tránh lặp code

---

## Output

Đầu ra.

```hcl
output "bucket_id" {
  value = aws_s3_bucket.app.id
}
```

---

# 9. Luồng Dữ Liệu Trong Terraform

```text
Variable
    ↓
Local
    ↓
Resource
    ↓
Output
```

---

# 10. So Sánh Các Cơ Chế Secret

| Tính năng  | CLI  | State     |
| ---------- | ---- | --------- |
| sensitive  | Ẩn   | Lưu       |
| ephemeral  | Ẩn   | Không lưu |
| write-only | Ẩn   | Không lưu |
| hardcode   | Hiện | Lưu       |

---

# 11. Best Practices

Không hardcode:

```hcl
password = "admin123"
```

---

Dùng:

```text
AWS Secrets Manager
HashiCorp Vault
SSM Parameter Store
```

---

Bật Remote State Encryption.

---

Hạn chế quyền truy cập State.

---

Ưu tiên:

```text
ephemeral
+
write-only
```

cho môi trường Production.

---

# 12. Tổng Kết

| Công cụ    | Vai trò            |
| ---------- | ------------------ |
| sensitive  | Che trên CLI       |
| ephemeral  | Đọc secret an toàn |
| write-only | Ghi secret an toàn |
| variable   | Nhận dữ liệu       |
| local      | Xử lý dữ liệu      |
| output     | Xuất dữ liệu       |
