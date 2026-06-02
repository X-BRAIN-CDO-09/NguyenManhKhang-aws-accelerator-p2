# Bài 1: Tổng Quan Về Infrastructure as Code (IaC) và Terraform

## 1. Vấn Đề Của Hạ Tầng Cấu Hình Bằng Tay (Manual Configuration)
Việc cấu hình hạ tầng bằng tay trực tiếp trên giao diện hoặc qua dòng lệnh đơn lẻ mang lại nhiều rủi ro lớn cho hệ thống:
* [cite_start]**Không thể tái cấu trúc:** Không có tài liệu ghi lại chi tiết các bước thực hiện, dẫn đến việc cực kỳ khó khăn để tạo ra một bản sao chính xác cho các môi trường thử nghiệm (Staging, Lab)[cite: 2].
* [cite_start]**Sự sai lệch cấu hình (Configuration drift):** Các thay đổi trực tiếp bằng tay trong quá trình xử lý sự cố khẩn cấp sẽ làm mất đi trạng thái gốc, khiến hệ thống không còn cơ sở chuẩn để đối chiếu[cite: 3].
* [cite_start]**Không thể xem xét trước (Review):** Các thay đổi nguy hiểm và vô hại nhìn hoàn toàn giống nhau, không có cơ chế so sánh sự khác biệt (diff), không có pull request hay quy trình phê duyệt an toàn[cite: 4].

> [cite_start]**Giải pháp Infrastructure as Code (IaC):** Mô tả toàn bộ hạ tầng bằng các tệp cấu hình, lưu trữ tập trung trong Git và sử dụng công cụ chuyên dụng để tự động chuyển đổi mã nguồn thành hạ tầng thực tế[cite: 5].

---

## 2. Terraform Là Gì?
[cite_start]**Terraform** là một công cụ IaC mạnh mẽ cho phép định nghĩa các tài nguyên đám mây (Cloud) và hạ tầng tại chỗ (On-prem) trong các tệp cấu hình có cấu trúc rõ ràng, có khả năng đọc được, kiểm soát phiên bản, tái sử dụng và chia sẻ dễ dàng[cite: 7].

### Tính Khai Báo (Declarative)
[cite_start]Terraform hoạt động theo mô hình khai báo[cite: 8]. [cite_start]Người dùng chỉ cần viết ra trạng thái mong muốn cuối cùng của hạ tầng, Terraform sẽ tự động tính toán thứ tự, mối phụ thuộc và cách thức chi tiết để thực hiện hành động đó[cite: 8].

### Ba Khái Niệm Cốt Lõi
* [cite_start]**Provider:** Plugin giúp Terraform giao tiếp và gửi yêu cầu tới các nền tảng cụ thể như AWS, Google Cloud, Azure, v.v. [cite: 10]
* [cite_start]**Resource:** Đơn vị hạ tầng cụ thể được khai báo mà Terraform quản lý trực tiếp (Ví dụ: `aws_instance`, `aws_s3_bucket`)[cite: 11].
* [cite_start]**State:** Tệp trạng thái (`terraform.tfstate`) lưu trữ thông tin thực tế hiện tại của hạ tầng để đối chiếu liên tục với mã nguồn cấu hình[cite: 12].

---

## 3. Vòng Đời Hoạt Động Và Cơ Chế Vận Hành Bên Trong

### Vòng Đời Cơ Bản (4 Bước)
Write (Viết cấu hình .tf) ➔ Plan (Xem trước thay đổi) ➔ Apply (Thực thi thay đổi) ➔ Destroy (Hủy bỏ hạ tầng)
### Cơ Chế Vận Hành Bên Trong
Hệ thống Terraform hoạt động tách biệt thành hai tiến trình độc lập và giao tiếp với nhau thông qua cổng **gRPC** trên `localhost`[cite: 15]:
1. **Terraform Core:** Chịu trách nhiệm đọc tệp cấu hình `.tf`, xây dựng biểu đồ phụ thuộc (Dependency Graph), so sánh cấu hình hiện tại với tệp trạng thái (`state`) để tính toán sự khác biệt (diff)[cite: 16]. Tiến trình Core hoàn toàn không chứa mã nguồn cụ thể về AWS hay bất kỳ Cloud nào khác[cite: 16].
2. **Provider Plugin:** Được tải về máy khi khởi tạo dự án[cite: 17]. Tiến trình này định nghĩa schema cho tài nguyên và chuyển đổi các yêu cầu trừu tượng từ Core thành các cuộc gọi API thực tế (thông qua Cloud SDK)[cite: 17]. Sau khi tạo xong, nó sẽ trả lại ID tài nguyên cho Core để ghi vào tệp `state`[cite: 17].

---

## 4. Cài Đặt và CLI cơ bản
Các lệnh CLI chính bạn cần nắm vững[cite: 19]:
* `init`: Chuẩn bị thư mục làm việc, tải các provider và module cần thiết[cite: 20].
* `validate`: Kiểm tra tính nhất quán và cú pháp của tệp cấu hình[cite: 21].
* `plan`: Xem trước tất cả các thay đổi sẽ tác động đối với hạ tầng[cite: 22].
* `apply`: Tiến hành tạo mới hoặc cập nhật hạ tầng thực tế[cite: 23].
* `destroy`: Xóa bỏ toàn bộ hạ tầng đã được tạo trước đó[cite: 24].

> **Mẹo nâng cao:** Sử dụng lệnh `terraform -install-autocomplete` để kích hoạt tính năng tự động gợi ý lệnh bằng phím `Tab` trên Terminal[cite: 26]. Ngoài ra còn có các lệnh nâng cao khác như `fmt`, `console`, `graph`, `import`, `output`, `providers`, `show`, `state`, `test`[cite: 25].