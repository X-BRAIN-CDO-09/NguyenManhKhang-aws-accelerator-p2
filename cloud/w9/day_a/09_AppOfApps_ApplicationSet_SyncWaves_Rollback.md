# 09_AppOfApps_ApplicationSet_SyncWaves_Rollback.md

# Advanced GitOps Patterns

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu App of Apps Pattern.
* Hiểu ApplicationSet.
* Hiểu Sync Waves.
* Hiểu GitOps Rollback.
* Biết cách quản lý hàng chục hoặc hàng trăm ứng dụng Kubernetes.

---

# 1. Vấn đề khi hệ thống lớn lên

Ban đầu:

```text
frontend
```

Một Application là đủ.

---

Sau vài tháng:

```text
frontend
backend
redis
postgres
ingress
monitoring
logging
```

---

Sau vài năm:

```text
50+
Applications
```

Việc quản lý từng Application riêng lẻ trở nên khó khăn.

---

# 2. App of Apps Pattern

Ý tưởng:

```text
Một Application
Quản lý
Nhiều Application khác
```

---

## Kiến trúc

```text
Root Application

├── frontend-app
├── backend-app
├── ingress-app
├── monitoring-app
└── logging-app
```

---

# 3. Root Application

Chỉ cần deploy:

```text
root-app
```

ArgoCD sẽ tự động tạo:

```text
frontend
backend
monitoring
logging
```

---

## Ví dụ cấu trúc Git

```text
gitops-repo

applications/

├── root-app.yaml
├── frontend-app.yaml
├── backend-app.yaml
├── ingress-app.yaml
└── monitoring-app.yaml
```

---

# 4. Lợi ích App of Apps

## Single Entry Point

Một nơi quản lý toàn bộ hệ thống.

---

## Declarative

Mọi thứ nằm trong Git.

---

## Scalability

Quản lý hàng trăm ứng dụng.

---

## Cascading Deletion

Xóa Root App:

```text
Root App
↓
Child Apps
↓
Resources
```

đều bị xóa theo.

---

# 5. ApplicationSet là gì?

ApplicationSet là Controller giúp sinh Application tự động.

---

Thay vì:

```text
frontend-dev
frontend-staging
frontend-prod
```

tạo thủ công.

ApplicationSet sinh tự động.

---

# 6. Vấn đề không dùng ApplicationSet

Ví dụ:

20 Services

x

3 Environment

=

60 Applications

---

Bạn phải viết:

```text
60 YAML Files
```

---

# 7. ApplicationSet Solution

Viết:

```text
1 Template
```

Sinh:

```text
60 Applications
```

---

# 8. Ví dụ Multi Environment

Input:

```text
dev
staging
prod
```

---

ApplicationSet tạo:

```text
frontend-dev
frontend-staging
frontend-prod
```

---

# 9. Các Generator phổ biến

## List Generator

```yaml
elements:
- env: dev
- env: staging
- env: prod
```

---

## Git Generator

Đọc thư mục Git.

Ví dụ:

```text
apps/*
```

---

## Cluster Generator

Tạo Application cho nhiều Cluster.

Ví dụ:

```text
Singapore Cluster

Tokyo Cluster

US Cluster
```

---

# 10. Sync Waves

## Vấn đề

ArgoCD mặc định deploy đồng thời.

Ví dụ:

```text
Backend
Database
Ingress
```

cùng lúc.

---

## Hậu quả

Backend khởi động trước Database.

```text
Connection Refused
```

---

Ingress tạo trước Namespace.

```text
Deployment Failed
```

---

# 11. Sync Wave hoạt động thế nào?

ArgoCD gán:

```text
Wave Number
```

cho từng Resource.

---

Nguyên tắc:

```text
Wave nhỏ hơn
↓
Chạy trước
```

---

ArgoCD đợi:

```text
Wave hiện tại Healthy
```

mới chuyển sang:

```text
Wave tiếp theo
```

---

# 12. Cấu hình Sync Wave

```yaml
metadata:

  annotations:

    argocd.argoproj.io/sync-wave: "2"
```

---

# 13. Thứ tự triển khai chuẩn

## Wave -5

```text
Namespace
CRDs
```

---

## Wave -2

```text
ConfigMap
Secrets
Vault
```

---

## Wave 0

```text
Database

PostgreSQL
MySQL
Redis
```

---

## Wave 2

```text
Backend Services
```

---

## Wave 5

```text
Frontend

Ingress
```

---

# 14. Rollback trong GitOps

Khi deploy lỗi:

```text
Production Down
```

Cần quay về trạng thái an toàn.

---

# 15. Cách 1 - kubectl rollout undo

```bash
kubectl rollout undo deployment/backend
```

---

## Vấn đề

Nếu Self-Heal bật:

```text
ArgoCD
↓
Phát hiện Drift
↓
Deploy lại bản lỗi
```

Rollback thất bại.

---

# 16. Cách 2 - ArgoCD Rollback

```bash
argocd app rollback
```

---

## Ưu điểm

Rất nhanh.

---

## Nhược điểm

Git và Cluster lệch nhau.

```text
Git ≠ Cluster
```

---

# 17. Cách 3 - Git Revert (Khuyến nghị)

Đây là cách chuẩn GitOps.

---

## Bước 1

Tìm commit lỗi.

```bash
git log
```

---

## Bước 2

Revert.

```bash
git revert <commit-id>
```

---

## Bước 3

Push.

```bash
git push
```

---

## Bước 4

Merge Pull Request.

---

## Bước 5

ArgoCD Sync.

```text
Git Revert
↓
ArgoCD Detect
↓
Sync
↓
Cluster Restore
```

---

# 18. Tại sao Git Revert tốt nhất?

## Audit

Biết ai revert.

---

## Compliance

Có lịch sử đầy đủ.

---

## Không Drift

```text
Git
=
Cluster
```

---

## Không cần tắt Auto Sync

ArgoCD vẫn hoạt động bình thường.

---

# 19. Enterprise GitOps Architecture

```text
Developer
↓
Application Repo
↓
GitHub Actions
↓
Docker Registry
↓
GitOps Repo
↓
Pull Request
↓
Merge
↓
ArgoCD
↓
ApplicationSet
↓
App Of Apps
↓
Kubernetes
```

---

# Tổng kết

Khi hệ thống lớn:

```text
Application
↓
App of Apps
↓
ApplicationSet
```

Khi cần thứ tự triển khai:

```text
Sync Waves
```

Khi Production gặp lỗi:

```text
Git Revert
```

Đây là mô hình GitOps mà phần lớn Platform Team, DevOps Team và SRE Team đang áp dụng trong môi trường Kubernetes quy mô lớn.
