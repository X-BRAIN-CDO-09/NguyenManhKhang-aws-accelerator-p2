# Rollout Steps and Pause

## Canary Strategy

```yaml
strategy:
  canary:
    steps:
    - setWeight: 10
    - pause: {}
    - setWeight: 25
    - pause:
        duration: 10m
    - setWeight: 50
    - pause: {}
    - setWeight: 100
```

---

## setWeight

Điều chỉnh tỷ lệ traffic.

Ví dụ:

```yaml
- setWeight: 10
```

Traffic:

- 90% Stable
- 10% Canary

---

## Manual Pause

```yaml
pause: {}
```

Rollout dừng vô thời hạn.

DevOps phải:

```bash
kubectl argo rollouts promote APP_NAME
```

---

## Automated Pause

```yaml
pause:
  duration: 10m
```

Tự động tiếp tục sau thời gian quy định.

---

## Quy trình hoàn chỉnh

10% → Pause

25% → Pause

50% → Pause

100% → Promote
