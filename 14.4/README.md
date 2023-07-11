### 14.4 Обновление приложений

```
Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор
Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
Запас по ресурсам в менее загруженный момент времени составляет 20%.
Обновление мажорное, новые версии приложения не умеют работать со старыми.
Вам нужно объяснить свой выбор стратегии обновления приложения.

Задание 2. Обновить приложение
Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
Откатиться после неудачного обновления.
```

##### 1) Задание 1
Можно предположить несколько вариантов (20% относительное понятие, в данном случае)


###### а)  Rolling Update - использовать параметризацию обновления maxsurge и maxunavailable (максимальное количество подов добавляемое в апдейт и недоступных, соответственно) - указать равным "1"; Также при прогнозируемом самом разгруженном периоде работы выполнить апдейт


###### б) Canary update - перевод пользователей приложения по частям


В случае неуспеха, возможно откатиться обратно

##### 2) Задание 2

Листинг:
```
k8s
   └── deployment.yml - !!! Содержит крайнюю версию 1.28, на момент последнего шага
```

###### Создаем deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
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
        image: nginx:1.19
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
###### Применяем:
```shell
$ microk8s kubectl apply -f ./k8s/
deployment.apps/myapp created
service/myapp created

$ microk8s kubectl get pods
NAME                     READY   STATUS              RESTARTS   AGE
myapp-7f4b548f84-n7sfg   0/2     ContainerCreating   0          16s
myapp-7f4b548f84-567mg   0/2     ContainerCreating   0          16s
myapp-7f4b548f84-2f85m   0/2     ContainerCreating   0          16s
myapp-7f4b548f84-2b427   0/2     ContainerCreating   0          16s
myapp-7f4b548f84-xvk9r   0/2     ContainerCreating   0          16s
```
```shell
$ microk8s kubectl describe deployments.apps myapp | grep Image
    Image:        nginx:1.19
    Image:      wbitt/network-multitool
```

###### Меняем версию nginx 1.20 и применяем:

```shell
$ microk8s kubectl apply -f ./k8s/
deployment.apps/myapp configured
service/myapp unchanged
```
```shell
$ microk8s kubectl rollout status deployment 
Waiting for deployment "myapp" rollout to finish: 2 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 2 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 2 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "myapp" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "myapp" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "myapp" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "myapp" rollout to finish: 4 of 5 updated replicas are available...
deployment "myapp" successfully rolled out
```

```shell
$ microk8s kubectl describe deployments.apps myapp | grep Image
    Image:        nginx:1.20
    Image:      wbitt/network-multitool
```


###### Пробуем обновиться до 1.28:

Что-то пошло не так:
```shell
$ microk8s kubectl get pods
NAME                     READY   STATUS             RESTARTS   AGE
myapp-5768cbc66d-ktwxv   2/2     Running            0          3m14s
myapp-5768cbc66d-v8s6p   2/2     Running            0          3m14s
myapp-5768cbc66d-5nt5t   2/2     Running            0          3m9s
myapp-5768cbc66d-bljcv   2/2     Running            0          3m7s
myapp-6657fb7568-tvbpk   1/2     ImagePullBackOff   0          57s
myapp-6657fb7568-rv6lf   1/2     ImagePullBackOff   0          57s
```
Приложение не "упало":
```shell
$ microk8s kubectl exec deployments/myapp -- curl myapp
Defaulted container "nginx" out of: nginx, multitool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   298k      0 --:--:-- --:--:-- --:--:--  298k<!DOCTYPE html>
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


###### Откатываемся:
```shell
$ microk8s kubectl rollout undo deployment myapp 
deployment.apps/myapp rolled back
``````

```shell
$ microk8s kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
myapp-5768cbc66d-ktwxv   2/2     Running   0          9m16s
myapp-5768cbc66d-v8s6p   2/2     Running   0          9m16s
myapp-5768cbc66d-5nt5t   2/2     Running   0          9m11s
myapp-5768cbc66d-bljcv   2/2     Running   0          9m9s
myapp-5768cbc66d-t6vvh   2/2     Running   0          76s
```

```shell
$ microk8s kubectl describe deployments.apps myapp | grep Image
    Image:        nginx:1.20
    Image:      wbitt/network-multitool
```