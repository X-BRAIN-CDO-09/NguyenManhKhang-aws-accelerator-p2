# Terraform + Kubernetes (Minikube) on AWS

## Mục tiêu

Triển khai một EC2 Ubuntu chạy Minikube và deploy app lên Kubernetes. ALB nhận traffic HTTP và chuyển đến service Kubernetes trên NodePort.

## Kiến trúc

ALB (HTTP 80) → Target Group → EC2 instance (port 30080) → Minikube NodePort service 30080 → Pod nginx

- `aws` provider: tạo VPC, subnet, IGW, route table, security group, EC2, ALB, target group, listener.
- `null` provider: copy script và manifest vào EC2, chạy cài đặt Minikube/kubectl/docker và deploy app.
- `tls` provider: Tạo cặp khóa SSH, Cung cấp khóa công khai  

## Cách chạy

Trong thư mục `cloud/w8/lap`:

```bash
terraform init
terraform plan
terraform apply 

```

Sau khi apply xong, lấy URL ALB:

```bash
terraform output -raw alb_dns_name
```

Mở trình duyệt:

```text
http://<alb_dns_name>
```

## Kiểm tra

![alb dns name sau khi chạy xong lệnh terraform apply](/cloud/w8/lap/image/output.png)
- sau khi apply xong sẽ hiện ra alb dns name 
![giao diện khi chạy xong](/cloud/w8/lap/image/trangchu.png)
- sao chép alb dns name đưa vào trình duyệt sẽ thấy giao diện
![chứng minh bằng ssh](/cloud/w8/lap/image/k8sonec2.png)
- minh chứng App thực sự chạy trong K8s, không cài thẳng EC2

## Dọn sạch

```bash
terraform destroy 
```
![bằng chứng sau khi chạy terraform destroy](/cloud/w8/lap/image/destroy.png)
- hiển thị sau khi chạy terraform destroy
## Các file quan trọng

- `main.tf`: định nghĩa infra AWS và provision Kubernetes.
- `variables.tf`: cấu hình biến đầu vào.
- `terraform.tfvars`: giá trị mặc định gồm region, instance type, và SSH key.
- `scripts/install.sh`: cài Docker, kubectl, Minikube.
- `scripts/deploy-app.sh`: deploy manifest Kubernetes và port-forward NodePort.
- `kubernetes/deployment.yaml`: Deployment nginx.
- `kubernetes/service.yaml`: Service NodePort 30080.

## Why this design?

- Dùng **Minikube trên EC2** để đảm bảo app chạy thực sự trong K8s, không phải install app trực tiếp trên VM.
- Dùng **ALB** để tạo URL public và route HTTP tới Kubernetes service.
- Dùng **`null` provider** để orchestration deployment sau khi AWS infra đã có, giúp kết hợp infra và provisioning trong cùng cấu hình Terraform.
- Dùng **`aws` provider** để quản lý toàn bộ AWS resources và đảm bảo cấu hình có thể tái tạo.

## Notes

- `terraform.tfvars` hiện tại dùng key:
  - `key_name = "minikube-key"`
  - `public_key_path = "C:/Users/OS/.ssh/id_ed25519.pub"`
  - `private_key_path = "C:/Users/OS/.ssh/id_ed25519"`
- Nếu không dùng file `.tfvars`, hãy cung cấp giá trị bằng `-var`.
- Hãy đảm bảo AWS credential đã cấu hình trước khi chạy `terraform init`.
