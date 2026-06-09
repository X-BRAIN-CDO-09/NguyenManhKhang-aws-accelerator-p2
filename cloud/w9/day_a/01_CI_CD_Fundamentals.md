# CI/CD Fundamentals

## Mục tiêu học tập

Sau khi hoàn thành bài này, bạn cần:

* Hiểu CI (Continuous Integration) là gì.
* Hiểu CD (Continuous Delivery và Continuous Deployment).
* Phân biệt được CI, Continuous Delivery và Continuous Deployment.
* Hiểu luồng làm việc chuẩn trong doanh nghiệp.
* Hiểu vai trò của Git, Docker, Registry và Pipeline trong hệ sinh thái CI/CD.
* Nắm được các lợi ích và thách thức khi triển khai CI/CD.

---

# 1. CI/CD là gì?

CI/CD là tập hợp các phương pháp và công cụ giúp tự động hóa quá trình:

* Tích hợp mã nguồn
* Kiểm thử
* Đóng gói ứng dụng
* Triển khai hệ thống

Mục tiêu cuối cùng là:

* Giảm lỗi do thao tác thủ công
* Tăng tốc độ phát hành sản phẩm
* Nâng cao chất lượng phần mềm
* Tạo quy trình triển khai nhất quán

---

# 2. Continuous Integration (CI)

## Định nghĩa

Continuous Integration (CI) là quá trình thường xuyên tích hợp code của các thành viên vào cùng một repository và tự động kiểm tra chất lượng của code sau mỗi lần thay đổi.

Ý tưởng cốt lõi:

> Mỗi thay đổi nhỏ phải được kiểm tra ngay lập tức.

Thay vì đợi đến cuối tuần hoặc cuối sprint mới gộp code, CI yêu cầu:

* Commit thường xuyên
* Push thường xuyên
* Kiểm tra tự động thường xuyên

---

## Vấn đề trước khi có CI

Ví dụ:

Developer A:

```text
Làm việc 5 ngày
```

Developer B:

```text
Làm việc 5 ngày
```

Đến cuối tuần:

```text
Merge Code
↓
Conflict
↓
Build Error
↓
Production Delay
```

Các vấn đề thường gặp:

* Merge Conflict lớn
* Build thất bại
* Test thất bại
* Không xác định được ai gây lỗi

Đây được gọi là:

```text
Integration Hell
```

---

## CI giải quyết vấn đề như thế nào?

Thay vì merge sau nhiều ngày:

```text
Code
↓
Commit
↓
Push
↓
CI Pipeline
↓
Feedback ngay lập tức
```

Nếu có lỗi:

* Build fail
* Test fail
* Security fail

Pipeline sẽ dừng ngay.

Developer sửa lỗi trước khi tiếp tục.

---

# 3. Các thành phần trong CI

## Build

Mục tiêu:

Xác minh ứng dụng có thể biên dịch hoặc đóng gói thành công.

Ví dụ:

NodeJS

```bash
npm run build
```

Java

```bash
mvn package
```

Gradle

```bash
./gradlew build
```

Go

```bash
go build
```

Nếu Build thất bại:

* Không được triển khai
* Không được merge

---

## Automated Testing

### Unit Test

Kiểm tra từng hàm riêng lẻ.

Ví dụ:

```javascript
add(2,3) = 5
```

Công cụ:

* Jest
* JUnit
* Pytest
* Go Test

---

### Integration Test

Kiểm tra sự tương tác giữa các thành phần.

Ví dụ:

```text
API
↓
Database
↓
Redis
```

---

### End-to-End Test

Mô phỏng hành vi người dùng.

Ví dụ:

```text
Login
↓
Add Cart
↓
Checkout
```

Công cụ:

* Cypress
* Playwright
* Selenium

---

## Code Quality Check

Mục tiêu:

Đảm bảo code tuân thủ coding standard.

Ví dụ:

### ESLint

```bash
npm run lint
```

### PHPStan

```bash
phpstan analyse
```

### GolangCI-Lint

```bash
golangci-lint run
```

---

## Security Scan

Mục tiêu:

Phát hiện lỗ hổng trước khi triển khai.

### SAST

Static Application Security Testing

Phân tích source code.

Ví dụ:

* SonarQube
* Semgrep
* Checkmarx

---

### Dependency Scan

Kiểm tra thư viện bên thứ ba.

Ví dụ:

```text
Log4j
OpenSSL
Spring Boot
```

Công cụ:

* Snyk
* Dependabot
* OWASP Dependency Check

