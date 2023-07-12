### 14.5 Troubleshooting

##### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

###### 1) Деплоим указанное приложение:

```shell
$ microk8s kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.
yaml
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "web" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
```
Получаем ошибку об отсутствии необходимых пространств имен (namespaces) "web" и "data"

###### 2) Создаем недостающее:
```shell
$ microk8s kubectl create namespace web
namespace/web created
$ microk8s kubectl create namespace data
namespace/data created
```

###### 3) Повторяем размещение приложения:

```shell
$ microk8s kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
deployment.apps/web-consumer created
deployment.apps/auth-db created
service/auth-db created
```
Успешно. 

###### 4) Проверяем что с подами и смотрим логи, так как "...web-consumer не может подключиться к auth-db..."

```shell
$ microk8s kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-node-9ghxf                          1/1     Running   0          25h
kube-system   calico-kube-controllers-6c99c8747f-kxs94   1/1     Running   0          25h
kube-system   coredns-7745f9f87f-9bcph                   1/1     Running   0          25h
web           web-consumer-84fc79d94d-8bt5q              1/1     Running   0          69s
data          auth-db-864ff9854c-cl74r                   1/1     Running   0          69s
web           web-consumer-84fc79d94d-42xjk              1/1     Running   0          69s
```
Поды запущены... Логи:

```shell
$ microk8s kubectl logs -n web web-consumer-84fc79d94d-42xjk 
.......
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
```
Видим сообщение об ошибке: "curl: (6) Couldn't resolve host 'auth-db'"

curl пытается "достучаться" до auth-db в своем же неймспейсе, а у нас они в разных неймспейсах.

Смотрим деплоймент:

```shell
$ microk8s kubectl describe -n web deployments.apps web-consumer
Name:                   web-consumer
Namespace:              web
CreationTimestamp:      Wed, 12 Jul 2023 11:48:47 +0300
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=web-consumer
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=web-consumer
  Containers:
   busybox:
    Image:      radial/busyboxplus:curl
    Port:       <none>
    Host Port:  <none>
    Command:
      sh
      -c
      while true; do curl auth-db; sleep 5; done
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   web-consumer-84fc79d94d (2/2 replicas created)
Events:          <none>
```

Вот ошибка:

```shell
    Command:
      sh
      -c
      while true; do curl auth-db; sleep 5; done
```

###### 5) Необходимо внести изменения:

```shell
$ microk8s kubectl edit -n web deployments.apps web-consumer
```
Меняем
```
while true; do curl auth-db; sleep 5; done
```
на
```
while true; do curl auth-db.data; sleep 5; done
```
Редактирование успешно, изменения внесены:

```shell
deployment.apps/web-consumer edited
```

###### 6) Снова проверяем логи:

```shell
$ microk8s kubectl logs -n web web-consumer-5769f9f766-q9gj2
.........
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   206k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
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

Ошибки устранены.