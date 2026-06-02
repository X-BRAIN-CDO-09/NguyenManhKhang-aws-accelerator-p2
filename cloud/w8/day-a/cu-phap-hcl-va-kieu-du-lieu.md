# Bài 3: Cú Pháp HCL, Kiểu Dữ Liệu Và Quy Tắc Thực Thi

## 1. Ba Thành Phần Chính Trong Cú Pháp HCL

Ngôn ngữ cấu hình HashiCorp Configuration Language (HCL) được xây dựng dựa trên ba thành phần nền tảng:

### Argument (Đối số)

Argument dùng để gán một giá trị cho một thuộc tính cụ thể.

Ví dụ:

```hcl
region = "ap-southeast-1"
```

Trong đó:

- Bên trái (`region`) là **Identifier**.
- Bên phải (`"ap-southeast-1"`) là **Expression** hoặc giá trị.

---

### Block (Khối)

Block là đơn vị cấu trúc chính trong Terraform, dùng để nhóm các cấu hình liên quan lại với nhau.

Cấu trúc tổng quát:

```hcl
block_type "label1" "label2" {
  argument = value
}
```

Ví dụ:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
}
```

Một Block bao gồm:

| Thành phần | Ý nghĩa |
|------------|----------|
| Block Type | Loại khối (`resource`, `provider`, `variable`...) |
| Labels | Nhãn dùng để định danh |
| Body | Nội dung bên trong dấu `{}` |

---

### Identifier (Định Danh)

Identifier là tên được sử dụng cho:

- Biến (`variable`)
- Output (`output`)
- Resource
- Argument
- Local Value

Ví dụ:

```hcl
variable "region" {}
```

Trong đó:

```text
region
```

chính là Identifier.

#### Quy tắc đặt tên

Hợp lệ:

```text
my_var
web-server
project123
```

Không hợp lệ:

```text
123project
```

Identifier có thể chứa:

- Chữ cái (`a-z`, `A-Z`)
- Chữ số (`0-9`)
- Dấu gạch dưới (`_`)
- Dấu gạch ngang (`-`)

Nhưng không được bắt đầu bằng số.

---

# 2. Công Cụ Thử Nghiệm Và 6 Kiểu Dữ Liệu

## Terraform Console

Terraform cung cấp môi trường tương tác giúp kiểm tra nhanh biểu thức HCL mà không cần tạo tài nguyên thật.

Khởi động:

```bash
terraform console
```

Ví dụ:

```text
> 10 + 5
15
```

```text
> upper("terraform")
TERRAFORM
```

---

## Sáu Kiểu Dữ Liệu Nền Tảng

### Nhóm Primitive (Nguyên Thủy)

#### String

Chuỗi ký tự văn bản.

```hcl
"web"
```

```hcl
"production"
```

---

#### Number

Hỗ trợ cả số nguyên và số thực.

```hcl
10
```

```hcl
3.14
```

---

#### Boolean

Chỉ có hai giá trị:

```hcl
true
```

```hcl
false
```

---

### Nhóm Collection (Tập Hợp)

#### List

Danh sách phần tử cùng kiểu dữ liệu.

Ví dụ:

```hcl
["web", "api", "db"]
```

Truy cập phần tử:

```hcl
var.servers[0]
```

Terraform đánh số từ:

```text
0, 1, 2, ...
```

---

#### Tuple

Tương tự List nhưng cho phép nhiều kiểu dữ liệu khác nhau.

```hcl
["web", 2, true]
```

---

#### Map

Tập hợp các cặp khóa–giá trị.

Ví dụ:

```hcl
{
  env  = "prod"
  team = "devops"
}
```

Truy cập:

```hcl
var.tags["env"]
```

---

#### Object

Tương tự Map nhưng mỗi thuộc tính có thể mang kiểu dữ liệu khác nhau.

Ví dụ:

```hcl
{
  name = "web"
  cpu  = 2
  ssl  = true
}
```

---

### Null

Giá trị đặc biệt biểu thị sự vắng mặt của dữ liệu.

```hcl
null
```

Ví dụ:

```hcl
resource "aws_instance" "example" {
  key_name = null
}
```

Terraform sẽ coi như thuộc tính `key_name` không được khai báo.

Lưu ý:

```hcl
null
```

khác với:

```hcl
""
```

và

```hcl
0
```

vì đây vẫn là các giá trị hợp lệ.

---

# 3. Biểu Thức (Expressions) Và Hàm (Functions)

## Toán Tử Ba Ngôi (Ternary Operator)

Cú pháp:

```hcl
condition ? value_if_true : value_if_false
```

Ví dụ:

```hcl
var.env == "prod" ? 3 : 1
```

Ý nghĩa:

- Nếu môi trường là Production → trả về 3.
- Ngược lại → trả về 1.

Ứng dụng phổ biến:

- Bật/tắt tính năng.
- Thay đổi số lượng tài nguyên theo môi trường.
- Chọn cấu hình Dev hoặc Prod.

---

## Nội Suy Chuỗi (String Interpolation)

Cho phép nhúng biểu thức vào chuỗi.

Ví dụ:

```hcl
"${var.env}-web"
```

Nếu:

```hcl
var.env = "prod"
```

Kết quả:

```text
prod-web
```

Ví dụ khác:

```hcl
"${var.project}-${var.env}"
```

Kết quả:

```text
myapp-prod
```

---

## Hàm Tích Hợp Sẵn (Built-in Functions)

Terraform cung cấp hàng trăm hàm hỗ trợ xử lý dữ liệu.

### Hàm length()

Đếm số phần tử.

```hcl
length(["a", "b", "c"])
```

Kết quả:

```text
3
```

---

### Hàm upper()

Chuyển thành chữ hoa.

```hcl
upper("terraform")
```

Kết quả:

```text
TERRAFORM
```

---

### Hàm lower()

Chuyển thành chữ thường.

```hcl
lower("AWS")
```

Kết quả:

```text
aws
```

---

### Hàm cidrsubnet()

Tự động chia subnet từ CIDR gốc.

Ví dụ:

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

Kết quả:

```text
10.0.1.0/24
```

Đây là hàm rất phổ biến khi xây dựng VPC.

---

### Hạn Chế

> 🚨 Terraform không cho phép người dùng tự định nghĩa hàm (Custom Function). Chỉ có thể sử dụng các hàm tích hợp sẵn do HashiCorp cung cấp.

---

# 4. Khối terraform {} Và Quy Tắc Thực Thi

## Khối terraform {}

Đây là khối cấu hình chính cho môi trường thực thi Terraform.

Ví dụ:

```hcl
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

