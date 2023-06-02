### 13.2 Хранение в K8s. Часть 2

#### 1) Создать Deployment приложения, использующего локальный PV, созданный вручную

- ###### Создаем Deplayment.yml с двумя контейнерами, pv и pvc:

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
          - name: pv-local
            mountPath: /tmp/pv-local

      - name: busybox
        image: busybox
        volumeMounts:
          - name: pv-local
            mountPath: /tmp/pv-local
        command: ['sh', '-c', 'while true; do date +%X >> /tmp/pv-local/output.txt; sleep 5; done']
      
      volumes:
        - name: pv-local
          persistentVolumeClaim:
            claimName: pvc01

---

apiVersion: v1
kind: PersistentVolume
metadata:
  name: mypv
  labels:
    type: local
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/mypv"

---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc01
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```
- ###### Смотрим, что получилось:

```shell
$ microk8s.kubectl apply -f ./Deployment.yml 
deployment.apps/myapp created
persistentvolume/mypv created
persistentvolumeclaim/pvc01 created
```

```shell
$ microk8s.kubectl get pods,pv,pvc
NAME                         READY   STATUS    RESTARTS   AGE
pod/myapp-644d684867-qbrrm   2/2     Running   0          54s

NAME                    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM           STORAGECLASS   REASON   AGE
persistentvolume/mypv   1Gi        RWO            Retain           Bound    default/pvc01                           54s

NAME                          STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc01   Bound    mypv     1Gi        RWO                           54s
```

- ###### Посмотрим доступен ли наш файл обоим контейнерам (должно быть: один пишет, второй видит):

```shell
$ microk8s.kubectl exec myapp-644d684867-qbrrm -c multitool -- tail -f /tmp/pv-local/output.txt
08:15:04
08:15:09
08:15:14
08:15:19
08:15:24
08:15:29
08:15:34
08:15:39
08:15:44
08:15:49
08:15:54
^C
```

- ###### А что с файлом на локальной системе:
```shell
$ ls /tmp/mypv/ 
output.txt
$ cat /tmp/mypv/output.txt 
08:13:44
08:13:49
08:13:54
08:13:59
08:14:04
08:14:09
08:14:14
08:14:19
08:14:24
08:14:29
08:14:34
08:14:39
08:14:44
08:14:49
08:14:54
08:14:59
08:15:04
08:15:09
08:15:14
08:15:19
08:15:24
08:15:29
08:15:34
08:15:39
08:15:44
08:15:49
08:15:54
08:15:59
08:16:04
08:16:09
```

- ###### Удаляем deployment и pvc:

```shell
$ microk8s.kubectl delete deployment myapp
deployment.apps "myapp" deleted
$ microk8s.kubectl delete pvc pvc01
persistentvolumeclaim "pvc01" deleted
```
```shell
$ microk8s.kubectl get pods,pv,pvc
NAME                    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM           STORAGECLASS   REASON   AGE
persistentvolume/mypv   1Gi        RWO            Retain           Released   default/pvc01                           3m36s
```

- ###### Смотрим файл на системе (он останется, так как он не "внутри" пода):

```shell
$ ls /tmp/mypv/ 
output.txt
$ cat /tmp/mypv/output.txt 
08:13:44
08:13:49
08:13:54
08:13:59
08:14:04
08:14:09
08:14:14
08:14:19
08:14:24
08:14:29
08:14:34
08:14:39
08:14:44
08:14:49
08:14:54
08:14:59
08:15:04
08:15:09
08:15:14
08:15:19
08:15:24
08:15:29
08:15:34
08:15:39
08:15:44
08:15:49
08:15:54
08:15:59
08:16:04
08:16:09
08:16:14
08:16:19
08:16:24
08:16:29
08:16:34
08:16:39
08:16:44
08:16:49
08:16:54
08:16:59
08:17:04
```

- ###### Удалеям сам PV, проверяем что с файлом (он также останется, даже если указать policy delete - эта политика удалит только в облачных сервисах, а у нас не тот случай):

```shell
$ microk8s.kubectl delete pv mypv
persistentvolume "mypv" deleted
vvk@bubuntu:~/dz/micro/13.2$ microk8s.kubectl get pods,pv,pvc
No resources found
```
```shell
$ ls /tmp/mypv/ 
output.txt
$ cat /tmp/mypv/output.txt 
08:13:44
08:13:49
08:13:54
08:13:59
08:14:04
08:14:09
08:14:14
08:14:19
08:14:24
08:14:29
08:14:34
08:14:39
08:14:44
08:14:49
08:14:54
08:14:59
08:15:04
08:15:09
08:15:14
08:15:19
08:15:24
08:15:29
08:15:34
08:15:39
08:15:44
08:15:49
08:15:54
08:15:59
08:16:04
08:16:09
08:16:14
08:16:19
08:16:24
08:16:29
08:16:34
08:16:39
08:16:44
08:16:49
08:16:54
08:16:59
08:17:04
```


#### 2) Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV

- ###### Установка nfs сервера:

```shell
$ sudo apt install nfs-kernel-server
....
Creating config file /etc/exports with new version

