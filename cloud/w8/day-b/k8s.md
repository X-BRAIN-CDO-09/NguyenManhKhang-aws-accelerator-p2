# Kubernetes (K8s) - Tóm tắt Kiến thức & Thực hành

## 1. Giới thiệu chung về Kubernetes

### Kubernetes là gì?

Kubernetes (K8s) là nền tảng mã nguồn mở cấp sản xuất dùng để điều phối (orchestrate) các container ứng dụng trong và giữa các cụm máy tính.

### Mục tiêu

* Đảm bảo dịch vụ luôn sẵn sàng 24/7
* Hỗ trợ triển khai phiên bản mới nhiều lần trong ngày
* Giảm hoặc loại bỏ downtime

### Minikube

Minikube là môi trường Kubernetes thu gọn chạy trên máy cá nhân.

Đặc điểm:

* Tạo một cụm Kubernetes cục bộ
* Chỉ gồm một Node
* Phục vụ học tập và phát triển

---

# 2. Kiến trúc Kubernetes Cluster

Một Kubernetes Cluster gồm hai thành phần chính:

## Control Plane

Đóng vai trò là bộ não của cụm.

### Chức năng

* Scheduling Pods
* Duy trì trạng thái mong muốn (Desired State)
* Scaling
* Rolling Update

### Giao tiếp

Người dùng tương tác thông qua Kubernetes API.

---

## Nodes

Là các máy vật lý hoặc máy ảo dùng để chạy ứng dụng.

### Thành phần trong Node

#### Kubelet

* Giao tiếp với Control Plane
* Quản lý Pod và Container

#### Container Runtime

Ví dụ:

* containerd
* CRI-O

### Khuyến nghị Production

Nên có tối thiểu:

```text
3 Nodes
```

để đảm bảo tính dự phòng (High Availability).

---

# 3. Kubernetes Deployment

Deployment dùng để triển khai và quản lý ứng dụng.

## Chức năng

* Tạo Pod
* Cập nhật Pod
* Scale Pod
* Rollback

## Self-Healing

Nếu:

* Node hỏng
* Pod bị xóa

Deployment sẽ tự động tạo Pod mới thay thế.

---

# 4. Kubectl Cơ Bản

Kubectl là CLI dùng để tương tác với Kubernetes API.

## Kiểm tra Cluster

### Xem phiên bản

```bash
kubectl version
```

### Xem Nodes

```bash
kubectl get nodes
```

---

## Triển khai ứng dụng

