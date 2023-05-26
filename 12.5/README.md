#### 12.5 Сетевое взаимодействие в K8S. Часть 2

##### 1) Создать Deployment приложений backend и frontend

- ###### Создаем Deplyment.yml (два сервиса: frontend 3 реплики, backend 1):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:          
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: nginx-port

---

apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
    - name: http
      port: 80
      protocol: TCP

---

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:          
      - name: multitool
        image: wbitt/network-multitool  
        ports:
        - containerPort: 80
          name: multi-port

---

apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
    - name: http
      port: 80
      protocol: TCP


```

- ###### Применяем и проверяем на доступность между собой:
```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/frontend created
service/frontend created
deployment.apps/backend created
service/backend create
```

```shell
$ microk8s.kubectl exec frontend-85cb7b678d-vddpx -- curl backend
  % Total    % ReceWBITT Network MultiTool (with NGINX) - backend-77db8bfd95-qp968 - 10.1.35.152 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
ived % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   140  100   140    0     0  28000      0 --:--:-- --:--:-- --:--:-- 28000
```

```shell
$ microk8s.kubectl exec backend-77db8bfd95-qp968 -- curl frontend
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   300k      0 --:--:-- --:--:-- --:--:--  600k
```

##### 2) Создать Ingress и обеспечить доступ к приложениям снаружи кластера

- ###### Включаем ingress в microk8s:
```shell
$ microk8s enable ingress
Infer repository core for addon ingress
Enabling Ingress
ingressclass.networking.k8s.io/public created
ingressclass.networking.k8s.io/nginx created
namespace/ingress created
serviceaccount/nginx-ingress-microk8s-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-microk8s-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-microk8s-role created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-microk8s created
configmap/nginx-load-balancer-microk8s-conf created
configmap/nginx-ingress-tcp-microk8s-conf created
configmap/nginx-ingress-udp-microk8s-conf created
daemonset.apps/nginx-ingress-microk8s-controller created
Ingress is enabled
```

- ###### Дополняем и применяем Deplayment.yml:
```yaml
---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
spec:
  rules:
    - host:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: frontend
              port:
                number: 80
        - path: /api
          pathType: Prefix
          backend:
            service:
              name: backend
              port:
                number: 80
```
```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/frontend unchanged
service/frontend unchanged
deployment.apps/backend unchanged
service/backend unchanged
ingress.networking.k8s.io/ingress configured
```

- ##### Пробуем получить ответ с помощью curl:
```shell
$ curl localhost 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
```shell
 curl localhost/api
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.20.2</center>
</body>
</html>
```
хм... 

Для наглядности сделал линк:
```shell
$ microk8s.kubectl exec backend-77db8bfd95-qp968 -- ln -s /usr/share/nginx/html /usr/share/nginx/html/api
```
```shell
$ curl localhost/api/
WBITT Network MultiTool (with NGINX) - backend-77db8bfd95-qp968 - 10.1.35.142 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
