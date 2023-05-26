### 13.1 Хранение в K8s. Часть 1

#### 1) Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными:

- ###### Создаем Deplayment.yml:

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
      - name: multitool
        image: wbitt/network-multitool
        volumeMounts: 
          - name: shara
            mountPath: /tmp/shara

      - name: busybox
        image: busybox
        volumeMounts:
          - name: shara
            mountPath: /tmp/shara
        command: ['sh', '-c', 'while true; do date +%X >> /tmp/shara/output.txt; sleep 5; done']
      
      volumes:
        - name: shara
          emptyDir: {}

```
- ###### Применяем:
```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/myapp created
```

- ##### Пробуем прочитать файл из контейнеров:
```shell
$ microk8s.kubectl exec myapp-57746d8b9b-fbtkw -c busybox -- tail -f /tmp/shara/output.txt
13:13:36
13:13:41
13:13:46
13:13:51
13:13:56
13:14:01
13:14:06
13:14:11
13:14:16
13:14:21
13:14:26
13:14:31
^C
```

```shell
$ microk8s.kubectl exec myapp-57746d8b9b-fbtkw -c multitool -- tail -f /tmp/shara/output.txt
13:14:01
13:14:06
13:14:11
13:14:16
13:14:21
13:14:26
13:14:31
13:14:36
13:14:41
13:14:46
13:14:51
^C
```

#### 2) Создать DaemonSet приложения, которое может прочитать логи ноды

- ###### Создаем daemonset (дополняем Deployment.yml):
```yaml
---

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: daemon
  labels:
    app: daemon
spec:
  selector:
    matchLabels:
      app: daemon
  template:
    metadata:
      labels:
        app: daemon
    spec:
      containers:
      - name: daemon-multi
        image: wbitt/network-multitool
        volumeMounts:
        - name: node-logs
          mountPath: /node-logs/syslog
          subPath: syslog
      volumes:
      - name: node-logs
        hostPath:
          path: /var/log/
```

- ###### Применяем:
```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/myapp unchanged
daemonset.apps/daemon created
```

- ###### Проверяем наличие файла:
```shell
$ microk8s.kubectl exec daemon-bx52k -- ls /node-logs/
syslog
```

- ###### Смотрим содержимое:
```shell
$ microk8s.kubectl exec daemon-bx52k -- tail -f /node-logs/syslog
May 26 16:30:39 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.72IkK9.mount: Deactivated successfully.
May 26 16:30:40 bubuntu systemd[1]: run-containerd-runc-k8s.io-e749f854311f1b63e9bd0a59882f763d710d75d92111a5f691b70c1f6e555bd5-runc.yG0l2Q.mount: Deactivated successfully.
May 26 16:30:41 bubuntu systemd[1]: run-containerd-runc-k8s.io-e749f854311f1b63e9bd0a59882f763d710d75d92111a5f691b70c1f6e555bd5-runc.BtKwmJ.mount: Deactivated successfully.
May 26 16:30:42 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.7JKXRM.mount: Deactivated successfully.
May 26 16:30:49 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.leO3Jl.mount: Deactivated successfully.
May 26 16:30:51 bubuntu systemd[1]: run-containerd-runc-k8s.io-e749f854311f1b63e9bd0a59882f763d710d75d92111a5f691b70c1f6e555bd5-runc.YPJDNJ.mount: Deactivated successfully.
May 26 16:30:52 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.HyNumK.mount: Deactivated successfully.
May 26 16:30:58 bubuntu systemd[1859518]: Started snap.microk8s.kubectl.72f8d160-e417-4c80-aea6-928e16291711.scope.
May 26 16:30:58 bubuntu systemd[1859518]: Started snap.microk8s.kubectl.f737543c-c2af-40b9-9c82-e0a0024d7764.scope.
May 26 16:31:00 bubuntu systemd[1859518]: Started snap.microk8s.kubectl.c1bff1f1-9e14-4155-8d25-c8c51e621475.scope.
May 26 16:31:01 bubuntu systemd[1]: run-containerd-runc-k8s.io-e749f854311f1b63e9bd0a59882f763d710d75d92111a5f691b70c1f6e555bd5-runc.toHHD5.mount: Deactivated successfully.
May 26 16:31:02 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.59N4yq.mount: Deactivated successfully.
May 26 16:31:09 bubuntu systemd[1]: run-containerd-runc-k8s.io-49d56ebe8d2a279b955844de5483686ba7d41f7d1d9e03c2b3843349b6f01da7-runc.vwHCkE.mount: Deactivated successfully.
May 26 16:31:10 bubuntu yandex-browser.desktop[1863548]: [1863541:1863567:0526/163110.609091:ERROR:passman_store_impl.cc(1283)] No encryptor.
^C
```