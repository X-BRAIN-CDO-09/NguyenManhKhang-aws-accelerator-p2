# Success and Abort Criteria

## Success Criteria

Cho phép rollout tiếp tục.

Ví dụ:

- Error Rate < 1%
- Latency P95 < 300ms

---

## Abort Criteria

Rollback ngay lập tức.

Ví dụ:

- Error Rate > 5%
- Latency > 1s

---

## Chu trình Rollback

```text
Error xuất hiện
        ↓
Prometheus phát hiện
        ↓
AnalysisRun Failed
        ↓
Rollout Abort
        ↓
Traffic = 0% Canary
        ↓
100% Stable
```

---

## Auto Rollback

Ưu điểm:

- Không cần người can thiệp
- Giảm downtime
- Bảo vệ user
