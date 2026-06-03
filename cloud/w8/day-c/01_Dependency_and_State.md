# Dependency Graph Và Cơ Chế Điều Phối Tài Nguyên Trong Terraform

## 1. Bản chất của Dependency Graph

Terraform không thực thi tài nguyên theo thứ tự xuất hiện trong file `.tf`.

Trước khi thực hiện `plan` hoặc `apply`, Terraform sẽ phân tích toàn bộ cấu hình và xây dựng một **Dependency Graph (Đồ thị phụ thuộc)**.

Trong đồ thị:

* Mỗi Resource là một Node (Đỉnh)
* Quan hệ phụ thuộc là Edge (Cạnh)

Ví dụ:

```hcl
resource "aws_s3_bucket" "data" {
  bucket_prefix = "tf-series-bai5-"
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
}
```

Terraform nhận biết:

```text
aws_s3_bucket.data
        │
        ▼
aws_s3_bucket_versioning.data
```

Bucket phải được tạo trước thì Versioning mới có thể bật được.

---

## 2. Implicit Dependency (Phụ Thuộc Ngầm Định)

Đây là cơ chế phụ thuộc phổ biến nhất.

Terraform tự động tạo dependency khi một resource tham chiếu thuộc tính của resource khác.

Ví dụ:

```hcl
bucket = aws_s3_bucket.data.id
```

Terraform hiểu rằng:

```text
versioning phụ thuộc bucket
```

không cần khai báo thêm.

### Ưu điểm

* Code ngắn gọn
* Terraform tự suy luận
* Giảm lỗi cấu hình

### Khuyến nghị

Luôn ưu tiên Implicit Dependency khi có thể.

---

## 3. Xem Dependency Graph

Terraform cung cấp lệnh:

```bash
terraform graph
```

Kết quả trả về là mã DOT.

Ví dụ xuất thành ảnh:

```bash
terraform graph | dot -Tpng > graph.png
```

Yêu cầu cài Graphviz.

Sau đó có thể mở:

```bash
graph.png
```

để xem sơ đồ phụ thuộc trực quan.

---

## 4. Topological Sort

Sau khi tạo Dependency Graph, Terraform sử dụng thuật toán:

```text
Topological Sort
```

để tìm ra thứ tự thực thi hợp lệ.

Ví dụ:

```text
VPC
 │
 ├── Subnet A
 │
 └── Subnet B
```

Terraform có thể:

1. Tạo VPC trước
2. Tạo Subnet A và B song song

---

## 5. Parallelism

Những resource không phụ thuộc nhau sẽ được tạo đồng thời.

Mặc định:

```text
10 tác vụ song song
```

Ví dụ:

```text
Bucket Logs
Bucket Data
Bucket Backup
```

có thể được tạo cùng lúc.

Điều này giúp tăng tốc độ triển khai hạ tầng lớn.

---

# 6. Destroy Hoạt Động Như Thế Nào?

Khi chạy:

```bash
terraform destroy
```

Terraform đảo ngược Dependency Graph.

Apply:

```text
Bucket
   │
   ▼
Versioning
```

Destroy:

```text
Versioning
   │
   ▼
Bucket
```

Nguyên tắc:

> Tạo sau → Xóa trước

---

## 7. Vai Trò Của State File Trong Destroy

Nếu resource đã bị xóa khỏi code:

```hcl
resource "aws_s3_bucket" "data" {}
```

Terraform không còn nhìn thấy dependency nữa.

Lúc này Terraform phải dựa vào:

```text
terraform.tfstate
```

để biết:

* Resource nào tồn tại
* Resource nào phụ thuộc nhau
* Thứ tự destroy chính xác

---

## 8. Explicit Dependency (depends_on)

Có nhiều dependency Terraform không tự nhận ra.

Ví dụ:

* IAM Policy cần tạo xong
* Sau đó EC2 mới được boot

Nhưng EC2 không tham chiếu trực tiếp tới IAM Policy.

Khai báo:

```hcl
resource "aws_instance" "app" {

  depends_on = [
    aws_iam_role_policy.app
  ]
}
```

Terraform buộc phải tạo:

```text
IAM Policy
    ↓
EC2
```

---

## 9. Khi Nào Dùng depends_on

Nên dùng:

* Quan hệ logic
* Quan hệ ứng dụng
* Không có thuộc tính để tham chiếu

Không nên dùng:

* Thay thế Implicit Dependency
* Lạm dụng để ép thứ tự

Lý do:

Terraform có thể:

* Plan kém tối ưu
* Tạo lại nhiều resource không cần thiết

---

## 10. Terraform Target

Cho phép chỉ tác động một phần của graph.

Ví dụ:

```bash
terraform apply \
-target=aws_s3_bucket.data
```

Terraform sẽ:

* Tạo Bucket
* Tạo các dependency cần thiết

Nhưng bỏ qua các resource khác.

---

## 11. Rủi Ro Của -target

HashiCorp khuyến nghị:

Chỉ dùng cho:

* Debug
* Khắc phục sự cố
* Hotfix

Không dùng thường xuyên.

Nếu phải dùng hằng ngày:

→ Thiết kế State chưa hợp lý.

---

## 12. Tổng Kết

| Cơ chế              | Mục đích                    |
| ------------------- | --------------------------- |
| Implicit Dependency | Terraform tự suy luận       |
| depends_on          | Khai báo phụ thuộc thủ công |
| graph               | Xem sơ đồ phụ thuộc         |
| destroy             | Chạy ngược Dependency Graph |
| -target             | Cô lập resource khi cần     |
