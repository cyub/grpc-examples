create-clusterrole:
	kubectl apply -f k8s-endpoint/clusterrole.yml

create-serviceaccount:
	kubectl apply -f k8s-endpoint/serviceaccount.yml

clusterrolebinding:
	kubectl apply -f k8s-endpoint/clusterrolebinding.yml

create-client-endpoint-deployment:
	kubectl apply -f k8s-endpoint/deployment-client.yml

client-endpoint-log:
	kubectl get pods -n grpc-lb-example | grep greeter-client-endpoint | awk  '{print $$1}' | xargs -I{} kubectl logs -f  {} -n  grpc-lb-example greeter-client-endpoint
