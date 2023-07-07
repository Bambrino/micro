### 14.2 Установка Kubernetes


Для выполнения задания использовался terraform и kuberspray

Файлы приложены:
```
files
├── kuberspray (дир-я куда клонируем keberspray, не включал в репозиторий)
└── terraform
    ├── ansible.tf (запуск kuberspray)
    ├── inventory.tf (создание инвентори для kuberspray)
    ├── master01.tf (мастер нода)
    ├── net.tf (создание сети в YC)
    ├── provider.tf (описание провайдера)
    ├── vars.tf (используемые переменные)
    ├── worker01.tf (воркер нода1)
    ├── worker02.tf (воркер нода2)
    ├── worker03.tf (воркер нода3)
    └── worker04.tf (воркер нода4)

```


---

###### 1)  Клонируем keberspray на локальную машину:

```shell
$ git clone https://github.com/kubernetes-sigs/kubespray ./kuberspray
Клонирование в «./kuberspray»...
remote: Enumerating objects: 69707, done.
remote: Counting objects: 100% (505/505), done.
remote: Compressing objects: 100% (407/407), done.
remote: Total 69707 (delta 53), reused 343 (delta 38), pack-reused 69202
Получение объектов: 100% (69707/69707), 21.85 МиБ | 5.86 МиБ/с, готово.
Определение изменений: 100% (39062/39062), готово.
```
###### 2)  Устанавливаем зависимости:

```shell
vvk@bubuntu:~/dz/micro/14.2/files$ cd kuberspray/
vvk@bubuntu:~/dz/micro/14.2/files/kuberspray$ pip3 install -r requirements.txt 
Defaulting to user installation because normal site-packages is not writeable
Collecting ansible==7.6.0
  Downloading ansible-7.6.0-py3-none-any.whl (43.8 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 43.8/43.8 MB 4.6 MB/s eta 0:00:00
Collecting ansible-core==2.14.6
  Downloading ansible_core-2.14.6-py3-none-any.whl (2.2 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.2/2.2 MB 6.2 MB/s eta 0:00:00
Collecting cryptography==41.0.1
  Downloading cryptography-41.0.1-cp37-abi3-manylinux_2_28_x86_64.whl (4.3 MB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 4.3/4.3 MB 6.1 MB/s eta 0:00:00
Requirement already satisfied: jinja2==3.1.2 in /home/vvk/.local/lib/python3.10/site-packages (from -r requirements.txt (line 4)) (3.1.2)
Collecting jmespath==1.0.1
  Downloading jmespath-1.0.1-py3-none-any.whl (20 kB)
Collecting MarkupSafe==2.1.3
  Downloading MarkupSafe-2.1.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (25 kB)
Requirement already satisfied: netaddr==0.8.0 in /usr/lib/python3/dist-packages (from -r requirements.txt (line 7)) (0.8.0)
Collecting pbr==5.11.1
  Downloading pbr-5.11.1-py2.py3-none-any.whl (112 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 112.7/112.7 KB 9.3 MB/s eta 0:00:00
Collecting ruamel.yaml==0.17.31
  Downloading ruamel.yaml-0.17.31-py3-none-any.whl (112 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 112.1/112.1 KB 8.1 MB/s eta 0:00:00
Collecting ruamel.yaml.clib==0.2.7
  Downloading ruamel.yaml.clib-0.2.7-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux_2_24_x86_64.whl (485 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 485.6/485.6 KB 6.9 MB/s eta 0:00:00
Requirement already satisfied: packaging in /home/vvk/.local/lib/python3.10/site-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (21.3)
Requirement already satisfied: PyYAML>=5.1 in /usr/lib/python3/dist-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (5.4.1)
Requirement already satisfied: resolvelib<0.9.0,>=0.5.3 in /usr/local/lib/python3.10/dist-packages (from ansible-core==2.14.6->-r requirements.txt (line 2)) (0.8.1)
Requirement already satisfied: cffi>=1.12 in /usr/local/lib/python3.10/dist-packages (from cryptography==41.0.1->-r requirements.txt (line 3)) (1.15.1)
Requirement already satisfied: pycparser in /usr/local/lib/python3.10/dist-packages (from cffi>=1.12->cryptography==41.0.1->-r requirements.txt (line 3)) (2.21)
Requirement already satisfied: pyparsing!=3.0.5,>=2.0.2 in /usr/lib/python3/dist-packages (from packaging->ansible-core==2.14.6->-r requirements.txt (line 2)) (2.4.7)
Installing collected packages: ruamel.yaml.clib, pbr, MarkupSafe, jmespath, ruamel.yaml, cryptography, ansible-core, ansible
  Attempting uninstall: MarkupSafe
    Found existing installation: MarkupSafe 2.1.1
    Uninstalling MarkupSafe-2.1.1:
      Successfully uninstalled MarkupSafe-2.1.1
Successfully installed MarkupSafe-2.1.3 ansible-7.6.0 ansible-core-2.14.6 cryptography-41.0.1 jmespath-1.0.1 pbr-5.11.1 ruamel.yaml-0.17.31 ruamel.yaml.clib-0.2.7
```

