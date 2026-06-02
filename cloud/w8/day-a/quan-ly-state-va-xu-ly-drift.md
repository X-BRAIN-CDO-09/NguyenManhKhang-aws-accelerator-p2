# Bài 4: Quản Lý Tệp Trạng Thái (State File) Và Xử Lý Drift

## 1. Tại Sao Terraform Cần Một File State Riêng Biệt?

Một câu hỏi phổ biến của người mới học Terraform là:

> Nếu đã có file cấu hình (`main.tf`) và hạ tầng thực tế trên Cloud, tại sao Terraform vẫn cần thêm một file `terraform.tfstate`?

Câu trả lời là Terraform cần State File để theo dõi và quản lý chính xác vòng đời của hạ tầng.

---

## 1.1 Ánh Xạ Vào Thế Giới Thực (Resource Mapping)

Trong mã nguồn Terraform, tài nguyên thường được đặt tên bằng các định danh cục bộ.

Ví dụ:

```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "my-demo-bucket"
}
```

Terraform chỉ biết:

```text
aws_s3_bucket.demo
```

Tuy nhiên AWS lại quản lý tài nguyên bằng:

- ARN
- ID nội bộ
- Metadata riêng của hệ thống

Ví dụ:

```text
arn:aws:s3:::my-demo-bucket
```

State File đóng vai trò là cầu nối giữa:

```text
Terraform Resource Address
        ↕
AWS Resource ID
```

Nhờ vậy Terraform biết chính xác tài nguyên nào cần:

- Cập nhật
- Thay đổi
- Xóa bỏ

khi mã nguồn được chỉnh sửa.

---

## 1.2 Lưu Trữ Thông Tin Phụ Thuộc (Dependency Metadata)

Terraform tự động xây dựng quan hệ phụ thuộc giữa các tài nguyên.

Ví dụ:

```text
VPC
 └── Subnet
      └── EC2
```

Nếu một ngày bạn xóa toàn bộ tài nguyên khỏi file `.tf`, Terraform sẽ không còn nhìn thấy các mối quan hệ này trong code.

Lúc đó State File giúp Terraform ghi nhớ:

```text
EC2 phụ thuộc Subnet
Subnet phụ thuộc VPC
```

để quá trình hủy tài nguyên diễn ra đúng thứ tự:

```text
EC2 → Subnet → VPC
```

thay vì ngược lại.

Điều này giúp tránh lỗi:

```text
Cannot delete VPC because Subnet still exists
```

---

## 1.3 Tối Ưu Hiệu Năng (Performance)

State File hoạt động giống như một bộ nhớ đệm (Cache).

Không có State File, mỗi lần chạy:

```bash
terraform plan
```

Terraform sẽ phải:

1. Liệt kê toàn bộ tài nguyên trên Cloud.
2. Gọi API cho từng tài nguyên.
3. Thu thập toàn bộ thuộc tính.

Với hệ thống lớn:

```text
1000+
2000+
5000+ tài nguyên
```

thời gian thực hiện sẽ rất lâu và dễ gặp giới hạn API (Rate Limit).

Nhờ State File, Terraform chỉ cần:

```text
State → Cloud → So sánh
```

thay vì phải khám phá lại toàn bộ hạ tầng từ đầu.

---

## 1.4 Đồng Bộ Hóa Khi Làm Việc Nhóm

Trong môi trường doanh nghiệp, nhiều người cùng quản lý một hệ thống Terraform.

Nếu mỗi người giữ một State File riêng:

```text
Dev A → state A
Dev B → state B
```

sẽ dẫn đến:

- Ghi đè lẫn nhau.
- Mất đồng bộ.
- Hủy nhầm tài nguyên.

Giải pháp là sử dụng Remote State.

Ví dụ:

```text
AWS S3
Terraform Cloud
Azure Storage
Google Cloud Storage
```

Khi đó State File trở thành:

> Single Source of Truth (Nguồn sự thật duy nhất)

cho toàn bộ nhóm.

---

# 2. Các Lệnh Đọc State Chuyên Dụng

## Không Chỉnh Sửa Trực Tiếp File State

Mặc dù file:

```text
terraform.tfstate
```

được lưu dưới dạng JSON, bạn không nên mở và sửa thủ công.

Ví dụ:

```json
{
  "resources": [...]
}
```

Một thay đổi sai có thể khiến Terraform:

- Mất khả năng quản lý tài nguyên.
- Xóa nhầm hạ tầng.
- Tạo lại tài nguyên không mong muốn.

---

## terraform state list

Liệt kê toàn bộ tài nguyên Terraform đang quản lý.

```bash
terraform state list
```

Ví dụ:

```text
aws_s3_bucket.demo
aws_vpc.main
aws_subnet.public
```

Đây là cách nhanh nhất để kiểm tra Terraform hiện đang quản lý những gì.

---

## terraform state show

Hiển thị thông tin chi tiết của một tài nguyên.

```bash
terraform state show aws_s3_bucket.demo
```

Ví dụ kết quả:

