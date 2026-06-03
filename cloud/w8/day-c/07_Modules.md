# Terraform Modules – Tái Sử Dụng Và Chuẩn Hóa Hạ Tầng

## 1. Module Là Gì?

Khi dự án phát triển, việc copy-paste resource liên tục sẽ gây:

* Trùng lặp code
* Khó bảo trì
* Khó mở rộng
* Dễ phát sinh lỗi

Ví dụ:

```hcl
resource "aws_s3_bucket" "logs" {}
resource "aws_s3_bucket_versioning" "logs" {}
resource "aws_s3_bucket_public_access_block" "logs" {}
```

Lặp lại nhiều lần cho:

* logs
* data
* backup
* archive

→ Code trở nên khó quản lý.

Module giúp đóng gói nhiều resource thành một đơn vị tái sử dụng.

---

# 2. Tư Duy Module

Thay vì nghĩ:

```text
S3 Bucket
Versioning
Encryption
Policy
```

hãy nghĩ:

```text
Secure Bucket
```

Module biến nhiều resource thành một khái niệm nghiệp vụ.

Ví dụ:

```text
network-module
database-module
secure-bucket-module
web-cluster-module
```

---

# 3. Root Module Và Child Module

## Root Module

Là thư mục hiện tại chạy:

```bash
terraform init
terraform plan
terraform apply
```

Ví dụ:

```text
project/
 ├── main.tf
 ├── variables.tf
 └── outputs.tf
```

---

## Child Module

Là module được gọi từ Root Module.

Ví dụ:

```text
project/
 ├── main.tf
 └── modules/
      └── secure-bucket/
```

---

# 4. Cấu Trúc Chuẩn Của Module

```text
modules/
 └── secure-bucket/

      ├── variables.tf
      ├── main.tf
      └── outputs.tf
```

---

## variables.tf

Định nghĩa Input.

```hcl
variable "name_prefix" {
  type = string
}
```

---

## main.tf

Logic triển khai.

```hcl
resource "aws_s3_bucket" "this" {
  bucket_prefix = var.name_prefix
}
```

---

## outputs.tf

Xuất dữ liệu.

```hcl
output "id" {
  value = aws_s3_bucket.this.id
}
```

---

# 5. Quy Ước Đặt Tên "this"

HashiCorp khuyến nghị:

```hcl
resource "aws_s3_bucket" "this"
```

thay vì:

```hcl
resource "aws_s3_bucket" "secure_bucket"
```

Lý do:

Tên module đã thể hiện ý nghĩa.

Ví dụ State:

```text
module.logs_bucket.aws_s3_bucket.this
```

rõ ràng hơn.

---

# 6. Gọi Module

```hcl
module "logs_bucket" {

  source = "./modules/secure-bucket"

  name_prefix = "logs-"

}
```

---

## Truyền Input

```hcl
name_prefix = "logs-"
```

giống tham số hàm.

---

# 7. Nhận Output

Module xuất:

```hcl
output "id" {
  value = aws_s3_bucket.this.id
}
```

Sử dụng:

```hcl
module.logs_bucket.id
```

---

# 8. Tái Sử Dụng Module

Một module có thể gọi nhiều lần.

```hcl
module "logs_bucket" {

  source = "./modules/secure-bucket"

  name_prefix = "logs-"

}
```

---

```hcl
module "data_bucket" {

  source = "./modules/secure-bucket"

  name_prefix = "data-"

}
```

---

Terraform sinh:

```text
module.logs_bucket.*
module.data_bucket.*
```

Không xung đột.

---

# 9. Module State Address

Ví dụ:

```text
module.logs_bucket.aws_s3_bucket.this
```

```text
module.logs_bucket.aws_s3_bucket_versioning.this
```

```text
module.data_bucket.aws_s3_bucket.this
```

```text
module.data_bucket.aws_s3_bucket_versioning.this
```

Terraform quản lý hoàn toàn độc lập.

---

# 10. Module Composition

Khái niệm quan trọng nhất của Terraform Module.

---

## Module A

Tạo Bucket.

```hcl
module "data" {

 source = "./modules/secure-bucket"

}
```

---

## Module B

Tạo Object.

```hcl
module "seed" {

 source = "./modules/seed-object"

 bucket_id = module.data.id

}
```

---

## Luồng dữ liệu

```text
Module A
   │
Output
   │
   ▼
Module B
```

---

## Lợi ích

Terraform tự tạo dependency.

```text
Bucket
   ↓
Object
```

Không cần depends_on.

---

# 11. Module Composition Trong Thực Tế

Ví dụ:

```text
Network Module
      ↓
Subnet IDs
      ↓
Compute Module
      ↓
EC2
```

---

```text
Database Module
      ↓
Endpoint
      ↓
Application Module
```

---

# 12. Terraform Registry

Terraform Registry là kho module công cộng.

Chứa:

* AWS Modules
* Azure Modules
* GCP Modules

---

Ví dụ:

```hcl
module "s3" {

 source = "terraform-aws-modules/s3-bucket/aws"

 version = "~> 5.0"

}
```

---

# 13. Terraform Init Và Registry

Khi chạy:

```bash
terraform init
```

Terraform:

```text
Download Module
```

vào:

```text
.terraform/modules/
```

---

# 14. Version Pinning

Cực kỳ quan trọng.

---

## Sai

```hcl
source = "terraform-aws-modules/s3-bucket/aws"
```

---

Terraform luôn tải:

```text
Latest Version
```

có thể gây Breaking Change.

---

## Đúng

```hcl
version = "~> 5.0"
```

---

Ý nghĩa:

Cho phép:

```text
5.0.1
5.0.2
5.3.1
```

Nhưng chặn:

```text
6.0.0
```

---

# 15. Module Sources

## Local Module

```hcl
source = "./modules/network"
```

---

## Registry Module

```hcl
source = "terraform-aws-modules/vpc/aws"
```

---

## Git Module

```hcl
source = "git::https://github.com/org/network.git?ref=v1.2.0"
```

---

# 16. Best Practices

* Module phải giải quyết một bài toán hoàn chỉnh.
* Không tạo module cho một resource đơn lẻ.
* Luôn pin version.
* Dùng Output thay vì đọc State trực tiếp.
* Ưu tiên Composition thay vì depends_on.

---

# 17. Tổng Kết

| Thành phần   | Vai trò                |
| ------------ | ---------------------- |
| Root Module  | Điểm khởi đầu          |
| Child Module | Thành phần tái sử dụng |
| Variables    | Input                  |
| Outputs      | Output                 |
| Registry     | Chia sẻ module         |
| Composition  | Kết nối module         |
