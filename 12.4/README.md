#### 12.4 Сетевое взаимодействие в K8S. Часть 1

##### 1) Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

- ###### Создаем deployment (сделал уже с сервисом и подом):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 3
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
          value: "8080"   
        ports:
        - containerPort: 8080
          name: multi-port

---

apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
    - name: nginx
      port: 9001
      protocol: TCP
      targetPort: 80

    - name: multi
      port: 9002
      protocol: TCP
      targetPort: 8080

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

- ###### Проверяем:
```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/myapp created
service/myapp created
pod/multitool created
$ microk8s.kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
multitool                1/1     Running   0          112s
myapp-7c6c9d6b9d-sq5xc   2/2     Running   0          112s
myapp-7c6c9d6b9d-rdhcr   2/2     Running   0          112s
myapp-7c6c9d6b9d-22ljh   2/2     Running   0          112s
$ microk8s.kubectl get svc myapp
NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
myapp   ClusterIP   10.152.183.153   <none>        9001/TCP,9002/TCP   2m16s
```

- ###### Проверяем доступность портов приложения curl`ом:
```shell
$ microk8s.kubectl exec multitool -- curl myapp:9001
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
100   615  100   615    0     0   216k      0 --:--:-- --:--:-- --:--:--  300k
```
```shell
$ microk8s.kubectl exec multitool -- curl myapp:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   140  100   140    0     0  44052      0 --:--:-- --:--:-- --:--:-- 46666
WBITT Network MultiTool (with NGINX) - myapp-7c6c9d6b9d-sq5xc - 10.1.35.182 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

##### 2) Создать Service и обеспечить доступ к приложениям снаружи кластера

- ###### Создаем отдельный сервис (дополняем Deployment.yml):

```yaml
---

apiVersion: v1
kind: Service
metadata:
  name: myapp-nodeport
spec:
  selector:
    app: myapp
  type: NodePort
  ports:
    - name: nginx
      port: 80
      protocol: TCP
      nodePort: 30080
```
- ###### Применяем и проверяем:

```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/myapp unchanged
service/myapp unchanged
pod/multitool unchanged
service/myapp-nodeport created
```

```shell
$ microk8s.kubectl get svc 
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubernetes       ClusterIP   10.152.183.1     <none>        443/TCP             42d
myapp            ClusterIP   10.152.183.153   <none>        9001/TCP,9002/TCP   15m
myapp-nodeport   NodePort    10.152.183.166   <none>        80:30080/TCP        2m40s
```
```shell
$ curl localhost:30080
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