```text
id          = my-demo-bucket
arn         = arn:aws:s3:::my-demo-bucket
region      = ap-southeast-1
```

Lệnh này rất hữu ích khi:

- Debug.
- Kiểm tra thuộc tính.
- Xác minh dữ liệu trong State.

---

# 3. Cơ Chế Refresh Và Hiện Tượng Drift

## Quy Trình So Sánh Ba Bên (3-Way Comparison)

Mỗi lần chạy:

```bash
terraform plan
```

hoặc:

```bash
terraform apply
```

Terraform sẽ thực hiện bước:

```text
Refresh
```

Quá trình này gồm:

```text
State
   ↓
Cloud API
   ↓
Đọc trạng thái thực tế
   ↓
So sánh với Code
```

Terraform thực hiện đối chiếu:

```text
Code ↔ State ↔ Cloud
```

để xác định các thay đổi cần thực hiện.

---

## Drift Là Gì?

Drift (Configuration Drift) xảy ra khi hạ tầng bị thay đổi bên ngoài Terraform.

Ví dụ:

### Trường Hợp 1

Terraform tạo Bucket:

```text
my-app-prod
```

Sau đó quản trị viên vào AWS Console đổi:

```text
Tag Environment=Prod
```

---

### Trường Hợp 2

Một người chạy:

```bash
aws s3api put-bucket-versioning
```

bằng AWS CLI.

---

### Trường Hợp 3

Một kỹ sư DevOps chỉnh sửa trực tiếp:

```text
Security Group
IAM Policy
Route Table
```

trên giao diện AWS.

---

## Terraform Xem Điều Gì Là Chân Lý?

Mặc định Terraform luôn coi:

```text
Code (.tf)
```

là nguồn chân lý cao nhất.

Ví dụ:

Code:

```hcl
instance_type = "t3.micro"
```

Cloud thực tế:

```text
t3.large
```

Terraform sẽ đề xuất:

```text
~ update in-place
```

để đưa Cloud trở về:

```text
t3.micro
```

đúng như những gì được khai báo trong code.

---

# 4. Hai Cách Xử Lý Drift

Khi phát hiện Drift, Terraform cho phép hai hướng xử lý.

---

## Phương Án 1: Khôi Phục Theo Code

```bash
terraform plan
```

Triết lý:

```text
Code là chân lý
```

Terraform sẽ:

```text
Cloud → Quay lại giống Code
```

Phù hợp khi:

- Ai đó chỉnh sửa sai.
- Thay đổi không được phê duyệt.
- Muốn khôi phục cấu hình chuẩn.

---

## Phương Án 2: Chấp Nhận Thay Đổi Ngoài Thực Tế

```bash
terraform plan -refresh-only
```

Triết lý:

```text
Cloud là chân lý
```

Terraform sẽ:

```text
Cloud → Cập nhật State
```

mà không thay đổi hạ tầng.

Phù hợp khi:

- Thay đổi ngoài thực tế là hợp lệ.
- Đang xử lý sự cố khẩn cấp.
- Muốn cập nhật State trước rồi đồng bộ code sau.

---

## Bảng So Sánh

| Tiêu chí | terraform plan | terraform plan -refresh-only |
|-----------|----------------|------------------------------|
| Chân lý tối cao | Code | Cloud |
| Cập nhật State | Có | Có |
| Thay đổi Cloud | Có | Không |
| Mục tiêu | Đưa Cloud về giống Code | Đưa State về giống Cloud |
| Tình huống phù hợp | Sửa sai, khôi phục chuẩn | Chấp nhận thay đổi thủ công |

---

# 5. Cảnh Báo Bảo Mật Quan Trọng

## State File Là Plaintext

File:

```text
terraform.tfstate
```

không được mã hóa mặc định.

Bên trong có thể chứa:

- Mật khẩu Database.
- API Key.
- Secret Token.
- IAM Credentials.
- Private Key.
- Connection String.

Ví dụ:

```json
{
  "password": "SuperSecret123"
}
```

Bất kỳ ai đọc được file State đều có thể nhìn thấy các thông tin này.

---

## Quy Tắc Bắt Buộc

🚨 **Không bao giờ đưa State File lên Git Repository**

Sai:

```bash
git add terraform.tfstate
git commit -m "state file"
```

Đúng:

`.gitignore`

```gitignore
terraform.tfstate
terraform.tfstate.backup
*.tfstate
*.tfstate.*
```

---

## Khuyến Nghị Cho Môi Trường Thực Tế

Thay vì lưu State cục bộ, nên sử dụng:

- AWS S3 + DynamoDB Locking
- Terraform Cloud
- Azure Storage Backend
- Google Cloud Storage Backend

Lợi ích:

- Chia sẻ State cho cả nhóm.
- Hỗ trợ State Locking.
- Sao lưu tự động.
- Kiểm soát quyền truy cập.
- Giảm nguy cơ mất dữ liệu.

> State File là thành phần quan trọng nhất của Terraform. Mất State hoặc để lộ State có thể dẫn đến mất khả năng quản lý hạ tầng hoặc rò rỉ thông tin bảo mật nghiêm trọng.