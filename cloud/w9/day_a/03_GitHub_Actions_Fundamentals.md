# 03_GitHub_Actions_Fundamentals.md

# GitHub Actions Fundamentals

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu GitHub Actions hoạt động thế nào.
* Hiểu Workflow, Job, Step, Runner.
* Biết cách viết workflow YAML.
* Hiểu Event Trigger.
* Hiểu Dependency giữa các Job.
* Chuẩn bị cho phần CI Pipeline thực tế.

---

# 1. GitHub Actions là gì?

GitHub Actions là nền tảng CI/CD tích hợp sẵn trong GitHub.

Cho phép tự động hóa:

* Build
* Test
* Security Scan
* Deploy

---

# 2. Kiến trúc GitHub Actions

```text
Workflow
│
├── Job
│   ├── Step
│   ├── Step
│   └── Step
│
└── Job
    ├── Step
    └── Step
```

---

# 3. Workflow

Workflow là quy trình tự động.

Nằm trong:

```text
.github/workflows/
```

Ví dụ:

```yaml
name: CI Pipeline
```

---

## Workflow Trigger

Ví dụ:

```yaml
on:
  push:
```

Khi có push:

```text
Developer Push
↓
Workflow chạy
```

---

# 4. Các Trigger phổ biến

## Push

```yaml
on:
  push:
```

---

## Pull Request

```yaml
on:
  pull_request:
```

---

## Schedule

```yaml
on:
  schedule:
```

Cron:

```yaml
cron: '0 0 * * *'
```

---

## Manual

```yaml
on:
  workflow_dispatch:
```

---

# 5. Job

Job là tập hợp các Step.

Ví dụ:

```yaml
jobs:
  test:
```

---

## Job chạy song song

```yaml
jobs:
  build:
  test:
  security:
```

Mặc định:

```text
Parallel Execution
```

---

# 6. Job Dependency

Dùng:

```yaml
needs:
```

Ví dụ:

```yaml
deploy:
  needs: test
```

```text
Test
↓
Deploy
```

---

# 7. Step

Step là đơn vị nhỏ nhất.

Ví dụ:

```yaml
steps:
```

---

## Step chạy Command

```yaml
- run: npm test
```

---

## Step chạy Action

```yaml
- uses: actions/checkout@v4
```

---

# 8. Runner

Runner là máy thực thi workflow.

Ví dụ:

```yaml
runs-on: ubuntu-latest
```

---

## GitHub Hosted Runner

Do GitHub quản lý.

Ví dụ:

```text
ubuntu-latest
windows-latest
macos-latest
```

---

## Self Hosted Runner

Do doanh nghiệp tự quản lý.

Ưu điểm:

* Kiểm soát hoàn toàn
* Truy cập private network

Nhược điểm:

* Tự vận hành

---

# 9. Action là gì?

Action là thành phần tái sử dụng.

Ví dụ:

```yaml
uses: actions/checkout@v4
```

---

## Action phổ biến

### Checkout

```yaml
actions/checkout
```

Clone source code.

---

### Setup Node

```yaml
actions/setup-node
```

---

### Setup Java

```yaml
actions/setup-java
```

---

### Docker Login

```yaml
docker/login-action
```

---

# 10. Secrets

Dùng lưu thông tin nhạy cảm.

Ví dụ:

```text
AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

DOCKERHUB_TOKEN
```

---

## Truy cập Secrets

```yaml
${{ secrets.AWS_ACCESS_KEY_ID }}
```

---

# 11. Environment Variables

Ví dụ:

```yaml
env:
  APP_ENV: production
```

Truy cập:

```bash
echo $APP_ENV
```

---

# 12. Workflow YAML hoàn chỉnh

```yaml
name: CI Pipeline

on:
  push:

jobs:
  test:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4

      - name: Install
        run: npm ci

      - name: Test
        run: npm test

      - name: Build
        run: npm run build
```

---

# 13. Luồng thực thi thực tế

```text
Push Code
↓
GitHub Event
↓
Workflow
↓
Runner
↓
Checkout
↓
Install Dependencies
↓
Run Tests
↓
Build
↓
Result
```

---

# 14. Best Practices

## Workflow nhỏ

Mỗi workflow chỉ phục vụ một mục đích.

---

## Dùng Cache

Tăng tốc build.

---

## Không hardcode Secret

Dùng GitHub Secrets.

---

## Pin Version

Ví dụ:

```yaml
actions/checkout@v4
```

Không dùng:

```yaml
actions/checkout@latest
```

---

# Tổng kết

GitHub Actions được xây dựng trên 4 thành phần cốt lõi:

```text
Workflow
↓
Jobs
↓
Steps
↓
Runner
```

Hiểu rõ 4 thành phần này là điều kiện bắt buộc trước khi học:

* Standard CI Pipeline
* Docker Pipeline
* Terraform Pipeline
* GitOps Automation
