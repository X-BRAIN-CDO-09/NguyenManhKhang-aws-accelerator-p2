# For Expression, Dynamic Block, Count Và For_Each

## 1. Tại Sao Cần Lặp?

Trong hạ tầng thực tế:

* Nhiều EC2
* Nhiều Subnet
* Nhiều Security Rules

Viết tay:

```hcl
resource "aws_subnet" "a" {}
resource "aws_subnet" "b" {}
resource "aws_subnet" "c" {}
```

khó bảo trì.

Terraform hỗ trợ cơ chế lặp.

---

# 2. Count

## Cú pháp

```hcl
resource "aws_instance" "web" {

  count = 3

  ami = data.aws_ami.al2023.id

  instance_type = "t3.micro"
}
```

---

## Kết quả

Terraform tạo:

```text
aws_instance.web[0]
aws_instance.web[1]
aws_instance.web[2]
```

---

## Truy cập

```hcl
aws_instance.web[0].id
```

---

# 3. Nhược Điểm Count

Ví dụ:

```hcl
count = 3
```

Sau đó:

```hcl
count = 2
```

Terraform phải:

```text
Destroy web[2]
```

---

Nếu thay đổi vị trí phần tử:

```text
Có thể recreate ngoài ý muốn
```

---

# 4. For_Each

Giải pháp tốt hơn.

---

## Với Set

```hcl
resource "aws_s3_bucket" "data" {

  for_each = toset([
    "logs",
    "data",
    "backup"
  ])

  bucket_prefix = each.key
}
```

---

## Kết quả

```text
aws_s3_bucket.data["logs"]
aws_s3_bucket.data["data"]
aws_s3_bucket.data["backup"]
```

---

## Ưu điểm

Định danh theo Key.

Không phụ thuộc Index.

---

# 5. For_Each Với Map

```hcl
resource "aws_subnet" "public" {

  for_each = {

    subnet1 = "10.0.0.0/24"
    subnet2 = "10.0.1.0/24"

  }

  cidr_block = each.value
}
```

---

## each.key

```text
subnet1
```

---

## each.value

```text
10.0.0.0/24
```

---

# 6. Khi Nào Dùng Count?

Dùng khi:

```text
Số lượng đơn giản
```

Ví dụ:

```hcl
count = var.enable ? 1 : 0
```

Bật hoặc tắt tài nguyên.

---

# 7. Khi Nào Dùng For_Each?

Dùng khi:

* Có tên định danh
* Có Map
* Có Set

HashiCorp khuyến nghị:

```text
Ưu tiên For_Each
```

---

# 8. For Expression

Terraform hỗ trợ List Comprehension.

---

## Ví dụ

```hcl
[for s in aws_subnet.public : s.id]
```

---

## Kết quả

```text
[
 subnet-a,
 subnet-b,
 subnet-c
]
```

---

## Thêm Điều Kiện

```hcl
[
  for s in aws_subnet.public :
  s.id
  if s.available_ip_address_count > 50
]
```

---

# 9. Tạo Map

```hcl
{
  for s in aws_subnet.public :
  s.id => s.cidr_block
}
```

---

## Kết quả

```text
{
 subnet-a = 10.0.0.0/24
 subnet-b = 10.0.1.0/24
}
```

---

# 10. Dynamic Block

## Bài toán

Một Security Group có nhiều Rule.

---

### Cách thủ công

```hcl
ingress {}
ingress {}
ingress {}
```

---

## Dynamic

```hcl
dynamic "ingress" {

  for_each = var.rules

  content {

    from_port = ingress.value.port
    to_port   = ingress.value.port

    protocol  = "tcp"

    cidr_blocks = ingress.value.cidr

  }
}
```

---

## Terraform sinh ra

```text
ingress { ... }
ingress { ... }
ingress { ... }
```

---

# 11. Templatefile()

Tách UserData khỏi Terraform.

---

## user-data.sh

```bash
#!/bin/bash

echo "Hello"
```

---

## Terraform

```hcl
user_data = templatefile(
  "${path.module}/user-data.sh",
  {}
)
```

---

## Lợi ích

* Dễ đọc
* Dễ bảo trì
* Script dài không làm bẩn Terraform

---

# 12. Tổng Hợp Các Kỹ Thuật Lặp

| Công cụ        | Chức năng         |
| -------------- | ----------------- |
| count          | Lặp theo số lượng |
| for_each       | Lặp theo key      |
| for expression | Biến đổi dữ liệu  |
| dynamic        | Sinh block động   |
| templatefile   | Tách template     |

---

# 13. Best Practices

### Ưu tiên

```text
for_each
```

thay vì:

```text
count
```

khi có định danh.

---

### Dynamic Block

Chỉ dùng khi:

```text
Nested Block Lặp
```

---

### Templatefile

Dùng cho:

* UserData
* Cloud-init
* Config File

---

# 14. Tổng Kết

Terraform cung cấp 4 cơ chế xử lý dữ liệu động:

```text
count
for_each
for expression
dynamic
```

Trong dự án thực tế:

* count dùng để bật/tắt tài nguyên.
* for_each dùng để tạo nhiều resource.
* for expression dùng để xử lý dữ liệu.
* dynamic dùng để sinh nested block tự động.

Đây là nền tảng của Terraform nâng cao.
