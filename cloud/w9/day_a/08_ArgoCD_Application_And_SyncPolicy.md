# 08_ArgoCD_Application_And_SyncPolicy.md

# ArgoCD Application & Sync Policy

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu kiến trúc ArgoCD.
* Hiểu Application CRD.
* Hiểu Source và Destination.
* Hiểu Sync Policy.
* Hiểu Manual Sync và Automated Sync.
* Hiểu Prune và Self-Heal.
* Biết cách triển khai ứng dụng bằng ArgoCD.

---

# 1. ArgoCD Architecture

ArgoCD được triển khai như một ứng dụng trong Kubernetes Cluster.

Kiến trúc cơ bản:

```text
Git Repository
       │
       ▼
 Repo Server
       │
       ▼
Application Controller
       │
       ▼
Kubernetes Cluster
```

---

## Repo Server

Chức năng:

* Clone Git Repository
* Đọc YAML Manifest
* Render Helm Chart
* Render Kustomize

Ví dụ:

```text
Git
↓
Deployment.yaml
↓
Repo Server
```

---

## Application Controller

Nhiệm vụ:

```text
Observe
Compare
Sync
Heal
```

Liên tục so sánh:

```text
Desired State (Git)
```

và

```text
Actual State (Cluster)
```

---

## API Server

Cung cấp:

* Web UI
* CLI
* RBAC
* Authentication

---

# 2. Application CRD là gì?

ArgoCD giới thiệu Custom Resource:

```text
Application
```

Đây là đối tượng quan trọng nhất.

Một Application định nghĩa:

```text
Lấy gì từ Git?
Triển khai ở đâu?
Triển khai như thế nào?
```

---

# 3. Cấu trúc Application

Ví dụ:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application

metadata:
  name: frontend

spec:
  source:
  destination:
  syncPolicy:
```

---

# 4. Source

Source định nghĩa:

```text
Code ở đâu?
```

Ví dụ:

```yaml
source:
  repoURL: https://github.com/company/gitops-repo
  targetRevision: main
  path: apps/frontend
```

---

## repoURL

Repository chứa manifest.

Ví dụ:

```text
gitops-repo
```

---

## targetRevision

Branch hoặc Tag.

Ví dụ:

```yaml
targetRevision: main
```

---

## path

Thư mục cần deploy.

Ví dụ:

```yaml
path: apps/frontend
```

---

# 5. Destination

Destination định nghĩa:

```text
Deploy tới đâu?
```

Ví dụ:

```yaml
destination:
  server: https://kubernetes.default.svc
  namespace: frontend
```

---

## server

Kubernetes Cluster đích.

Ví dụ:

```text
Production Cluster
```

---

## namespace

Namespace triển khai.

Ví dụ:

```text
frontend
backend
monitoring
```

---

# 6. Sync Status

ArgoCD hiển thị trạng thái:

---

## Synced

```text
Git
=
Cluster
```

---

## OutOfSync

```text
Git
≠
Cluster
```

---

# 7. Health Status

## Healthy

Ứng dụng hoạt động bình thường.

---

## Progressing

Đang rollout.

---

## Missing

Resource không tồn tại.

---

## Degraded

Ứng dụng lỗi.

Ví dụ:

```text
CrashLoopBackOff

ImagePullBackOff
```

---

# 8. Manual Sync

Mặc định ArgoCD hoạt động ở chế độ:

```text
Observe Only
```

Không deploy tự động.

---

## Luồng hoạt động

```text
Git Commit
↓
ArgoCD Detect
↓
OutOfSync
↓
User Click Sync
↓
Deploy
```

---

## Ưu điểm

* Kiểm soát chặt
* An toàn Production

---

## Nhược điểm

* Phụ thuộc con người

---

# 9. Automated Sync

ArgoCD tự động triển khai.

Ví dụ:

```yaml
syncPolicy:
  automated: {}
```

---

## Luồng hoạt động

```text
Git Commit
↓
ArgoCD Detect
↓
Auto Sync
↓
Deploy
```

---

## Ưu điểm

* Không cần thao tác thủ công
* Chuẩn GitOps

---

## Nhược điểm

* Cần quy trình review tốt

---

# 10. Prune

Prune cho phép ArgoCD xóa tài nguyên không còn tồn tại trong Git.

---

## Git

```text
Deployment
Service
Ingress
```

---

## Sau khi xóa khỏi Git

```text
Deployment
Service
```

---

## Khi bật Prune

```yaml
syncPolicy:
  automated:
    prune: true
```

ArgoCD sẽ:

```text
Delete Ingress
```

---

# 11. Self Heal

Tính năng quan trọng nhất.

---

Git:

```yaml
replicas: 3
```

---

Admin:

```bash
kubectl scale deployment frontend --replicas=10
```

---

Cluster:

```yaml
replicas: 10
```

---

ArgoCD phát hiện Drift:

```text
OutOfSync
```

và sửa lại:

```yaml
replicas: 3
```

---

## Cấu hình

```yaml
syncPolicy:
  automated:
    selfHeal: true
```

---

# 12. Automated Sync đầy đủ

```yaml
syncPolicy:

  automated:

    prune: true

    selfHeal: true
```

---

# 13. Application YAML hoàn chỉnh

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application

metadata:
  name: frontend

spec:

  project: default

  source:
    repoURL: https://github.com/company/gitops-repo
    targetRevision: main
    path: apps/frontend

  destination:
    server: https://kubernetes.default.svc
    namespace: frontend

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

# 14. Luồng triển khai chuẩn

```text
Developer
↓
Commit
↓
Pull Request
↓
Review
↓
Merge
↓
ArgoCD Detect
↓
Auto Sync
↓
Kubernetes
```

---

# 15. Best Practices

## Production

```text
Auto Sync = ON
Prune = ON
Self Heal = ON
```

---

## Không deploy bằng kubectl

Sai:

```bash
kubectl apply -f deployment.yaml
```

---

## Git là Source of Truth

Mọi thay đổi phải đi qua Pull Request.

---

# Tổng kết

Ba trường quan trọng nhất trong Application:

```text
Source
Destination
SyncPolicy
```

Ba tính năng mạnh nhất của ArgoCD:

```text
Auto Sync
Prune
Self Heal
```

Đây là nền tảng để triển khai App of Apps và ApplicationSet.
