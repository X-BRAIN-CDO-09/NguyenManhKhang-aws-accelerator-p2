# Kubernetes ConfigMap, Sidecar và Persistent Storage

# 1. ConfigMap

ConfigMap dùng để lưu trữ cấu hình dưới dạng key-value và tách cấu hình khỏi mã nguồn ứng dụng.

---

# 1.1 ConfigMap Mount dưới dạng Volume

## Cơ chế

Kubelet:

1. Đọc ConfigMap
2. Chuyển thành file trong volume
3. Mount vào container

```text
ConfigMap
    ↓
Volume
    ↓
Container
```

---

## Khi ConfigMap thay đổi

```bash
kubectl edit configmap my-config
```

Các file bên trong Pod sẽ được cập nhật tự động sau một khoảng thời gian ngắn.

---

## Lưu ý

Ứng dụng chỉ nhận cấu hình mới nếu:

* Có cơ chế Watch
* Có cơ chế Poll file

Nếu ứng dụng chỉ đọc file lúc startup:

```text
ConfigMap đổi
↓
File đổi
↓
Ứng dụng KHÔNG đổi
```

=> Cần restart Pod.

---

# 1.2 ConfigMap dưới dạng Environment Variables

Ví dụ:

```yaml
env:
  - name: APP_MODE
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: mode
```

---

## Hành vi cập nhật

Nếu sửa ConfigMap:

```bash
kubectl edit configmap app-config
```

Biến môi trường trong Pod hiện tại:

```text
KHÔNG thay đổi
```

---

## Cách áp dụng

```bash
kubectl rollout restart deployment my-app
```

Kubernetes sẽ tạo Pod mới với giá trị mới.

---

# 1.3 So sánh Volume vs Environment Variable

| Phương thức          | Khi ConfigMap đổi |
| -------------------- | ----------------- |
| Volume               | File tự cập nhật  |
| Environment Variable | Không cập nhật    |

---

# 1.4 Immutable ConfigMap

## Khai báo

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: app-config

immutable: true
```

---

## Mục đích

Dùng cho cấu hình:

* Không thay đổi
* Tăng hiệu năng
* Giảm số lượng watch từ kubelet

---

## Hạn chế

Không thể:

```text
Sửa dữ liệu
```

Không thể:

```text
immutable=true
↓
immutable=false
```

---

## Quy trình cập nhật

### Bước 1

Tạo ConfigMap mới

```yaml
app-config-v2
```

### Bước 2

Sửa Deployment

```yaml
configMap:
  name: app-config-v2
```

### Bước 3

Kubernetes rollout

```text
Pod mới
↓
Config mới
```

### Bước 4

Xóa ConfigMap cũ

---

# 1.5 Bảng Tổng Hợp

| Cách dùng | Khi ConfigMap đổi | Hành động           |
| --------- | ----------------- | ------------------- |
| Volume    | File tự cập nhật  | App phải watch file |
| Env       | Không cập nhật    | rollout restart     |
| Immutable | Không cho sửa     | Tạo ConfigMap mới   |

---

# 2. Ví dụ Redis với ConfigMap

## Kiến trúc

```text
ConfigMap
    ↓
redis.conf
    ↓
Volume
    ↓
/redis-master/redis.conf
    ↓
redis-server
```

---

## Trạng thái ban đầu

```text
maxmemory = 0
maxmemory-policy = noeviction
```

---

## Cập nhật ConfigMap

```yaml
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
```

---

## Hiện tượng

Redis vẫn hiển thị:

```text
maxmemory = 0
maxmemory-policy = noeviction
```

---

## Nguyên nhân

Redis chỉ đọc:

```text
redis.conf
```

một lần khi khởi động.

Redis không tự reload file cấu hình.

---

## Cách xử lý

```bash
kubectl delete pod redis
```

Tạo lại Pod:

```bash
kubectl apply -f redis-pod.yaml
```

---

## Kết quả

```text
maxmemory = 2097152
maxmemory-policy = allkeys-lru
```

---

# 3. Sidecar Container

## Sidecar là gì?

Container phụ trợ chạy cùng Pod với ứng dụng chính.

Ví dụ:

* Logging
* Monitoring
* mTLS
* Data Sync

---

# 3.1 Built-in Sidecar

Từ Kubernetes v1.33.

Khai báo:

```yaml
initContainers:
  - name: sidecar
    restartPolicy: Always
