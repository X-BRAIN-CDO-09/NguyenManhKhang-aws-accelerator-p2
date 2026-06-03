# Multiple Environments, Workspaces Và Terraform Remote State

## 1. Vì Sao Cần Nhiều Environment?

Trong doanh nghiệp thường có:

```text
Dev
Staging
Production
```

---

### Dev

Dùng để phát triển.

---

### Staging

Dùng để kiểm thử.

---

### Production

Hệ thống thật.

---

Nếu dùng chung một State:

```text
terraform.tfstate
```

sẽ xảy ra:

* Ghi đè tài nguyên
* Xung đột tên
* Không tách biệt môi trường

---

# 2. Workspaces

Terraform cho phép nhiều State trong cùng một thư mục.

---

## Tạo Workspace

```bash
terraform workspace new dev
```

```bash
terraform workspace new prod
```

---

## Chuyển Workspace

```bash
terraform workspace select dev
```

---

## Xem Workspace

```bash
terraform workspace show
```

---

# 3. Biến terraform.workspace

Terraform cung cấp:

```hcl
terraform.workspace
```

---

Ví dụ:

```hcl
locals {

 instance_type = terraform.workspace == "prod"
   ? "t3.small"
   : "t3.micro"

}
```

---

## Đặt Tên Resource Theo Workspace

```hcl
bucket_prefix = "app-${terraform.workspace}-"
```

---

Kết quả:

```text
app-dev
app-prod
```

---

# 4. Hạn Chế Của Workspace

HashiCorp không khuyến nghị dùng cho Production.

---

## Vấn đề 1

Chung Credentials.

```text
Dev User
=
Prod User
```

---

## Vấn đề 2

Dễ thao tác nhầm.

Ví dụ:

```bash
terraform destroy
```

trong workspace prod.

---

## Vấn đề 3

Blast Radius lớn.

Một lỗi có thể ảnh hưởng toàn bộ hệ thống.

---

# 5. Directory Layout

Đây là giải pháp doanh nghiệp sử dụng.

---

## Cấu trúc

```text
project/

 ├── modules/

 │    └── app/

 └── environments/

      ├── dev/
      │    └── main.tf

      └── prod/
           └── main.tf
```

---

# 6. Environment Dev

```hcl
provider "aws" {

 profile = "dev"

}
```

---

## Backend

```hcl
backend "s3" {

 key = "dev/app.tfstate"

}
```

---

# 7. Environment Prod

```hcl
provider "aws" {

 profile = "prod"

}
```

---

```hcl
backend "s3" {

 key = "prod/app.tfstate"

}
```

---

## Kết quả

```text
Dev State
```

hoàn toàn tách biệt khỏi:

```text
Prod State
```

---

# 8. So Sánh Workspace Và Directory Layout

| Tiêu chí   | Workspace         | Directory   |
| ---------- | ----------------- | ----------- |
| Thư mục    | 1                 | Nhiều       |
| Backend    | Chung             | Tách biệt   |
| IAM        | Chung             | Riêng       |
| An toàn    | Thấp              | Cao         |
| Production | Không khuyến nghị | Khuyến nghị |

---

# 9. terraform_remote_state

Cho phép:

```text
State A
    ↓
State B
```

---

## Bài toán

Network tạo:

```text
VPC
Subnet
```

---

Compute cần:

```text
Subnet ID
```

---

# 10. Output Từ Network

```hcl
output "subnet_ids" {

 value = aws_subnet.public[*].id

}
```

---

# 11. Đọc Remote State

```hcl
data "terraform_remote_state" "network" {

 backend = "s3"

 config = {

   bucket = "tf-state"

   key = "network/terraform.tfstate"

 }

}
```

---

## Sử dụng

```hcl
data.terraform_remote_state.network.outputs.subnet_ids
```

---

# 12. Luồng Kiến Trúc

```text
Network Layer
      │
      ▼
terraform_remote_state
      │
      ▼
Compute Layer
```

---

# 13. Ưu Điểm

* Tách State
* Tách Team
* Tách CI/CD
* Giảm Blast Radius

---

# 14. Lưu Ý Bảo Mật

Remote State chỉ đọc:

```text
Outputs
```

không đọc toàn bộ Resource.

---

Vì vậy:

```hcl
output "vpc_id" {}
```

là Contract giữa các Layer.

---

# 15. Best Practices

### Production

Dùng:

```text
Directory Layout
```

---

### Không dùng

```text
Workspace
```

để phân tách Prod.

---

### Chia hệ thống thành Layer

```text
Network
Compute
Database
Application
```

---

### Kết nối Layer

Thông qua:

```text
terraform_remote_state
```

---

# 16. Tổng Kết

| Thành phần       | Vai trò                   |
| ---------------- | ------------------------- |
| Workspace        | Nhiều State cùng cấu hình |
| Directory Layout | Tách môi trường hoàn toàn |
| Remote State     | Chia sẻ Output            |
| Output           | Contract giữa các Layer   |
| Production       | Ưu tiên Directory Layout  |