```bash
kubectl create deployment kubernetes-bootcamp \
--image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

### Xem Deployment

```bash
kubectl get deployments
```

---

## Truy cập ứng dụng bằng Proxy

### Khởi động Proxy

```bash
kubectl proxy
```

### Kiểm tra kết nối

```bash
curl http://localhost:8001/version
```

### Lấy tên Pod

```bash
export POD_NAME=$(kubectl get pods \
-o go-template \
--template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
```

### Truy cập Pod

```bash
curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME:8080/proxy/
```

---

# 5. Pods và Nodes

## Pod

Pod là đơn vị nhỏ nhất của Kubernetes.

### Đặc điểm

* Chứa một hoặc nhiều Container
* Chia sẻ Storage
* Chia sẻ Network
* Chạy trên cùng một Node

### Lưu ý

Deployment tạo Pod chứ không tạo Container trực tiếp.

---

## Node

Là nơi Pod được chạy.

Mỗi Node gồm:

* Kubelet
* Container Runtime

---

# 6. Các lệnh Troubleshooting

## Liệt kê tài nguyên

```bash
kubectl get pods
```

## Xem chi tiết

```bash
kubectl describe pods
```

## Xem Logs

```bash
kubectl logs POD_NAME
```

## Truy cập Container

```bash
kubectl exec -ti POD_NAME -- bash
```

---

# 7. Kubernetes Service

Pods có thể bị thay thế bất cứ lúc nào nên IP thay đổi liên tục.

Service tạo một lớp trừu tượng để truy cập ổn định.

## Chức năng

* Service Discovery
* Load Balancing
* External Access

---

## Các loại Service

### ClusterIP

Mặc định.

Chỉ truy cập được trong Cluster.

---

### NodePort

Cho phép truy cập:

```text
NodeIP:NodePort
```

---

### LoadBalancer

Tạo Load Balancer từ Cloud Provider.

---

### ExternalName

Mapping tới DNS CNAME.

---

# 8. Labels và Selectors

## Labels

Dạng:

```yaml
app: nginx
env: dev
version: v1
```

Dùng để phân loại tài nguyên.

---

## Selectors

Service dùng Selector để tìm Pod phù hợp.

Ví dụ:

```yaml
app=kubernetes-bootcamp
```

---

# 9. Thực hành Service

## Tạo Service

```bash
kubectl expose deployment/kubernetes-bootcamp \
--type="NodePort" \
--port=8080
```

---

## Kiểm tra Service

```bash
kubectl describe services/kubernetes-bootcamp
```

hoặc

```bash
minikube service kubernetes-bootcamp --url
```

---

# 10. Quản lý Labels

## Tìm Pod theo Label

```bash
kubectl get pods -l app=kubernetes-bootcamp
```

---

## Gắn Label

```bash
kubectl label pods "$POD_NAME" version=v1
```

---

# 11. Xóa Service

```bash
kubectl delete service -l app=kubernetes-bootcamp
```

Lưu ý:

* Service bị xóa
* Deployment vẫn chạy

Muốn tắt ứng dụng hoàn toàn cần xóa Deployment.

---

# 12. Scaling

## Khái niệm

Scale được thực hiện bằng cách thay đổi số lượng Replica.

### Scale Out

Tăng số lượng Pod.

### Scale Down

Giảm số lượng Pod.

---

## Load Balancing

Service chỉ gửi traffic tới Pod đang sẵn sàng.

---

## Kiểm tra ReplicaSet

```bash
kubectl get deployments
kubectl get rs
```

---

## Scale lên 4 Pods

```bash
kubectl scale deployments/kubernetes-bootcamp --replicas=4
```

---

## Kiểm tra Pods

```bash
kubectl get pods -o wide
```

---

# 13. Rolling Update

## Định nghĩa

Cho phép cập nhật phiên bản ứng dụng mà không gây downtime.

---

## Cơ chế

* Tạo Pod mới
* Đợi Pod mới Ready
* Xóa Pod cũ

---

## Lợi ích

* Zero Downtime
* An toàn
* Có thể Rollback

---

# 14. Cập nhật ứng dụng

## Update Image

```bash
kubectl set image deployments/kubernetes-bootcamp \
kubernetes-bootcamp=docker.io/jocatalin/kubernetes-bootcamp:v2
```

---

## Kiểm tra trạng thái

```bash
kubectl rollout status deployments/kubernetes-bootcamp
```

---

## Kiểm tra lỗi

```bash
kubectl get pods
```

Ví dụ lỗi:

```text
ImagePullBackOff
```

---

## Xem chi tiết lỗi

```bash
kubectl describe pods
```

---

# 15. Rollback

Khôi phục phiên bản ổn định trước đó.

```bash
kubectl rollout undo deployments/kubernetes-bootcamp
```

---

# 16. Cleanup

Xóa toàn bộ tài nguyên sau khi thực hành.

```bash
kubectl delete deployments/kubernetes-bootcamp services/kubernetes-bootcamp
```

---

# Mindmap Ôn Thi Nhanh

```text
Cluster
├── Control Plane
│   ├── Scheduling
│   ├── Scaling
│   └── Updates
│
├── Node
│   ├── Kubelet
│   └── Container Runtime
│
├── Pod
│   └── Containers
│
├── Deployment
│   ├── Self-Healing
│   ├── Scale
│   └── Rolling Update
│
└── Service
    ├── ClusterIP
    ├── NodePort
    ├── LoadBalancer
    └── ExternalName
```
