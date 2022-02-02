.PHONY: protoc build-server build-client tidy clean build-server-image start-minikube start-minikube-dashboard

GREETER_SERVER_BIN = greeter_server
GREETER_CLIENT_BIN = greeter_client
GREETER_SERVER_DIR = $(PWD)/helloworld/server
GREETER_CLIENT_DIR = $(PWD)/helloworld/client
MINIKUBE_ENV = `minikube -p minikube docker-env`
GO=go

protoc:
	protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    helloworld/proto/*.proto

tidy:
	$(GO) mod tidy

build-server:
	$(GO) build -v -o $(GREETER_SERVER_DIR)/$(GREETER_SERVER_BIN) $(GREETER_SERVER_DIR)

build-server-image:
	docker build -f $(GREETER_SERVER_DIR)/Dockerfile -t greeter_server:1.0 .

build-client:
	$(GO) build -v -o $(GREETER_CLIENT_DIR)/$(GREETER_CLIENT_BIN) $(GREETER_CLIENT_DIR)

build-client-image:
	docker build -f $(GREETER_CLIENT_DIR)/Dockerfile -t greeter_client:1.0 .

clean:
	rm -rf $(GREETER_SERVER_DIR)/$(GREETER_SERVER_BIN) $(GREETER_CLIENT_DIR)/$(GREETER_CLIENT_BIN)

start-minikube:
	minikube start

minikube-env:
	eval `minikube -p minikube docker-env`

start-minikube-dashboard:
	minikube dashboard &
	kubectl proxy --address='0.0.0.0' --disable-filter=true &

create-k8s-namespace:
	kubectl apply -f service/namespace.yml

create-server-deployment:
	kubectl apply -f service/deployment-server.yml

include clusterip.mk headless-service.mk envoy-proxy.mk envoy-proxy-sidecar.mk service-mesh.mk
