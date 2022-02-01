create-server-service:
	kubectl apply -f service/service.yml

create-client-deployment:
	kubectl apply -f service/deployment-client.yml

client-log:
	 kubectl get pods -n grpc-lb-example | grep greeter-client | awk  '{print $$1}' | xargs -I{} kubectl logs -f  {} -n  grpc-lb-example
