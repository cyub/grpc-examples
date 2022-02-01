create-server-headless-service:
	kubectl apply -f headless-service/service.yml

create-client-headless-deployment:
	kubectl delete -n grpc-lb-example deployment grpc-lb-example-greeter-client-headless
	kubectl apply -f headless-service/deployment-client.yml

client-headless-log:
	 kubectl get pods -n grpc-lb-example | grep greeter-client-headless | awk  '{print $$1}' | xargs -I{} kubectl logs -f  {} -n  grpc-lb-example
