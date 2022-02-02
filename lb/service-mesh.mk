create-server-istio-deployment:
	istioctl kube-inject -f service-mesh/deployment-service-server.yml | kubectl apply -f -

create-client-istio-deployment:
	istioctl kube-inject -f service-mesh/deployment-client.yml | kubectl apply -f -

client-istio-log:
	kubectl get pods -n grpc-lb-example | grep greeter-client-istio | awk  '{print $$1}' | xargs -I{} kubectl logs -f  {} -n  grpc-lb-example greeter-client

run-kiali:
	kubectl port-forward svc/kiali 20001:20001 -n istio-system --address='0.0.0.0'