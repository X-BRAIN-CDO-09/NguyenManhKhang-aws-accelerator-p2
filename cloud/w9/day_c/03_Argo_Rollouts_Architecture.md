# Argo Rollouts Architecture

## Tại sao cần Argo Rollouts

Deployment không hỗ trợ:

- Canary
- Blue-Green
- Automated Analysis

Argo Rollouts giải quyết các vấn đề đó.

---

## Rollout CRD

Thay vì:

```yaml
kind: Deployment
```

Sử dụng:

```yaml
kind: Rollout
```

---

## GitOps Workflow

```text
Git
 ↓
ArgoCD
 ↓
Rollout CRD
 ↓
Argo Rollouts Controller
 ↓
ReplicaSets
 ↓
Pods
```

---

## Luồng hoạt động

### Git

Developer cập nhật image tag.

### ArgoCD

Phát hiện thay đổi.

### Rollout CRD

Kubernetes tiếp nhận khai báo.

### Rollouts Controller

Thực hiện:

- Canary
- Blue-Green
- Analysis

---

## Vai trò của Controller

Controller quản lý:

- Stable ReplicaSet
- Canary ReplicaSet

và điều khiển:

- NGINX
- Istio
- Linkerd

để phân chia traffic.
