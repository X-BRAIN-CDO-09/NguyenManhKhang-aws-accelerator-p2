# 02_Git_Workflow_And_Branch_Strategy.md

# Git Workflow & Branch Strategy

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu cách Git được sử dụng trong CI/CD.
* Thành thạo Branch Strategy phổ biến.
* Hiểu Pull Request Workflow.
* Phân biệt Merge và Rebase.
* Hiểu Semantic Versioning.
* Biết cách bảo vệ nhánh Production.
* Áp dụng Git Workflow chuẩn doanh nghiệp.

---

# 1. Tại sao Git quan trọng trong CI/CD?

CI/CD chỉ hoạt động hiệu quả khi source code được quản lý chặt chẽ.

Git cung cấp:

* Version Control
* Collaboration
* Audit Trail
* Rollback Capability

Mọi pipeline CI/CD đều bắt đầu từ Git Event:

```text
Push
Pull Request
Merge
Tag Release
```

---

# 2. Git Workflow là gì?

Git Workflow là quy tắc làm việc chung của nhóm nhằm tránh:

* Xung đột code
* Ghi đè code
* Triển khai nhầm

Ví dụ:

```text
Developer A
     ↓
Feature Branch
     ↓
Pull Request
     ↓
Code Review
     ↓
Merge Main
     ↓
CI/CD Pipeline
```

---

# 3. Các Branch phổ biến

## Main Branch

Là nhánh chính.

Ví dụ:

```text
main
master
```

Yêu cầu:

* Luôn deploy được
* Không commit trực tiếp

---

## Feature Branch

Dùng phát triển tính năng mới.

Ví dụ:

```text
feature/login

feature/payment

feature/dashboard
```

Luồng:

```text
main
 ↓
feature/login
 ↓
Pull Request
 ↓
main
```

---

## Bugfix Branch

Dùng sửa lỗi.

Ví dụ:

```text
bugfix/logout

bugfix/api-error
```

---

## Hotfix Branch

Dùng xử lý sự cố Production.

Ví dụ:

```text
hotfix/payment-failure

hotfix/security-vulnerability
```

---

# 4. Feature Branch Workflow

Workflow phổ biến nhất hiện nay.

## Bước 1

Tạo branch

```bash
git checkout -b feature/login
```

---

## Bước 2

Code

```bash
git add .
git commit -m "Add login feature"
```

---

## Bước 3

Push

```bash
git push origin feature/login
```

---

## Bước 4

Tạo Pull Request

```text
feature/login
↓
main
```

---

## Bước 5

CI Pipeline chạy

```text
Build
Test
Lint
Security Scan
```

---

## Bước 6

Review

Reviewer:

* Kiểm tra logic
* Kiểm tra coding style
* Kiểm tra security

---

## Bước 7

Merge

Sau khi:

* CI PASS
* Review PASS

---

# 5. Pull Request (PR)

## Pull Request là gì?

PR là yêu cầu gộp code từ branch này sang branch khác.

Ví dụ:

```text
feature/login
↓
main
```

---

## Lợi ích

### Code Review

Nhiều người cùng kiểm tra.

---

### Chạy CI

Tự động kiểm tra.

---

### Thảo luận

Review comment trực tiếp trên code.

---

### Audit

Lưu lịch sử thay đổi.

---

# 6. Merge và Rebase

## Merge

```text
main
│
├── commit A
│
├── commit B
│
└── merge commit
```

Lệnh:

```bash
git merge feature/login
```

### Ưu điểm

* Dễ sử dụng
* An toàn

### Nhược điểm

* History phức tạp

---

## Rebase

```text
main
│
├── commit A
├── commit B
├── commit C
└── commit D
```

Lệnh:

```bash
git rebase main
```

### Ưu điểm

* History sạch

### Nhược điểm

* Dễ conflict

---

# 7. Semantic Versioning

Quy tắc:

```text
MAJOR.MINOR.PATCH
```

Ví dụ:

```text
1.0.0
1.1.0
1.1.1
2.0.0
```

---

## PATCH

Fix bug.

```text
1.0.0
↓
1.0.1
```

---

## MINOR

Thêm feature.

```text
1.0.0
↓
1.1.0
```

---

## MAJOR

Breaking Change.

```text
1.0.0
↓
2.0.0
```

---

# 8. Git Tag

Tạo release.

```bash
git tag v1.0.0
```

Push tag:

```bash
git push origin v1.0.0
```

---

# 9. Branch Protection

## Review Required

Yêu cầu reviewer.

Ví dụ:

```text
Minimum Reviewers = 2
```

---

## Status Check Required

CI phải PASS.

```text
Build PASS
Test PASS
Security PASS
```

---

## Restrict Push

Không cho push trực tiếp vào main.

---

## Require Signed Commit

Bắt buộc commit có chữ ký.

---

# 10. Workflow chuẩn doanh nghiệp

```text
Developer
↓
Feature Branch
↓
Commit
↓
Push
↓
Pull Request
↓
GitHub Actions
↓
Review
↓
Approve
↓
Merge Main
↓
Deploy
```

---

# Tổng kết

Bạn cần thành thạo:

* Feature Branch Workflow
* Pull Request
* Merge
* Rebase
* Semantic Versioning
* Branch Protection

Đây là nền tảng trước khi học GitHub Actions.
