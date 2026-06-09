# 07_GitOps_And_ArgoCD.md

# GitOps & ArgoCD

## Mục tiêu học tập

Sau bài học này bạn sẽ:

* Hiểu GitOps là gì.
* Hiểu sự khác biệt giữa Push-Based và Pull-Based Deployment.
* Hiểu 4 nguyên tắc GitOps.
* Hiểu Configuration Drift.
* Hiểu Self-Healing.
* Hiểu vai trò của ArgoCD trong Kubernetes.

---

# 1. GitOps là gì?

GitOps là phương pháp quản lý hệ thống trong đó:

```text
Git
=
Single Source of Truth
```

Mọi thay đổi phải đi qua Git.

---

# 2. Mô hình truyền thống (Push-Based)

CI/CD Pipeline:

```text
GitHub Actions
↓
kubectl apply
↓
Kubernetes Cluster
```

Pipeline đẩy cấu hình trực tiếp vào Cluster.

---

## Nhược điểm

### Khó Audit

Không biết ai sửa gì.

---

### Configuration Drift

Git khác Cluster.

---

### Manual Change

Admin có thể sửa trực tiếp.

---

# 3. GitOps (Pull-Based)

GitOps đảo ngược quy trình.

```text
Developer
↓
Git Repository
↓
ArgoCD
↓
Kubernetes Cluster
```

ArgoCD sẽ tự kéo cấu hình.

---

# 4. Single Source of Truth

Git là nơi duy nhất được phép thay đổi.

---

## Không được phép

```bash
kubectl edit deployment
```

```bash
kubectl scale deployment
```

```bash
kubectl apply -f
```

trên Production.

---

## Phải thực hiện

```text
Edit YAML
↓
Commit
↓
Pull Request
↓
Merge
```

---

# 5. 4 Nguyên tắc GitOps

## Declarative

Khai báo trạng thái mong muốn.

Ví dụ:

```yaml
replicas: 3
```

Không phải:

```bash
kubectl scale deployment
```

---

## Versioned

Mọi cấu hình nằm trong Git.

Có:

* History
* Audit
* Rollback

---

## Pulled Automatically

ArgoCD tự động kéo thay đổi.

```text
Git
↓
ArgoCD Pull
↓
Cluster
```

---

## Reconciled Continuously

ArgoCD liên tục so sánh:

```text
Desired State
```

và

```text
Actual State
```

---

# 6. Desired State vs Actual State

Desired State:

```yaml
replicas: 3
```

---

Actual State:

```yaml
replicas: 10
```

---

ArgoCD phát hiện:

```text
OutOfSync
```

và sửa lại.

---

# 7. Configuration Drift

Là hiện tượng:

```text
Git
≠
Cluster
```

Ví dụ:

Admin:

```bash
kubectl edit deployment
```

---

Git:

```yaml
replicas: 3
```

Cluster:

```yaml
replicas: 10
```

---

Đây gọi là:

```text
Configuration Drift
```

---

# 8. Self-Healing

Tính năng nổi bật nhất của GitOps.

ArgoCD tự động:

```text
Detect Drift
↓
Correct Drift
```

---

Ví dụ

Git:

```yaml
replicas: 3
```

Cluster:

```yaml
replicas: 1
```

ArgoCD:

```text
Auto Scale Back
```

về:

```yaml
replicas: 3
```

---

# 9. Luồng GitOps hoàn chỉnh

## App Repository

Developer:

```text
Push Code
```

---

GitHub Actions:

```text
Build
Test
Docker Build
Push Registry
```

---

Image mới:

```text
my-app:v1.2.0
```

---

## GitOps Repository

GitHub Actions:

```text
Update image tag
```

Từ:

```yaml
image: my-app:v1.1.0
```

Thành:

```yaml
image: my-app:v1.2.0
```

---

## ArgoCD

Phát hiện commit mới:

```text
Pull
↓
Sync
↓
Deploy
```

---

# 10. Vai trò của ArgoCD

ArgoCD là Kubernetes Controller.

Nhiệm vụ:

```text
Observe
Compare
Sync
Heal
```

---

# 11. Trạng thái trong ArgoCD

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

## Healthy

Ứng dụng hoạt động bình thường.

---

## Degraded

Ứng dụng gặp lỗi.

---

# 12. Ưu điểm GitOps

## Audit

Toàn bộ lịch sử trong Git.

---

## Rollback

Git Revert.

---

## Security

Không cần cấp quyền kubectl cho nhiều người.

---

## Consistency

Không có Configuration Drift.

---

## Self-Healing

Tự động sửa lỗi.

---

# 13. GitOps Enterprise Workflow

```text
Developer
↓
Git Push
↓
GitHub Actions
↓
Docker Registry
↓
Update GitOps Repo
↓
Pull Request
↓
Review
↓
Merge
↓
ArgoCD Sync
↓
Kubernetes Cluster
```

---

# 14. Best Practices

## Không sửa trực tiếp Cluster

Sai:

```bash
kubectl edit
```

---

## Mọi thay đổi phải qua Git

Đúng:

```text
Commit
↓
Merge
↓
Sync
```

---

## Bật Self-Heal

```yaml
selfHeal: true
```

---

## Bật Prune

```yaml
prune: true
```

---

# Tổng kết

GitOps dựa trên 4 nguyên tắc:

```text
Declarative
Versioned
Pulled Automatically
Reconciled Continuously
```

ArgoCD là công cụ giúp hiện thực hóa các nguyên tắc đó trên Kubernetes.

Đây là nền tảng trước khi học:

* ArgoCD Architecture
* Application CRD
* Sync Policy
* App of Apps
* ApplicationSet
* Sync Waves
* Rollback