Creating config file /etc/default/nfs-kernel-server with new version
Обрабатываются триггеры для man-db (2.10.2-1) …
Обрабатываются триггеры для libc-bin (2.35-0ubuntu3.1) …
```
```shell
$ mkdir /srv/nfs
$ sudo chown nobody:nogroup /srv/nfs
$ sudo chmod 777 /srv/nfs
```

```shell
$ echo "/srv/nfs *(rw,sync,no_subtree_check)" | sudo tee /etc/exports 
/srv/nfs *(rw,sync,no_subtree_check)
$ sudo systemctl restart nfs-kernel-server
```
- ###### Настройка nfs драйвера:

```shell
$ microk8s enable helm3
Infer repository core for addon helm3
Addon core/helm3 is already enabled

$ microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
"csi-driver-nfs" has been added to your repositories

$ microk8s helm3 repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "csi-driver-nfs" chart repository
Update Complete. ⎈Happy Helming!⎈
```

```shell
$ microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet
NAME: csi-driver-nfs
LAST DEPLOYED: Thu Jun  1 12:13:52 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The CSI NFS Driver is getting deployed to your cluster.

To check CSI NFS Driver pods status, please run:

  kubectl --namespace=kube-system get pods --selector="app.kubernetes.io/instance=csi-driver-nfs" --watch
```
```shell
  $ microk8s.kubectl wait pod --selector app.kubernetes.io/name=csi-driver-nfs --for condition=ready --namespace kube-system
pod/csi-nfs-node-hbkv2 condition met
pod/csi-nfs-controller-8599647cb4-qdmrl condition met
```

- ###### Пробуем применить deployment со storageclass и pvc:

```shell
microk8s.kubectl apply -f ./Deploymet2.yml 
deployment.apps/myapp created
storageclass.storage.k8s.io/mynfsclass created
persistentvolumeclaim/nfsclaim created
```
```shell
microk8s.kubectl get pods,sc,pvc
NAME                        READY   STATUS    RESTARTS   AGE
pod/myapp-6f7fd5fdb-5hkhm   1/1     Running   0          51s

NAME                                     PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
storageclass.storage.k8s.io/mynfsclass   nfs.csi.k8s.io   Delete          Immediate           false                  51s

NAME                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/nfsclaim   Bound    pvc-4a80028b-fc53-4e2a-82cc-ae62078eb440   1Gi        RWO            mynfsclass     51s
```

- ###### Проверим запись и доступность с nfs:
```shell
$ microk8s.kubectl exec -ti myapp-6f7fd5fdb-5hkhm -- sh
# cd /srv/nfs/
/srv/nfs # ls
/srv/nfs # touch 1
/srv/nfs # touch 2
/srv/nfs # ls
1  2
/srv/nfs # exit
```
```shell
$ ls /srv/nfs/pvc-4a80028b-fc53-4e2a-82cc-ae62078eb440/
1  2
```
