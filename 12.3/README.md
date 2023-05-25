### 12.3. Запуск приложений в K8S

##### 1) Создать Deployment и обеспечить доступ к репликам приложения из другого Pod
- ###### Файл Deplayment.yaml (изменен порт http у multitool):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:          
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: nginx-port
      
      - name: multitool
        image: wbitt/network-multitool  
        env:
        - name: HTTP_PORT
          value: "8081"   
        ports:
        - containerPort: 8081
          name: multi-http-port
```

Запускаем:
```shell
$ microk8s kubectl apply -f ./Deployment.yaml 
deployment.apps/myapp created
$ microk8s kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-6cc8879fdc-pfd2g   2/2     Running   0          6s
```
- ###### Пробуем увеличить количество реплик изменив "replicas: 1" -> "replicas: 2"
```shell
$ microk8s kubectl apply -f ./Deployment.yaml 
deployment.apps/myapp configured
```
- Проверяем результат:
```shell
$ microk8s kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-6cc8879fdc-pfd2g   2/2     Running   0          8m29s
myapp-6cc8879fdc-tbqlf   2/2     Running   0          6s
```

- ###### Создаем сервис для нашего приложения (дополняем Deplayment.yaml):
```yaml
---

apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
    - name: http
      port: 80
      protocol: TCP

    - name: http-multi
      port: 8081
      protocol: TCP
```
Применяем изенения:
```shell
$ microk8s kubectl apply -f ./Deployment.yaml 
deployment.apps/myapp unchanged
service/myapp created
```
Смотрим, что получилось:
```shell
$ microk8s kubectl get deployments,svc myapp
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myapp   2/2     2            2           14m

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
service/myapp   ClusterIP   10.152.183.253   <none>        80/TCP,8081/TCP   2m37s
$ curl 10.152.183.253
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
$ curl 10.152.183.253:8081
WBITT Network MultiTool (with NGINX) - myapp-6cc8879fdc-pfd2g - 10.1.35.153 - HTTP: 8081 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
- ###### Создаем отдельный pod multitool (дополняем Deplayment.yaml):
```yaml
---

apiVersion: v1
kind: Pod
metadata:
  name: multitool
spec:
  containers:
  - image: wbitt/network-multitool
    name: multitool
```
```shell
$ microk8s kubectl apply -f ./Deployment.yaml 
deployment.apps/myapp unchanged
service/myapp unchanged
pod/multitool created
$ microk8s kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-6cc8879fdc-pfd2g   2/2     Running   0          20m
myapp-6cc8879fdc-m45mg   2/2     Running   0          6m14s
multitool                1/1     Running   0          46s
```
Проверяем доступность с отдельного pod`а нашего app:
```shell
$ microk8s.kubectl exec multitool -- curl 10.152.183.253
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
100   615  100   615    0     0   430k      0 --:--:-- --:--:-- --:--:--  600k
```

- ###### (additional) Curl by service name:
```shell
$ microk8s.kubectl exec multitool -- curl myapp
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
<!DOCTYPE html>    0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
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
100   615  100   615    0     0  41805      0 --:--:-- --:--:-- --:--:-- 43928
```


#### 2) Создать Deployment и обеспечить старт основного контейнера при выполнении условий
- ###### Создаем deployment (файл Deployment2.yaml):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:          
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: nginx-port
      
      initContainers:
      - image: busybox
        name: init
        command: ['sh', '-c', "until nslookup nginx.default.svc.cluster.local; do echo 'not ready yet'; sleep 10; done;"]
```
Запускаем:
```shell
$ microk8s.kubectl apply -f ./Deployment2.yaml 
deployment.apps/nginx created
```
Смотрим что получилось:
```shell
 microk8s.kubectl logs -f nginx-7d6d9d6d79-sb8pv -c init
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

not ready yet
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

not ready yet
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

not ready yet
^C
$ microk8s.kubectl get pods
NAME                     READY   STATUS     RESTARTS   AGE
nginx-7d6d9d6d79-sb8pv   0/1     Init:0/1   0          36s
```

Добавляем сервис:
```yaml
---

apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - name: http
      port: 80
      protocol: TCP
```
```shell
$ microk8s.kubectl apply -f ./Deployment2.yaml 
deployment.apps/nginx unchanged
service/nginx created
```

Результат:
```shell
not ready yet
Server:         10.152.183.10
Address:        10.152.183.10:53

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

** server can't find nginx.default.svc.cluster.local: NXDOMAIN

not ready yet
Server:         10.152.183.10
Address:        10.152.183.10:53


Name:   nginx.default.svc.cluster.local
Address: 10.152.183.93

$ microk8s.kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7d6d9d6d79-sb8pv   1/1     Running   0          86s
```
