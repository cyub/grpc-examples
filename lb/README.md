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

## envoy proxy 模式

![](https://static.cyub.vip/images/202111/envoy-proxy.png)

```
make envoy-configmap # 创建envoy 配置文件的configmap
make create-envoy-deployment # 创建envoy deployment
make create-envoy-service # 创建k8s service，代理到envoy pod
make create-client-envoy-deployment # 创建grpc client deployment，连到envoy service
make client-envoy-log # 查看grpc client日志
```

## 资料

- [你好，Minikube](https://kubernetes.io/zh/docs/tutorials/hello-minikube/)
- [Kubernetes 文档-概念-服务、负载均衡和联网-服务](https://kubernetes.io/zh/docs/concepts/services-networking/service/#type-nodeport)
- [通过环境变量将 Pod 信息呈现给容器](https://kubernetes.io/zh/docs/tasks/inject-data-application/environment-variable-expose-pod-information/)
- [gRPC Name Resolution](https://github.com/grpc/grpc/blob/master/doc/naming.md)
- [gRPC service config](https://github.com/grpc/grpc/blob/master/doc/service_config.md)