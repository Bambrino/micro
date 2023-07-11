### 14.3 Как работает сеть в K8s


```
Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа
Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
В качестве образа использовать network-multitool.
Разместить поды в namespace App.
Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
Продемонстрировать, что трафик разрешён и запрещён.
```

Листинг ДЗ:
```
 k8s
 ├── 00_namespace.yml   Манифест неймспейса
 ├── 01_backend.yml     Манифест бекэнда
 ├── 02_cache.yml       Манифест кэша
 ├── 03_frontend.yml    Манифест фронта
 ├── 99_netpolicy.yml   Манифест политик
 └── curl.sh            Скрипт для проверки
```

###### 1) Создаем deployments:

```
├── 00_namespace.yml
├── 01_backend.yml
├── 02_cache.yml
└── 03_frontend.yml
```

###### 2) Применяем и проверяем доступность:

```shell
$ microk8s kubectl apply -f ./
namespace/app created
deployment.apps/backend created
service/backend created
deployment.apps/cache created
service/cache created
deployment.apps/frontend created
service/frontend created
```

```shell
$ ./curl.sh 
 check access frontend2backend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - backend-6c666c55f-ccf7m - 10.1.35.138 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   139  100   139    0     0  54022      0 --:--:-- --:--:-- --:--:-- 69500
 check access frontend2cache 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0WBITT Network MultiTool (with NGINX) - cache-5cf54749b5-vg4fd - 10.1.35.139 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   138  100   138    0     0  65371      0 --:--:-- --:--:-- --:--:--  134k

  check access back2frontend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   141  100   141    0     0  50375      0 --:--:-- --:--:-- --:--:-- 70500
WBITT Network MultiTool (with NGINX) - frontend-5747bd89c5-shjv2 - 10.1.35.140 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

  check access back2cache 
WBITT Network MultiTool (with NGINX) - cache-5cf54749b5-vg4fd - 10.1.35.139 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0  50922      0 --:--:-- --:--:-- --:--:-- 69000

  check access cache2frontend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   141  100   141    0     0  83928      0 --:--:-- --:--:-- --:--:--  137k
WBITT Network MultiTool (with NGINX) - frontend-5747bd89c5-shjv2 - 10.1.35.140 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

  check access cache2backend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   139  100   139    0     0  45276      0 --:--:-- --:--:-- --:--:-- 69500
WBITT Network MultiTool (with NGINX) - backend-6c666c55f-ccf7m - 10.1.35.138 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```
###### 3) Добавляем сетевые политики и снова проверяем:

```shell
$ microk8s kubectl apply -f ./
namespace/app unchanged
deployment.apps/backend unchanged
service/backend unchanged
deployment.apps/cache unchanged
service/cache unchanged
deployment.apps/frontend unchanged
service/frontend unchanged
networkpolicy.networking.k8s.io/all-deny created
networkpolicy.networking.k8s.io/front2back created
networkpolicy.networking.k8s.io/back2cache created
```

```shell
$ ./curl.sh 
 check access frontend2backend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   139  100   139    0     0  90435      0 --:--:-- --:--:-- --:--:--  135k
WBITT Network MultiTool (with NGINX) - backend-6c666c55f-ccf7m - 10.1.35.138 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
 check access frontend2cache 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 28

  check access back2frontend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Connection timed out after 5001 milliseconds
command terminated with exit code 28

  check access back2cache 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0  56977      0 --:--:-- --:--:-- --:--:-- 69000
WBITT Network MultiTool (with NGINX) - cache-5cf54749b5-vg4fd - 10.1.35.139 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

  check access cache2frontend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Connection timed out after 5000 milliseconds
command terminated with exit code 28

  check access cache2backend 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0
curl: (28) Connection timed out after 5000 milliseconds
command terminated with exit code 28
```