---

## Ba Thành Phần Quan Trọng

### required_version

Ràng buộc phiên bản Terraform CLI.

Ví dụ:

```hcl
required_version = ">= 1.10"
```

Terraform sẽ từ chối chạy nếu phiên bản thấp hơn yêu cầu.

---

### required_providers

Khai báo Provider cần sử dụng.

Ví dụ:

```hcl
required_providers {
  aws = {
    source = "hashicorp/aws"
  }
}
```

Terraform sẽ tự động tải plugin tương ứng.

---

### backend

Xác định nơi lưu Terraform State.

Ví dụ:

```hcl
backend "s3" {
  bucket = "terraform-state"
  key    = "prod/state.tfstate"
  region = "ap-southeast-1"
}
```

Các backend phổ biến:

- Local
- S3
- Azure Storage
- Google Cloud Storage
- Terraform Cloud

---

## Quy Tắc Quan Trọng

Khối `terraform {}` chỉ chấp nhận giá trị tĩnh.

Ví dụ hợp lệ:

```hcl
required_version = ">= 1.10"
```

Ví dụ không hợp lệ:

```hcl
required_version = var.tf_version
```

Terraform cần đọc khối này trước khi tải biến và Provider nên không cho phép sử dụng biến động.

---

# 5. Terraform Không Thực Thi Theo Thứ Tự Dòng Code

Nhiều người mới học thường nghĩ Terraform sẽ đọc file từ trên xuống dưới giống ngôn ngữ lập trình.

Thực tế hoàn toàn khác.

Terraform là ngôn ngữ khai báo (Declarative Language), không phải ngôn ngữ mệnh lệnh (Imperative Language).

Ví dụ:

```hcl
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}
```

Mặc dù `aws_instance` được khai báo trước nhưng Terraform vẫn:

1. Tạo VPC.
2. Tạo Subnet.
3. Tạo EC2.

vì Terraform tự động xây dựng **Dependency Graph (Đồ thị phụ thuộc)**.

---

## Dependency Graph

Terraform sẽ:

1. Đọc toàn bộ cấu hình.
2. Phân tích các tham chiếu.
3. Xây dựng đồ thị phụ thuộc.
4. Tính toán thứ tự tối ưu.
5. Thực thi song song các tài nguyên độc lập.

Lợi ích:

- Triển khai nhanh hơn.
- Hạn chế lỗi phụ thuộc.
- Không cần tự quản lý thứ tự tạo tài nguyên.

> Đây là một trong những cơ chế quan trọng nhất giúp Terraform quản lý hạ tầng phức tạp một cách tự động và đáng tin cậy.