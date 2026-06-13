# AnalysisTemplate

## Vai trò

Tự động đánh giá sức khỏe Canary.

---

## Thành phần

### Metric

Tên chỉ số cần đo.

### Interval

Tần suất query.

Ví dụ:

```yaml
interval: 1m
```

### Success Condition

```yaml
successCondition: result[0] >= 0.99
```

### Failure Limit

```yaml
failureLimit: 2
```

---

## Ví dụ

```yaml
kind: AnalysisTemplate

metrics:
- name: success-rate
  interval: 1m

  successCondition: result[0] >= 0.99

  failureLimit: 2
```
