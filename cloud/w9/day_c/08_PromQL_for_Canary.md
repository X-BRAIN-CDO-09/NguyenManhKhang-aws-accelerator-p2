# PromQL for Canary

## Error Rate

```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

---

## Success Rate

```promql
sum(rate(http_requests_total{status!~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

---

## Latency P95

```promql
histogram_quantile(
 0.95,
 sum by (le)(
  rate(http_request_duration_seconds_bucket[5m])
 )
)
```

---

## RED Method

### Rate

Số lượng request.

### Errors

Tỷ lệ lỗi.

### Duration

Độ trễ.