---

### Container Scan

Kiểm tra Docker Image.

Công cụ:

* Trivy
* Grype
* Clair

Ví dụ:

```bash
trivy image myapp:latest
```

---

# 4. Continuous Delivery (CD)

## Định nghĩa

Continuous Delivery là quá trình tự động chuẩn bị mọi thứ cho việc triển khai nhưng vẫn yêu cầu con người xác nhận trước khi đưa lên Production.

Luồng:

```text
Push Code
↓
Build
↓
Test
↓
Docker Build
↓
Deploy Staging
↓
Manual Approval
↓
Deploy Production
```

---

## Ưu điểm

* Kiểm soát tốt Production
* Giảm rủi ro
* Phù hợp doanh nghiệp lớn

---

## Nhược điểm

* Cần thao tác thủ công
* Chậm hơn Continuous Deployment

---

# 5. Continuous Deployment

## Định nghĩa

Continuous Deployment tự động triển khai tất cả thay đổi lên Production nếu toàn bộ pipeline thành công.

Luồng:

```text
Push Code
↓
Build
↓
Test
↓
Security Scan
↓
Deploy Production
```

Không cần:

* Approval
* Human Intervention

---

## Ưu điểm

* Release nhanh
* Tự động hóa hoàn toàn
* Feedback từ người dùng sớm

---

## Nhược điểm

* Rủi ro cao hơn
* Yêu cầu chất lượng test rất tốt

---

# 6. So sánh Continuous Delivery và Continuous Deployment

| Tiêu chí                  | Delivery | Deployment |
| ------------------------- | -------- | ---------- |
| Manual Approval           | Có       | Không      |
| Deploy tự động Production | Không    | Có         |
| Mức độ tự động hóa        | Cao      | Rất cao    |
| Độ an toàn                | Cao      | Thấp hơn   |
| Tốc độ Release            | Chậm hơn | Nhanh hơn  |

---

# 7. Luồng CI/CD thực tế trong doanh nghiệp

## Bước 1: Developer Push Code

```text
Feature Branch
```

Ví dụ:

```text
feature/login
```

---

## Bước 2: Pull Request

```text
feature/login
↓
main
```

---

## Bước 3: CI Pipeline

Pipeline thực hiện:

```text
Checkout
↓
Build
↓
Lint
↓
Test
↓
Security Scan
```

---

## Bước 4: Code Review

Reviewer kiểm tra:

* Logic
* Security
* Performance
* Coding Convention

---

## Bước 5: Merge

Sau khi:

* CI Pass
* Reviewer Approve

---

## Bước 6: Build Artifact

Ví dụ:

Docker Image

```text
myapp:v1.0.0
```

---

## Bước 7: Push Registry

Ví dụ:

* Docker Hub
* Amazon ECR
* Google Artifact Registry
* GitHub Container Registry

---

## Bước 8: Deploy

Có thể deploy tới:

* Dev
* Staging
* Production

---

# 8. Các công cụ phổ biến trong hệ sinh thái CI/CD

## Source Control

* Git
* GitHub
* GitLab
* Bitbucket

---

## CI Engine

* GitHub Actions
* GitLab CI
* Jenkins
* CircleCI
* Azure DevOps

---

## Container

* Docker
* Podman

---

## Registry

* Docker Hub
* AWS ECR
* GCR
* GHCR

---

## Deployment

* Kubernetes
* ArgoCD
* FluxCD
* Helm

---

# 9. Ví dụ Pipeline CI/CD hoàn chỉnh

```text
Developer Push Code
↓
GitHub
↓
GitHub Actions
↓
Lint
↓
Unit Test
↓
Security Scan
↓
Build Docker Image
↓
Push Docker Hub
↓
Update GitOps Repo
↓
ArgoCD Sync
↓
Kubernetes Cluster
```

Đây là mô hình hiện đại được sử dụng phổ biến trong các hệ thống Cloud Native hiện nay.

---

# Tổng kết

CI giúp:

* Kiểm tra code liên tục
* Phát hiện lỗi sớm
* Giảm Integration Hell

Continuous Delivery giúp:

* Chuẩn bị deploy tự động
* Vẫn có bước phê duyệt

Continuous Deployment giúp:

* Triển khai hoàn toàn tự động

CI/CD là nền tảng bắt buộc trước khi học:

1. Git Workflow
2. GitHub Actions
3. Docker
4. Kubernetes
5. Terraform
6. GitOps
7. ArgoCD
8. Platform Engineering
