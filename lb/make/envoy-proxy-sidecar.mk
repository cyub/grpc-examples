envoy-sidecar-configmap:
	-kubectl delete -n grpc-lb-example configmap envoy-sidecar-config
	kubectl apply -f envoy-proxy-sidecar/envoy-sidecar-configmap.yml

create-client-envoy-sidecar-deployment:
	kubectl apply -f envoy-proxy-sidecar/deployment-client.yml

client-envoy-sidecar-log:
	 kubectl get pods -n grpc-lb-example | grep greeter-client-envoy-sidecar | awk  '{print $$1}' | xargs -I{} kubectl logs -f  {} -n  grpc-lb-example greeter-client-envoy-sidecar
