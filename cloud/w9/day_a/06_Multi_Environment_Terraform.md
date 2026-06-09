# 06_Multi_Environment_Terraform.md

# Multi Environment Terraform

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu lý do phải tách môi trường.
* Hiểu Terraform State Isolation.
* Hiểu Backend riêng cho từng môi trường.
* Hiểu Environment Secrets.
* Biết cách tổ chức Terraform Project theo chuẩn doanh nghiệp.
* Hiểu Terraform Workspace và Directory-based Structure.

---

# 1. Tại sao phải tách môi trường?

Trong doanh nghiệp, không bao giờ dùng chung một môi trường cho mọi mục đích.

Thông thường sẽ có:

```text
Development (DEV)
↓
Staging (STG)
↓
Production (PROD)
```

Mỗi môi trường có mục tiêu khác nhau:

| Environment | Mục đích           |
| ----------- | ------------------ |
| DEV         | Developer kiểm thử |
| STAGING     | Kiểm thử tích hợp  |
| PROD        | Phục vụ khách hàng |

---

# 2. Rủi ro khi dùng chung môi trường

Ví dụ:

Developer thử nghiệm:

```hcl
resource "aws_db_instance" "test" {

}
```

Sau đó:

```bash
terraform destroy
```

Nếu dùng chung môi trường:

```text
DEV
=
PROD
```

Hậu quả:

```text
Production Database
↓
Deleted
↓
System Outage
```

---

# 3. Terraform State là gì?

Terraform sử dụng file:

```text
terraform.tfstate
```

để lưu:

* Resource ID
* Resource Mapping
* Dependency Graph
* Current Infrastructure State

---

## Ví dụ

Terraform Code:

```hcl
resource "aws_instance" "web" {

}
```

State:

```json
{
  "id": "i-123456"
}
```

Terraform dùng State để biết:

```text
Code
↔
Infrastructure
```

đang đồng bộ hay không.

---

# 4. State Isolation

Nguyên tắc:

```text
1 Environment
=
1 State File
```

Không dùng chung state.

---

## Sai

```text
terraform.tfstate

DEV
STAGING
PROD
```

---

## Đúng

```text
DEV
↓
terraform-dev.tfstate

STAGING
↓
terraform-staging.tfstate

PROD
↓
terraform-prod.tfstate
```

---

# 5. Backend riêng cho từng môi trường

Ví dụ S3 Backend:

```text
s3://company-tfstate/dev/terraform.tfstate

s3://company-tfstate/staging/terraform.tfstate

s3://company-tfstate/prod/terraform.tfstate
```

---

## Lợi ích

### Isolation

Không ảnh hưởng nhau.

### Security

Quản lý quyền riêng.

### Recovery

Khôi phục từng môi trường.

---

# 6. Environment Secrets

Mỗi môi trường cần:

```text
AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY
```

riêng biệt.

---

## Ví dụ

DEV

```text
Limited Permission
```

---

STAGING

```text
Medium Permission
```

---

PROD

```text
Administrator Permission
```

---

# 7. GitHub Environments

GitHub hỗ trợ:

```text
Settings
↓
Environments
```

Ví dụ:

```text
development

staging

production
```

---

## Mỗi Environment có

* Secrets riêng
* Approval riêng
* Policy riêng

---

# 8. Directory-based Structure

Đây là cách phổ biến nhất.

```text
terraform-infra/

├── modules/
│
├── environments/
│
│   ├── dev/
│   │
│   ├── staging/
│   │
│   └── prod/
```

---

# 9. Modules

Module là thành phần tái sử dụng.

Ví dụ:

```text
modules/

vpc/

ec2/

rds/

eks/
```

---

## Ví dụ

```hcl
module "vpc" {

}
```

---

# 10. Environment Folder

DEV

```text
environments/dev

main.tf

variables.tf

backend.tf
```

---

PROD

```text
environments/prod

main.tf

variables.tf

backend.tf
```

---

# 11. Terraform Workspace

Terraform hỗ trợ:

```bash
terraform workspace
```

---

## Tạo Workspace

```bash
terraform workspace new dev

terraform workspace new staging

terraform workspace new prod
```

---

## Chuyển Workspace

```bash
terraform workspace select dev
```

---

# 12. Directory vs Workspace

| Tiêu chí   | Directory | Workspace |
| ---------- | --------- | --------- |
| Dễ hiểu    | ✅         | ❌         |
| Tách biệt  | ✅         | ⚠️        |
| Dễ học     | ✅         | ❌         |
| Enterprise | ✅         | ✅         |

---

# 13. Best Practices

## Không dùng Local State

Sai:

```text
terraform.tfstate
```

---

## Dùng Remote Backend

Ví dụ:

* S3
* Azure Blob
* GCS

---

## Enable State Locking

Ví dụ:

```text
AWS DynamoDB Lock
```

Ngăn:

```text
2 người Apply cùng lúc
```

---

## Tách Environment

Luôn:

```text
DEV

STAGING

PROD
```

---

# 14. Luồng Terraform Enterprise

```text
Developer
↓
Feature Branch
↓
Pull Request
↓
Terraform Plan
↓
Review
↓
Merge
↓
Terraform Apply
↓
DEV

STAGING

PROD
```

---

# Tổng kết

Nguyên tắc quan trọng:

```text
One Environment
=
One State
=
One Backend
```

Đây là nền tảng bắt buộc trước khi triển khai GitOps và ArgoCD.
