# Bài 2: Khởi Tạo Dự Án Và Khai Báo Tài Nguyên Đầu Tiên

## 1. Khai Báo Provider và Ghim Phiên Bản (Pin Version)
[cite_start]Tạo một thư mục trống và tạo tệp `main.tf` với nội dung cấu hình nhà cung cấp AWS[cite: 28]:

```terraform
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
## Giải Thích Mã Nguồn

### Khối `terraform {}`

Khai báo các ràng buộc về môi trường chạy của dự án.

#### `required_version = ">= 1.10"`

Đảm bảo chặn ngay lập tức những ai sử dụng phiên bản Terraform cũ hơn 1.10, giúp tránh các lỗi không tương thích hoặc hành vi không mong muốn trong quá trình triển khai.

#### `required_providers`

Định nghĩa nguồn tải và phiên bản của các Provider được sử dụng trong dự án.

Ví dụ:

```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}
```

##### Toán tử `~> 6.0` (Pessimistic Constraint Operator)

Cho phép Terraform tự động cập nhật các bản vá lỗi (patch) hoặc tính năng nhỏ trong nhánh **6.x**.

Ví dụ:

- ✅ 6.1.0
- ✅ 6.25.0
- ✅ 6.46.0
- ❌ 7.0.0

Việc ghim phiên bản theo cách này giúp:

- Nhận được các bản sửa lỗi và cải tiến mới nhất.
- Tránh tự động nâng cấp lên phiên bản lớn có thể chứa **Breaking Changes**.
- Đảm bảo khả năng tái tạo hạ tầng (Infrastructure Reproducibility) sau nhiều tháng hoặc nhiều năm.

---

### Khối `provider "aws" {}`

Cấu hình AWS Provider để Terraform biết cần tương tác với tài khoản AWS nào và ở khu vực nào.

Ví dụ:

```hcl
provider "aws" {
  region = "ap-southeast-1"
}
```

Trong ví dụ trên, mọi tài nguyên AWS sẽ được tạo tại vùng **Singapore (`ap-southeast-1`)**.

---

### Lưu Ý Về Thông Tin Xác Thực AWS

> ⚠️ **Quy tắc sống còn:** Tuyệt đối không viết trực tiếp Access Key hoặc Secret Key vào mã nguồn.

AWS Provider sẽ tự động tìm kiếm thông tin xác thực theo thứ tự ưu tiên:

1. Thông tin được khai báo trực tiếp trong khối `provider`.
2. Biến môi trường (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
3. File cấu hình `~/.aws/credentials`.
4. IAM Role (đối với EC2, ECS, Lambda, v.v.).

Ví dụ cấu hình an toàn bằng AWS CLI:

```bash
aws configure
```

Lệnh trên sẽ tạo file:

```text
~/.aws/credentials
```

Giúp Terraform tự động sử dụng thông tin xác thực mà không cần lưu trữ khóa bí mật trong mã nguồn.
Mở terminal tại thư mục chứa file main.tf và chạy lệnh:
terraform init
## Cơ Chế Hoạt Động Của Terraform Init

Khi chạy lệnh:

```bash
terraform init
```

Terraform sẽ thực hiện các bước sau:

1. Đọc khối `required_providers` trong cấu hình.
2. Tìm phiên bản mới nhất phù hợp với ràng buộc đã khai báo (ví dụ: `~> 6.0`).
3. Tải file binary của Provider về thư mục ẩn `.terraform/`.
4. Xác thực chữ ký số (Signature Verification) để đảm bảo Provider được phát hành chính thức và không bị chỉnh sửa.

Quá trình này chỉ diễn ra khi khởi tạo hoặc khi Terraform phát hiện cần tải phiên bản Provider mới.

---

## Tệp Khóa `.terraform.lock.hcl`

Sau khi chạy `terraform init`, Terraform tự động sinh ra file:

```text
.terraform.lock.hcl
```

File này lưu trữ:

- Phiên bản Provider được lựa chọn.
- Checksum (mã băm) của Provider.
- Thông tin xác thực tính toàn vẹn của gói cài đặt.

Ví dụ:

```hcl
provider "registry.terraform.io/hashicorp/aws" {
  version = "6.46.0"
  hashes = [
    "h1:xxxxxxxxxxxxxxxxxxxxxxxx",
    "zh:xxxxxxxxxxxxxxxxxxxxxxxx"
  ]
}
```

### Vai Trò

Ở những lần chạy `terraform init` tiếp theo:

- Terraform ưu tiên sử dụng đúng phiên bản được ghi trong file lock.
- Không tự động nâng cấp lên phiên bản mới hơn.
- Đảm bảo mọi thành viên trong nhóm và mọi môi trường CI/CD đều sử dụng cùng một phiên bản Provider.

Điều này giúp tránh các lỗi phát sinh do khác biệt phiên bản.

---

## Thực Hành Tốt Với Git

### NÊN

Thêm file lock vào Git:

```bash
git add .terraform.lock.hcl
```

Lợi ích:

- Toàn bộ đội phát triển dùng cùng một phiên bản Provider.
- Kết quả triển khai nhất quán giữa các môi trường.
- Dễ dàng tái tạo hạ tầng sau thời gian dài.

### KHÔNG NÊN

Không commit thư mục:

```text
.terraform/
```

Thêm vào file `.gitignore`:

```gitignore
.terraform/
```

Lý do:

- Chứa file binary tải về từ Internet.
- Dung lượng lớn.
- Có thể được tái tạo bằng `terraform init`.

---

## Hai Lệnh Kiểm Tra Nhanh (Không Tốn Phí)

### Kiểm Tra Định Dạng Mã Nguồn

```bash
terraform fmt -check
```

Lệnh này:

- Kiểm tra cách căn lề (indentation).
- Kiểm tra khoảng trắng.
- Kiểm tra định dạng dấu `=`.
- Đảm bảo toàn bộ mã nguồn tuân theo chuẩn Terraform.

Ví dụ:

```hcl
bucket="my-bucket"
```

sẽ được chuẩn hóa thành:

```hcl
bucket = "my-bucket"
```

---

### Kiểm Tra Cú Pháp

```bash
terraform validate
```

Terraform sẽ:

- Kiểm tra cú pháp HCL.
- Kiểm tra tham số bắt buộc.
- Kiểm tra tham chiếu giữa các tài nguyên.

Lệnh này không tạo tài nguyên và không gọi API AWS nên hoàn toàn miễn phí.

---

# 3. Khai Báo Tài Nguyên S3 Bucket Và Kiểm Tra Kế Hoạch (Plan)

Thêm đoạn mã sau vào cuối file `main.tf`:

```hcl
resource "aws_s3_bucket" "first" {
  bucket_prefix = "tf-series-bai2-"
  force_destroy = true

  tags = {
    Project = "terraform-series"
    Bai     = "02"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.first.id
}

output "bucket_arn" {
  value = aws_s3_bucket.first.arn
}
```

---

## Giải Thích Cú Pháp

### Khối Resource

```hcl
resource "aws_s3_bucket" "first"
```

Terraform sử dụng hai nhãn:

| Thành phần | Ý nghĩa |
|------------|----------|
| `aws_s3_bucket` | Loại tài nguyên |
| `first` | Tên cục bộ để tham chiếu trong Terraform |

Ví dụ tham chiếu:

```hcl
aws_s3_bucket.first.id
```

Tên `first` chỉ tồn tại trong Terraform và không phải tên thật của Bucket trên AWS.

---

### bucket_prefix

```hcl
bucket_prefix = "tf-series-bai2-"
```

Terraform sẽ tự động thêm chuỗi ngẫu nhiên phía sau:

Ví dụ:

```text
tf-series-bai2-a8df7x
```

Điều này giúp tránh lỗi do tên S3 Bucket phải duy nhất trên toàn cầu.

---

### force_destroy

```hcl
force_destroy = true
```

Cho phép Terraform xóa Bucket ngay cả khi bên trong vẫn còn dữ liệu.

Hữu ích cho:

- Lab.
- Môi trường thử nghiệm.
- Demo ngắn hạn.

Không nên sử dụng trong môi trường Production nếu chưa có cơ chế sao lưu dữ liệu.

---

### Outputs

```hcl
output "bucket_name"
```

Xuất tên Bucket sau khi triển khai.

```hcl
output "bucket_arn"
```

Xuất ARN của Bucket để sử dụng ở các module hoặc hệ thống khác.

---

## Kiểm Tra Kế Hoạch Triển Khai

Chạy:

```bash
terraform plan
```

Terraform sẽ tạo Execution Plan và hiển thị các thay đổi dự kiến.

### Dấu `+` Màu Xanh

Ví dụ:

```text
+ resource "aws_s3_bucket" "first"
```

Có nghĩa:

- Một tài nguyên mới sẽ được tạo.

---

### Dòng Tóm Tắt Quan Trọng

```text
Plan: 1 to add, 0 to change, 0 to destroy
```

Ý nghĩa:

| Giá trị | Ý nghĩa |
|----------|----------|
| Add | Tạo mới |
| Change | Cập nhật |
| Destroy | Xóa |

Đây là dòng đầu tiên cần đọc trước khi thực hiện triển khai.

---

### `(known after apply)`

Ví dụ:

```text
arn = (known after apply)
```

Những giá trị này chưa tồn tại ở thời điểm lập kế hoạch vì AWS sẽ sinh ra sau khi tài nguyên được tạo thành công.

Ví dụ:

- ARN
- ID
- Tên Bucket hoàn chỉnh
- Endpoint

---

# 4. Thực Thi Khởi Tạo Thực Tế (Apply) Và Dọn Dẹp (Destroy)

## Triển Khai Hạ Tầng

```bash
terraform apply -auto-approve
```

Tham số:

```text
-auto-approve
```

Giúp Terraform tự động đồng ý triển khai mà không cần nhập:

```text
yes
```

Quá trình thực hiện:

1. Đọc Execution Plan.
2. Gọi API AWS thông qua AWS Provider.
3. Tạo tài nguyên trên AWS.
4. Thu thập thông tin phản hồi.
5. Cập nhật State File.
6. Hiển thị Output cho người dùng.

Ví dụ:

```text
bucket_name = tf-series-bai2-a8df7x
bucket_arn  = arn:aws:s3:::tf-series-bai2-a8df7x
```

---

## Dọn Dẹp Tài Nguyên

Sau khi hoàn thành thực hành, nên xóa toàn bộ hạ tầng để tránh phát sinh chi phí.

```bash
terraform destroy -auto-approve
```

Terraform sẽ:

1. Đọc file State.
2. Xác định các tài nguyên đã tạo.
3. Gọi API AWS để xóa tài nguyên.
4. Cập nhật lại State File.

Kết quả:

```text
Destroy complete! Resources: 1 destroyed.
```

### Lưu Ý Quan Trọng

> Luôn chạy `terraform destroy` sau khi hoàn thành các bài thực hành AWS nếu không còn nhu cầu sử dụng tài nguyên, nhằm tránh phát sinh chi phí ngoài ý muốn.
