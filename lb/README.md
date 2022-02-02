# k8s 下 grpc 负载均衡

## 示例代码hellowlrd

来源：[grpc-go官方代码示例](https://github.com/grpc/grpc-go/tree/master/examples/helloworld)

## 准备

minikube安装过程略

```
make start-minikube # 启动minikube
make start-minikube-dashboard # 启动minikube-dashboard
eval `minikube -p minikube docker-env` # 设置docker环境
make build-server-image # 构建grpc server镜像
make build-client-image # 构建grpc client镜像
make create-server-deployment # 构建grpc server deployment，即创建grpc server pods
```

### clusterIP service模式

![](https://static.cyub.vip/images/202111/passthrough-service.png)

```
make create-server-service # 创建clusterIP service
make create-client-deployment # 创建grpc client部署，使用service name直连
make client-log # 查看日志
```

**注意：**

1. grpc client连接k8s service 时候，可直接使用k8s服务名称(grpc-lb-example-greeter-server-svc)，而不必在k8s服务名称后面再带上namespace(grpc-lb-example-greeter-server-svc.grpc-lb-example)
2. 通过日志可以看到即使grpc server有3个POD，k8s service也只会代理到其中一个

### headless servcie模式

![](https://static.cyub.vip/images/202111/k8s-headless-service.png)

```
make create-server-headless-service # 创建headless service
make create-client-headless-deployment # 创建grpc client部署，使用headless service name直连
make client-headless-log # 查看日志
```

**注意：**
1. grpc client连接k8s headless service时候，可以直接使用k8s headless服务名称(grpc-lb-example-greeter-server-headless-svc)，而不必在k8s服务名称后面再带上namespace(grpc-lb-example-greeter-server-headless-svc.grpc-lb-example)
2. DNS url中dns schema，由于后面省略了authority，所以一般都是三个反斜线`///`，标准格式为`dns:[//authority/]host[:port]`。
3. 测试发现当节点scale down后，grpc client能够立马感知，scale up之后需要过几秒才能够感知。

## k8s endpoints API 模式

![](https://static.cyub.vip/images/202111/k8s-endpoints-service.png)

## envoy proxy 模式

![](https://static.cyub.vip/images/202111/envoy-proxy.png)

```
make envoy-configmap # 创建envoy 配置文件的configmap
make create-server-headless-service # 创建grpc server headless service
make create-envoy-deployment # 创建envoy deployment
make create-envoy-service # 创建k8s service，代理到envoy pod
make create-client-envoy-deployment # 创建grpc client deployment，连到envoy service
make client-envoy-log # 查看grpc client日志
```

## 基于Etcd/consul 等外部服务注册中心模式

![](https://static.cyub.vip/images/202111/etcd-service.png)


## envoy proxy as sidecar 模式

![](https://static.cyub.vip/images/202111/envoy-proxy-as-sidecar.png)

```
make envoy-sidecar-configmap # 创建envoy 配置文件的configmap
make create-server-headless-service # 创建grpc server headless service
make create-client-envoy-sidecar-deployment # 启动grpc client + envoy deployment
make client-envoy-sidecar-log # 查看日志
```

## service mesh 模式

### 安装istio

使用[istioctl 安装](https://istio.io/latest/zh/docs/setup/install/istioctl/)，
从[Istio release](https://github.com/istio/istio/releases) page选择最新istioctl进行下载。接着执行下面命令安装：

```
istioctl install # 使用默认配置档进行安装，该配置档是最小要求，适合生产环境
```

如果只是测试，可以安装demo配置档，包含所有配置和示例：

```
istioctl install --set profile=demo # 使用demo配置档进行安装
istioctl profile list # 查看所有配置档
```

### 安装 Kiali

[Kiali](https://kiali.io/docs/installation/quick-start/)是service mesh管理、可视化的工具。从[Istio release](https://github.com/istio/istio/releases) page选择最新的istio进行下载，接下执行下面命令：

```
kubectl apply -f ${ISTIO_HOME}/samples/addons/kiali.yaml
```

Kiali依赖istio的[Prometheus Addon](https://istio.io/latest/zh/docs/tasks/observability/metrics/querying-metrics/)，默认配置档没有安装，可以执行下命令安装：

```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/prometheus.yaml
```

## 测试

```
make create-server-istio-deployment # 创建grpc server pods和 service
make create-client-istio-deployment # 创建grpc client pods
make client-istio-log # 查看日志
make run-kiali # 启动kiali代理
```

## 资料

- [你好，Minikube](https://kubernetes.io/zh/docs/tutorials/hello-minikube/)
- [Kubernetes 文档-概念-服务、负载均衡和联网-服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/#type-nodeport)
- [通过环境变量将 Pod 信息呈现给容器](https://kubernetes.io/zh/docs/tasks/inject-data-application/environment-variable-expose-pod-information/)
- [gRPC Name Resolution](https://github.com/grpc/grpc/blob/master/doc/naming.md)
- [gRPC service config](https://github.com/grpc/grpc/blob/master/doc/service_config.md)
- [gRPC Load Balancing on Kubernetes examples](https://github.com/jtattermusch/grpc-loadbalancing-kubernetes-examples)
- [使用 Envoy Proxy 对 GKE 上的 gRPC 服务进行负载平衡](https://cloud.google.com/architecture/exposing-grpc-services-on-gke-using-envoy-proxy)
- [Using Envoy for GRPC Applications in Kubernetes](https://www.hairizuan.com/using-envoy-for-grpc-applications-in-kubernetes/)