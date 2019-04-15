[kubernetes in action github](https://github.com/luksa/kubernetes-in-action)

```
sudo su -
minikube start
minikube status
kubectl cluster-info
kubectl proxy --port=8080
(ctrl + c)
inikube addons list # https://github.com/kubernetes/minikube/blob/master/docs/addons.md
minikube dashboard
# http://127.0.0.1:36065/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

kubectl get node
kubectl describe node minikube

kubectl run kubia --image=luksa/kubia  --generator=run/v1 --port=8080
kubectl get all
kubectl expose rc kubia --type=LoadBalancer --name kubia-http
kubectl get services
kubectl get pods
kubectl scale rc kubia --replicas=3
curl [ip]:8080
kubectl get pods
kubectl get rc

kubectl run nginx --image nginx --generator=run/v1 --port=80
kubectl get all
kubectl expose rc nginx --type=LoadBalancer --name nginx-http
kubectl get pods
kubectl scale rc nginx --replicas=3
kubectl get pods
kubectl get rc

kubectl delete rc kubia
kubectl delete svc kubia-http
```

## descriptor 예제
```
kubectl get po kubia -o yaml
kubectl get rc kubia -o yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubia-manual
spec:
  containers:
  - image: luksa/kubia
    name: kubia
    ports:
    - containerPort: 8080
      protocol: TCP
```

```
kubectl explain pods
kubectl explain pods.spec

cd yaml
kubectl create -f kubia-manual.yaml
kubectl get all
kubectl get all -o yaml
kubectl logs kubia-manual

#(minikube 되야하는데 안됨.)kubectl port-forward kubia-manual 8888:8080
#(안됨)curl localhost:8888

kubectl create -f kubia-manual-with-labels.yaml
kubectl get po --show-labels
kubectl label po kubia-manual-v2 env=debug --overwrite
kubectl get po -l env
kubectl get po -l '!env'

kubectl label node minikube gpu=true
kubectl get nodes -l gpu=true
kubectl create -f kubia-gpu.yaml 
kubectl get all

kubectl get ns
kubectl create -f custom-namespace.yaml 
kubectl create -f kubia-manual.yaml -n custom-namespace 
kubectl delete po kubia-gpu
kubectl delete po -l create_method=manual
delete po -l creation_method=manual
kubectl delete ns custom-namespace #포드는 네임스페이스가 삭제되면 자동 삭제
kubectl delete po --all
kubectl delete all --all
```

## replicatoin and controller
```
kubectl get po
kubectl create -f liveness-probe.yaml
kubectl get po
kubectl describe po liveness-http 

kubectl create -f kubia-rc.yaml 
kubectl get all 
kubectl delete pod -l app=kubia
kubectl get pod -l app=kubia
kubectl describe rc kubia

kubectl label pod -l app=kubia app=kubia2 --overwrite
kubectl get pods --show-labels

kubectl edit rc kubia #replicas=1
kubectl get pods -l app=kubia
kubectl edit rc kubia #replicas=8
kubectl get pods -l app=kubia
kubectl delete rc kubia
kubectl delete all --all
```

## service
```
kubectl create -f kubia-rc.yaml 
kubectl create -f kubia-svc.yaml
kubectl get svc
curl [ip]

kubectl create -f kubia-svc-loadbalancer.yaml
kubectl get svc # minikube는 external loadbalancer가 없어서 pending. 클라우드를 쓰면 ip가 할당됨.
```

#### ingress
```shell
minikube addons list
minikube addons enable ingress

kubectl create -f kubia-ingress.yaml 
kubectl get ingresses
curl localhost
```



## 아래는 준비중...
## namespace 예제(이건 빠짐....)
```
kubectl get all --all-namespaces
kubectl create namespace demo

kubectl get all --namespace=demo
kubectl run nginx --image nginx --generator=run-pod/v1 --namespace demo
kubectl run nginx --image nginx --generator=run-pod/v1 --namespace demo --port=80
kubectl delete rc nginx -n=demo 
kubectl exec -it nginx -n demo /bin/bash

kubectl port-forward pods/nginx 8080:80

kubectl run nginx --image nginx -namespace demo
kubectl get all -n demo
kubectl delete deployment nginx -n demo


docker run -d -p 5000:5000 --restart=always --name registry registry:2
demo-server/deploy.sh
http://localhost:5000/v2/demo-server/tags/list
```
