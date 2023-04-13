### 11.04. Микросервисы: масштабирование

``` 
Предложите решение для обеспечения развёртывания, запуска и управления приложениями. Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.
Решение должно соответствовать следующим требованиям:

- поддержка контейнеров;
- обеспечивать обнаружение сервисов и маршрутизацию запросов;
- обеспечивать возможность горизонтального масштабирования;
- обеспечивать возможность автоматического масштабирования;
- обеспечивать явное разделение ресурсов, доступных извне и внутри системы;
- обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с  возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т. п.
```

Использование Kubernetes позволяет обеспечить все запрошенные функции:

- контейнеризация;
- возможность маршрутизации kube-proxy + virtual ip для сервисов;
- горизонтальное масштабирование через реплики подов;
- масштабирование по нагрузке Pod Autoscaler;
- наличие пространств имен (namespaces) для разграничения сервисов и сетвых политик для распределиния доступов;
- использование secret, vault позволит обеспечить надежное хранение чувствительной информации