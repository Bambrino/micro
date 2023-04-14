### 12.2. Базовые объекты K8S

##### 1) Создать Pod с именем hello-world

- Файл hello-world.yaml:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
    - name: hello-world
      image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
      ports:
        - containerPort: 8080

```
- Применяем:

```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl apply -f ./hello-world.yaml
pod/hello-world created
```

- Смотрим наличии pod`а:

```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl get po
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          65s
```

- Проброс порта:
```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl port-forward pods/hello-world 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
```

- Запрос curl`ом:

```shell
vvk@bubuntu:~$ curl localhost:8080


Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:8080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-

```


##### 2) Создать Service и подключить его к Pod

- Файл netology-web.yaml:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: netology-web
  labels:
    name: netology-web
spec:
  containers:
  - name: netology-web
    image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
    ports:
      - containerPort: 8080
        name: netology-port

---
apiVersion: v1
kind: Service
metadata:
  name: netology-svc
spec:
  selector:
    name: netology-web
  ports:
  - name: svc-netology-port
    protocol: TCP
    port: 8080
    targetPort: netology-port
```

- Применяем:

```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl apply -f ./netology-web.yaml 
pod/netology-web created
service/netology-svc created
```

- Смотрим наличиие сервиса и pod`а:

```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl get svc,po
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes     ClusterIP   10.152.183.1    <none>        443/TCP    25h
service/netology-svc   ClusterIP   10.152.183.23   <none>        8080/TCP   9s

NAME               READY   STATUS    RESTARTS   AGE
pod/hello-world    1/1     Running   0          7m28s
pod/netology-web   1/1     Running   0          9s
```

- Проброс порта:
```shell
vvk@bubuntu:~/dz/micro/12.2$ microk8s kubectl port-forward service/netology-svc 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
```

- Запрос curl`ом:

```shell
vvk@bubuntu:~$ curl localhost:8080


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:8080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-

```