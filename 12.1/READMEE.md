### 12.1. Kubernetes. Причины появления. Команда kubectl

#### 1) Установка microk8s:

```shell

vvk@bubuntu:~$ sudo snap install microk8s --classic --channel=1.27
microk8s (1.27/stable) v1.27.0 от Canonical✓ установлен
vvk@bubuntu:~$ sudo usermod -a -G microk8s vvk
vvk@bubuntu:~$ sudo chown -f -R vvk ~/.kube

```
#### 2) Проверяем состояние:

```shell
vvk@bubuntu:~$ microk8s status --wait-ready
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
  disabled:
    cert-manager         # (core) Cloud native certificate management
    community            # (core) The community addons repository
    gpu                  # (core) Automatic enablement of Nvidia CUDA
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    minio                # (core) MinIO object storage
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    storage              # (core) Alias to hostpath-storage add-on, deprecated

```

#### 3) После редактирования шаблона сертификата запускаем перегенерацию:

```shell
vvk@bubuntu:~$ sudo microk8s refresh-certs --cert front-proxy-client.crt
Taking a backup of the current certificates under /var/snap/microk8s/5101/certs-backup/
Creating new certificates
Signature ok
subject=CN = front-proxy-client
Getting CA Private Key
Restarting service kubelite.

```

#### 4) Добавляем dashboard:

```shell
vvk@bubuntu:~$ microk8s enable dashboard
Infer repository core for addon dashboard
Enabling Kubernetes Dashboard
Infer repository core for addon metrics-server
Enabling Metrics-Server
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
clusterrolebinding.rbac.authorization.k8s.io/microk8s-admin created
Metrics-Server is enabled
Applying manifest
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
secret/microk8s-dashboard-token created

If RBAC is not enabled access the dashboard using the token retrieved with:

microk8s kubectl describe secret -n kube-system microk8s-dashboard-token

Use this token in the https login UI of the kubernetes-dashboard service.

In an RBAC enabled setup (microk8s enable RBAC) you need to create a user with restricted
permissions as shown in:
https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md


```

#### 5) Смотрим статус dashboard`а:

```shell

vvk@bubuntu:~$ microk8s status 
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
  .......

```

#### 6) Получаем токен для авторизации в дашборде:

```shell

vvk@bubuntu:~$ microk8s kubectl describe secret -n kube-system microk8s-dashboard-token
Name:         microk8s-dashboard-token
Namespace:    kube-system
Labels:       kubernetes.io/legacy-token-last-used=2023-04-13
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 1e660278-60e4-4f16-a94e-eab2d393075e

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InhaWGJQWFJqNThMbjZ3Z2JxVEhYZE9LUGlIRFJvZEFxZEE4X1Y3akM2QUUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJtaWNyb2s4cy1kYXNoYm9hcmQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjFlNjYwMjc4LTYwZTQtNGYxNi1hOTRlLWVhYjJkMzkzMDc1ZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpkZWZhdWx0In0.YrB4YtiSa9MWZkSElZAHHyEkrzHsrJBFyAZcQ4SqJ8DjfzXIc1YnEZDT-Y9g6Y_UsJnxqnpRzTEG7vKZMcuXwtRtxxjdohCffVdTPMgdr04vlVLJg5wCCm7EnTf4Jx8hRUFZSk0Mkv_cs4UUGs3Ofxxszy1Yvd6m6jaaof3AqG6X_JHaieNs8kamSfaJnYR6uY_R9QCXfJi6yLdp0bGfbQppquaWSfLda5A5g4paFxAajAA6a0MWJz4Adrp8suKXDjIjByaXVS4aYexiBk7tG7bACIHfU4WrcuVQdwCCKFGtNv2vKF3-H5lD6FShlhu6v_ZlNthytxht74cd0t21og
ca.crt:     1123 bytes
namespace:  11 bytes
```

#### 7) Пробрасываем порт и пробуем подключиться:

```shell
vvk@bubuntu:~$ microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 --address 0.0.0.0
Forwarding from 0.0.0.0:10443 -> 8443
```

![Dashboard](https://github.com/Bambrino/micro/tree/main/12.1/kubedash.png)


