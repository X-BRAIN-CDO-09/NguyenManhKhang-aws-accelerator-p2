# SLO and Burn Rate

## Khái niệm

### SLI

Service Level Indicator

### SLO

Service Level Objective

Ví dụ:

99.95%

### Error Budget

```text
100% - 99.95%
=
0.05%
```

---

## Burn Rate

```text
Burn Rate
=
Actual Error Rate
/
Allowed Error Rate
```

---

## Quy tắc

### Continue

```text
Burn Rate < 2
```

Cho phép rollout tiếp tục.

---

### Warning

```text
2 <= Burn Rate <= 10
```

Tạm dừng quan sát.

---

### Abort

```text
Burn Rate > 10
```

Rollback ngay.

---

## PromQL Burn Rate

```promql
(
 sum(rate(http_requests_total{
   app="my-service",
   status=~"5.."
 }[5m]))
 /
 sum(rate(http_requests_total{
   app="my-service"
 }[5m]))
)
/
0.001
```

---

## Điều kiện Argo Rollouts

```yaml
successCondition: result[0] < 2

failureCondition: result[0] > 10
```

---

## Tư duy SRE

Từ:

- Metric Check

Sang:

- SLO Check
- Error Budget
- Burn Rate

Giúp triển khai an toàn ở quy mô lớn.
