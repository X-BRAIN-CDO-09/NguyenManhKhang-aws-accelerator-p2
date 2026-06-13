# Rollout CRDs

## Các Custom Resource chính

### Rollout

Thay thế Deployment.

Quản lý:

- Canary
- Blue Green

---

### AnalysisTemplate

Định nghĩa:

- Metrics
- Success Criteria
- Failure Criteria

---

### AnalysisRun

Instance thực thi của AnalysisTemplate.

Nhiệm vụ:

- Query Prometheus
- Đánh giá rollout

---

### Experiment

Dùng cho:

- A/B Testing
- Load Testing
- Validation

---

## Quan hệ giữa các CRD

```text
Rollout
   |
   +---- AnalysisTemplate
   |
   +---- AnalysisRun
   |
   +---- Experiment
```
