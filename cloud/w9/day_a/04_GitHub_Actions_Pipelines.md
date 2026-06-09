# 04_GitHub_Actions_Pipelines.md

# GitHub Actions Pipelines

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu cách xây dựng Pipeline thực tế.
* Viết được Pipeline CI hoàn chỉnh.
* Build và Push Docker Image tự động.
* Tự động hóa Terraform Plan trên Pull Request.
* Hiểu luồng CI/CD hiện đại trong doanh nghiệp.

---

# 1. Pipeline là gì?

Pipeline là chuỗi các bước tự động được thực thi nhằm:

* Kiểm tra code
* Kiểm thử
* Build artifact
* Đóng gói ứng dụng
* Triển khai hệ thống

Ví dụ:

```text
Developer Push Code
↓
CI Pipeline
↓
Build
↓
Test
↓
Artifact
↓
Deploy
```

---

# 2. Standard CI Pipeline

## Mục tiêu

Tự động:

* Lint
* Test
* Build

Mỗi lần developer push code.

---

## Luồng hoạt động

```text
Push Code
↓
Checkout
↓
Install Dependencies
↓
Lint
↓
Unit Test
↓
Build
↓
Success
```

---

## Workflow YAML

```yaml
name: Standard CI Pipeline

on:
  push:
    branches:
      - '**'

jobs:
  code-quality-and-build:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4

        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run Lint
        run: npm run lint

      - name: Run Tests
        run: npm run test

      - name: Build Application
        run: npm run build
```

---

# 3. Phân tích Pipeline

## Checkout

```yaml
uses: actions/checkout@v4
```

Clone source code về Runner.

---

## Setup Runtime

```yaml
uses: actions/setup-node@v4
```

Cài NodeJS.

---

## Install Dependencies

```bash
npm ci
```

Ưu điểm:

* Nhanh hơn npm install
* Chính xác theo package-lock.json

---

## Lint

```bash
npm run lint
```

Mục tiêu:

* Coding Convention
* Code Quality

---

## Test

```bash
npm run test
```

Kiểm tra:

* Unit Test
* Integration Test

---

## Build

```bash
npm run build
```

Tạo artifact.

---

# 4. Docker Pipeline

## Mục tiêu

Tự động:

* Build Docker Image
* Push Docker Hub

khi merge vào main.

---

## Luồng hoạt động

```text
Push Main
↓
Checkout
↓
Docker Login
↓
Build Image
↓
Push Image
```

---

# 5. DockerHub Secrets

Repository Settings

```text
Settings
↓
Secrets and Variables
↓
Actions
```

Tạo:

```text
DOCKERHUB_USERNAME

DOCKERHUB_TOKEN
```

---

# 6. Docker Build Pipeline

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:

  docker-build-push:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Login DockerHub

        uses: docker/login-action@v3

        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Setup Buildx

        uses: docker/setup-buildx-action@v3

      - name: Build and Push

        uses: docker/build-push-action@v5

        with:
          context: .
          file: ./Dockerfile
          push: true

          tags: |
            myuser/myapp:latest
            myuser/myapp:${{ github.sha }}
```

---

# 7. Docker Tag Strategy

## latest

```text
myapp:latest
```

Luôn trỏ tới phiên bản mới nhất.

---

## Commit SHA

```text
myapp:2f4f8ad
```

Ưu điểm:

* Truy vết chính xác
* Rollback dễ

---

## Semantic Version

```text
myapp:v1.0.0
myapp:v1.1.0
myapp:v2.0.0
```

Thường dùng Production.

---

# 8. Terraform Pull Request Pipeline

## Mục tiêu

Không deploy ngay.

Chỉ xem trước thay đổi.

---

## Luồng hoạt động

```text
Pull Request
↓
Terraform Init
↓
Terraform Validate
↓
Terraform Plan
↓
Comment PR
```

---

## Lợi ích

* Review trước khi Apply
* Phát hiện rủi ro
* Tránh phá Production

---

# 9. Terraform PR Workflow

```yaml
on:
  pull_request:
    branches:
      - main
```

Khi tạo Pull Request.

---

## Terraform Setup

```yaml
uses: hashicorp/setup-terraform@v3
```

---

## Terraform Init

```bash
terraform init
```

Mục tiêu:

* Download Provider
* Backend Init

---

## Terraform Plan

```bash
terraform plan
```

Hiển thị:

```text
+ Create
~ Update
- Destroy
```

---

# 10. CI Pipeline Best Practices

## Fail Fast

Nếu Test fail:

```text
Stop Pipeline
```

Không chạy Build.

---

## Caching

Ví dụ:

```yaml
cache: npm
```

Giảm thời gian build.

---

## Small Jobs

Không tạo pipeline khổng lồ.

---

## Version Pinning

Tốt:

```yaml
actions/checkout@v4
```

Không nên:

```yaml
actions/checkout@latest
```

---

# Tổng kết

Ba pipeline quan trọng nhất:

1. Standard CI
2. Docker Build & Push
3. Terraform Plan

Đây là nền tảng của mọi hệ thống GitOps hiện đại.
