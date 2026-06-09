# 05_Terraform_GitOps_Workflow.md

# Terraform GitOps Workflow

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu Plan-on-PR.
* Hiểu Apply-on-Merge.
* Hiểu Infrastructure Review.
* Hiểu GitOps với Terraform.
* Triển khai hạ tầng an toàn trong môi trường doanh nghiệp.

---

# 1. Vấn đề khi quản lý hạ tầng thủ công

Ví dụ:

Developer SSH vào Server.

```bash
ssh production-server
```

Sau đó:

```bash
terraform apply
```

Rủi ro:

* Không ai review
* Không có lịch sử
* Khó audit
* Dễ phá Production

---

# 2. GitOps cho Terraform

Git trở thành:

```text
Single Source of Truth
```

Mọi thay đổi hạ tầng phải:

```text
Code
↓
Pull Request
↓
Review
↓
Merge
↓
Apply
```

---

# 3. Plan-on-PR

## Khái niệm

Khi tạo Pull Request:

Terraform chỉ mô phỏng thay đổi.

Không tạo tài nguyên thật.

---

## Luồng hoạt động

```text
Pull Request
↓
Terraform Fmt
↓
Terraform Validate
↓
Terraform Plan
↓
Comment Result
↓
Review
```

---

# 4. Terraform Fmt

```bash
terraform fmt -check
```

Mục tiêu:

* Chuẩn hóa format
* Đồng nhất code

---

# 5. Terraform Validate

```bash
terraform validate
```

Kiểm tra:

* Syntax
* Provider
* Resource Definition

---

# 6. Terraform Plan

```bash
terraform plan
```

Kết quả:

```text
+ create
~ update
- destroy
```

Ví dụ:

```text
Plan:

2 to add
1 to change
0 to destroy
```

---

# 7. Comment kết quả lên Pull Request

Ví dụ:

```text
Terraform Plan Result

+ aws_instance.web

~ aws_security_group.web

No Destroy Action
```

Reviewer có thể xem trực tiếp.

---

# 8. Quy tắc vàng

Trong Pull Request:

```text
KHÔNG BAO GIỜ
terraform apply
```

Chỉ được:

```text
terraform plan
```

---

# 9. Apply-on-Merge

Sau khi PR được duyệt.

```text
Approve
↓
Merge
↓
Main Branch
↓
Terraform Apply
```

---

## Workflow

```text
Push Main
↓
Terraform Init
↓
Terraform Apply
```

---

# 10. Terraform Apply

```bash
terraform apply -auto-approve
```

Lúc này:

* AWS API
* Azure API
* GCP API

được gọi thực sự.

---

# 11. Tại sao Apply chỉ chạy trên Main?

Nếu cho phép:

```text
Developer Laptop
```

chạy Apply trực tiếp:

Rủi ro:

* Drift
* Sai môi trường
* Mất kiểm soát

Do đó:

```text
Main Branch
=
Nguồn duy nhất được phép Apply
```

---

# 12. GitOps Flow hoàn chỉnh

```text
Developer
↓
Terraform Code
↓
Feature Branch
↓
Pull Request
↓
Plan
↓
Review
↓
Approve
↓
Merge
↓
Apply
↓
Cloud Infrastructure
```

---

# 13. Ví dụ thực tế

Developer thêm EC2:

```hcl
resource "aws_instance" "web" {

}
```

---

## Pull Request

Pipeline chạy:

```bash
terraform plan
```

Kết quả:

```text
+ aws_instance.web
```

Reviewer thấy:

```text
1 EC2 sẽ được tạo
```

---

## Sau khi Merge

Pipeline chạy:

```bash
terraform apply
```

AWS mới thực sự tạo EC2.

---

# 14. Lợi ích của Plan-on-PR

## An toàn

Không thay đổi hạ tầng thật.

---

## Minh bạch

Ai cũng thấy thay đổi.

---

## Audit

Lưu lịch sử trên Git.

---

## Compliance

Đáp ứng yêu cầu doanh nghiệp.

---

# 15. Pipeline doanh nghiệp tiêu chuẩn

Pull Request:

```text
fmt
↓
validate
↓
plan
↓
review
```

Main:

```text
apply
```

---

# 16. Sai lầm phổ biến

## Apply từ máy cá nhân

Không khuyến khích.

---

## Bỏ qua Review

Rất nguy hiểm.

---

## Apply trực tiếp Production

Không tuân thủ GitOps.

---

## Không lưu Plan Output

Khó audit.

---

# Tổng kết

Terraform GitOps dựa trên nguyên tắc:

```text
Plan-on-PR
Apply-on-Merge
```

Đây là mô hình được sử dụng rộng rãi trong:

* AWS
* Azure
* GCP
* Kubernetes Platform Teams
* DevOps Teams
* SRE Teams

và là nền tảng trước khi học:

* Multi Environment Terraform
* GitOps
* ArgoCD
* App of Apps
* ApplicationSet