###### 3)  Копируем инвентори из примера (учитываем название использованное в terraform)

```shell
$ cp -rfp inventory/sample inventory/mykubecl
```

###### 4)  Запускаем terraform apply (ниже только хвост "портянки"):

```shell
null_resource.cluster (local-exec): PLAY RECAP *********************************************************************
null_resource.cluster (local-exec): localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.cluster (local-exec): master01                   : ok=767  changed=146  unreachable=0    failed=0    skipped=1292 rescued=0    ignored=8   
null_resource.cluster (local-exec): worker01                   : ok=540  changed=91   unreachable=0    failed=0    skipped=801  rescued=0    ignored=1   
null_resource.cluster (local-exec): worker02                   : ok=540  changed=91   unreachable=0    failed=0    skipped=800  rescued=0    ignored=1   
null_resource.cluster (local-exec): worker03                   : ok=540  changed=91   unreachable=0    failed=0    skipped=800  rescued=0    ignored=1   
null_resource.cluster (local-exec): worker04                   : ok=540  changed=91   unreachable=0    failed=0    skipped=800  rescued=0    ignored=1   

null_resource.cluster (local-exec): Пятница 07 июля 2023  12:40:34 +0300 (0:00:00.537)       0:29:00.594 **********
null_resource.cluster (local-exec): ===============================================================================
null_resource.cluster (local-exec): download : download_container | Download image if required ------------ 223.52s
null_resource.cluster (local-exec): download : download_container | Download image if required ------------- 53.52s
null_resource.cluster (local-exec): kubernetes/preinstall : Install packages requirements ------------------ 43.19s
null_resource.cluster (local-exec): network_plugin/calico : Wait for calico kubeconfig to be created ------- 41.75s
null_resource.cluster (local-exec): kubernetes/kubeadm : Join to cluster ----------------------------------- 27.60s
null_resource.cluster (local-exec): bootstrap-os : Install dbus for the hostname module -------------------- 27.03s
null_resource.cluster (local-exec): download : download_container | Download image if required ------------- 20.90s
null_resource.cluster (local-exec): container-engine/containerd : download_file | Download item ------------ 20.75s
null_resource.cluster (local-exec): container-engine/crictl : download_file | Download item ---------------- 20.13s
null_resource.cluster (local-exec): container-engine/runc : download_file | Download item ------------------ 20.10s
null_resource.cluster (local-exec): container-engine/nerdctl : download_file | Download item --------------- 20.04s
null_resource.cluster (local-exec): kubernetes/control-plane : kubeadm | Initialize first master ----------- 19.22s
null_resource.cluster (local-exec): download : download_container | Download image if required ------------- 18.21s
null_resource.cluster (local-exec): container-engine/crictl : extract_file | Unpacking archive ------------- 16.30s
null_resource.cluster (local-exec): download : download_file | Download item ------------------------------- 16.05s
null_resource.cluster (local-exec): container-engine/nerdctl : extract_file | Unpacking archive ------------ 15.80s
null_resource.cluster (local-exec): container-engine/nerdctl : download_file | Validate mirrors ------------ 13.68s
null_resource.cluster (local-exec): container-engine/runc : download_file | Validate mirrors --------------- 13.18s
null_resource.cluster (local-exec): container-engine/containerd : download_file | Validate mirrors --------- 13.10s
null_resource.cluster (local-exec): container-engine/crictl : download_file | Validate mirrors ------------- 13.01s
null_resource.cluster: Creation complete after 29m5s [id=5850595790008706940]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
```

###### 5)  Идем на наш мастер и смотрим, что получилось:


```shell
$ ssh ubuntu@158.160.75.241
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-153-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
New release '22.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Fri Jul  7 09:12:23 2023 from 84.52.77.66
```
###### 5.1)  Копируем конфиг в домашнюю папку пользователя:

```shell
$ mkdir .kube
ubuntu@master01:~$ sudo cat /etc/kubernetes/admin.conf >> /home/ubuntu/.kube/config
```
###### 5.2)  Смотрим ноды:
```shell
$ kubectl get nodes -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master01   Ready    control-plane   20m   v1.26.6   192.168.101.10   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.2
worker01   Ready    <none>          18m   v1.26.6   192.168.101.20   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.2
worker02   Ready    <none>          18m   v1.26.6   192.168.101.21   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.2
worker03   Ready    <none>          18m   v1.26.6   192.168.101.22   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.2
worker04   Ready    <none>          18m   v1.26.6   192.168.101.23   <none>        Ubuntu 20.04.6 LTS   5.4.0-153-generic   containerd://1.7.2

```
