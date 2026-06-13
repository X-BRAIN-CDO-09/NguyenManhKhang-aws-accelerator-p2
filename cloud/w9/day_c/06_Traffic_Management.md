# Traffic Management

## Tại sao cần Traffic Router

Kubernetes Service chia traffic theo Round Robin.

Ví dụ:

- 9 Pod V1
- 1 Pod V2

Traffic = 90/10

Không đủ linh hoạt.

---

## NGINX Ingress

Sử dụng:

```yaml
nginx.ingress.kubernetes.io/canary
```

Ưu điểm:

- Dễ triển khai
- Phổ biến

---

## Istio

Sử dụng:

- VirtualService
- DestinationRule

Ví dụ:

```yaml
route:
- destination:
    subset: stable
  weight: 90

- destination:
    subset: canary
  weight: 10
```

---

## So sánh

| Tiêu chí | NGINX | Istio |
|-----------|--------|--------|
| Độ phức tạp | Thấp | Cao |
| North-South Traffic | Có | Có |
| East-West Traffic | Không | Có |
| Routing nâng cao | Hạn chế | Mạnh |