```

---

# 3.2 Ưu điểm

## Khởi động

### Cũ

```text
App
↔
Sidecar
```

Không đảm bảo thứ tự.

---

### Mới

```text
Sidecar
↓
App
```

Đảm bảo sidecar sẵn sàng trước.

---

## Tắt máy

### Cũ

Thứ tự ngẫu nhiên.

### Mới

```text
App tắt
↓
Sidecar tắt
```

---

## Với Job

### Cũ

Job có thể bị kẹt.

### Mới

Job hoàn thành bình thường.

---

# 3.3 Kiểm tra Feature Gate

API Server:

```bash
kubectl get --raw /metrics | grep SidecarContainers
```

---

Node:

```bash
kubectl get --raw /api/v1/nodes/<node>/proxy/metrics | grep SidecarContainers
```

---

# 3.4 Lỗi Webhook

Một số Service Mesh cũ:

* Istio cũ
* Mutating Webhook cũ

có thể xóa:

```yaml
restartPolicy: Always
```

---

Kiểm tra:

```bash
kubectl describe pod mypod
```

---

# 4. Persistent Storage

---

# 4.1 Static Provisioning

## Thành phần

```text
Disk
 ↓
PersistentVolume (PV)
 ↓
PersistentVolumeClaim (PVC)
 ↓
Pod
```

---

## Vai trò

### Admin

Tạo:

```text
PV
```

Ví dụ:

```text
10Gi
```

---

### Developer

Tạo:

```text
PVC
```

Ví dụ:

```text
3Gi
```

---

### Kubernetes

Tự động:

```text
Bind PV ↔ PVC
```

---

# 4.2 Trạng thái

## Ban đầu

```text
PV = Available
```

---

## Sau khi Bind

```text
PV = Bound
PVC = Bound
```

---

# 5. SubPath

Dùng một PVC nhưng mount vào nhiều vị trí khác nhau.

---

## Ví dụ

```yaml
volumeMounts:
  - name: config
    mountPath: /usr/share/nginx/html
    subPath: html

  - name: config
    mountPath: /etc/nginx/nginx.conf
    subPath: nginx.conf
```

---

## Ý nghĩa

```text
PV
├── html/
└── nginx.conf
```

Mount:

```text
html/
→ /usr/share/nginx/html

nginx.conf
→ /etc/nginx/nginx.conf
```

---

## Lưu ý

Phải tạo trước:

```text
/mnt/data/html
/mnt/data/nginx.conf
```

Nếu không Kubernetes sẽ tạo thư mục rỗng gây lỗi.

---

# 6. Storage Permission bằng GID

## Vấn đề

```text
Permission Denied
```

khi container ghi dữ liệu.

---

## Giải pháp

Trong PV:

```yaml
metadata:
  annotations:
    pv.beta.kubernetes.io/gid: "1234"
```

---

## Cơ chế

Kubernetes tự động:

```text
Container
↓
Group 1234
↓
Có quyền ghi dữ liệu
```

---

# 7. Cleanup

## Redis

```bash
kubectl delete pod/redis
kubectl delete configmap/example-redis-config
```

---

## Persistent Storage

```bash
kubectl delete pod task-pv-pod
kubectl delete pvc task-pv-claim
kubectl delete pv task-pv-volume
```

---

# Cheat Sheet Ôn Thi

```text
ConfigMap
├── Volume → File tự update
├── Env → Rollout Restart
└── Immutable → Tạo ConfigMap mới

Sidecar
├── restartPolicy: Always
├── Start trước App
└── Stop sau App

Storage
├── PV
├── PVC
├── Bound
├── subPath
└── GID

Redis
├── ConfigMap update
├── File update
└── Redis phải restart
```
