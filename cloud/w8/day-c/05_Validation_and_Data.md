# Validation, Preconditions, Postconditions, Check Blocks Và Data Sources

## 1. Tại Sao Cần Validation?

Terraform mặc định tin tưởng mọi giá trị đầu vào.

Ví dụ:

```hcl
variable "instance_type" {
  type = string
}
```

Người dùng hoàn toàn có thể nhập:

```hcl
instance_type = "abcxyz"
```

Terraform chỉ phát hiện lỗi khi gọi API AWS.

Điều này gây:

* Mất thời gian Apply
* Khó debug
* Lỗi xuất hiện quá muộn

---

# 2. Variable Validation

## Cú pháp

```hcl
variable "instance_type" {

  type = string

  validation {
    condition = contains(
      ["t3.micro", "t3.small", "t3.medium"],
      var.instance_type
    )

    error_message = "Instance type không hợp lệ."
  }
}
```

---

## Cơ chế

Terraform kiểm tra trước khi Plan.

Nếu sai:

```text
Error:
Instance type không hợp lệ
```

Terraform dừng ngay lập tức.

---

## Ví dụ Validation CIDR

```hcl
variable "vpc_cidr" {

  type = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr,0))
    error_message = "CIDR không hợp lệ."
  }
}
```

---

## Hàm thường dùng

### contains()

```hcl
contains(["dev","prod"], var.env)
```

---

### can()

```hcl
can(regex("^10\\.", var.ip))
```

---

### regex()

```hcl
regex("^prod-", var.name)
```

---

# 3. Preconditions

## Mục tiêu

Kiểm tra điều kiện trước khi Resource được tạo.

---

## Ví dụ

```hcl
resource "aws_instance" "web" {

  instance_type = "t3.micro"

  lifecycle {

    precondition {

      condition = data.aws_ami.al2023.architecture == "x86_64"

      error_message = "AMI phải là x86_64"
    }
  }
}
```

---

## Khi nào dùng?

Validation:

```text
Kiểm tra Input
```

Precondition:

```text
Kiểm tra môi trường
```

---

# 4. Postconditions

## Mục tiêu

Kiểm tra sau khi Resource được tạo.

---

## Ví dụ

```hcl
resource "aws_s3_bucket" "logs" {

  bucket_prefix = "logs-"

  lifecycle {

    postcondition {

      condition = self.versioning_enabled

      error_message = "Bucket phải bật versioning."
    }
  }
}
```

---

## Luồng hoạt động

```text
Create Resource
        ↓
Check Postcondition
        ↓
Pass / Fail
```

---

# 5. Validation vs Preconditions vs Postconditions

| Tính năng     | Thời điểm    |
| ------------- | ------------ |
| Validation    | Trước Plan   |
| Precondition  | Trước Create |
| Postcondition | Sau Create   |

---

# 6. Check Blocks

Terraform 1.5+

---

## Mục tiêu

Kiểm tra trạng thái hệ thống.

Không làm Apply thất bại.

---

## Ví dụ

```hcl
check "website_health" {

  assert {

    condition = data.http.website.status_code == 200

    error_message = "Website đang lỗi."
  }
}
```

---

## Kết quả

Nếu lỗi:

```text
Warning:
Website đang lỗi
```

Terraform vẫn Apply thành công.

---

## So sánh

| Tính năng     | Fail Apply |
| ------------- | ---------- |
| Validation    | Có         |
| Precondition  | Có         |
| Postcondition | Có         |
| Check         | Không      |

---

# 7. Data Sources

## Khái niệm

Data Source cho phép:

```text
ĐỌC
```

thông tin từ bên ngoài.

Không tạo tài nguyên.

---

## Ví dụ AMI mới nhất

```hcl
data "aws_ami" "al2023" {

  most_recent = true

  owners = ["amazon"]

}
```

---

## Truy cập dữ liệu

```hcl
data.aws_ami.al2023.id
```

---

# 8. Data Source Phổ Biến

## Availability Zones

```hcl
data "aws_availability_zones" "available" {}
```

---

## Caller Identity

```hcl
data "aws_caller_identity" "current" {}
```

---

## Region

```hcl
data "aws_region" "current" {}
```

---

## Existing VPC

```hcl
data "aws_vpc" "main" {
  id = "vpc-xxxx"
}
```

---

# 9. Data Source Và Dependency

Terraform tự động hiểu:

```text
Data Source
     ↓
Resource
```

khi Resource sử dụng output của Data Source.

---

# 10. Best Practices

* Validation cho Input.
* Precondition cho môi trường.
* Postcondition cho kết quả.
* Check Block cho monitoring nhẹ.
* Ưu tiên Data Source thay vì hardcode ID.

---

# 11. Tổng Kết

| Công cụ       | Vai trò               |
| ------------- | --------------------- |
| Validation    | Kiểm tra Input        |
| Precondition  | Kiểm tra trước Create |
| Postcondition | Kiểm tra sau Create   |
| Check         | Health Check          |
| Data Source   | Đọc dữ liệu có sẵn    |
