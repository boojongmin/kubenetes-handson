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

kubectl get node -o wide
kubectl describe node minikube

kubectl run kubia --image=luksa/kubia  --generator=run/v1 --port=8080
kubectl get all
kubectl expose rc kubia --type=LoadBalancer --name kubia-http # rc == replicationcontroller
kubectl get services -o wide
kubectl get pods -o wide
kubectl scale rc kubia --replicas=3
kubectl get pods
kubectl get service
curl [ip]:8080   # curl $(minikube service kubia-http --url)
kubectl get rc -o wide

kubectl run nginx --image nginx --generator=run/v1 --port=80
kubectl get all
kubectl expose rc nginx --type=LoadBalancer --name nginx-http
curl [ip]
kubectl get pods
kubectl scale rc nginx --replicas=3
kubectl get pods
kubectl get rc

kubectl delete svc kubia-http
```

## descriptor 예제
```
kubectl get po kubia-[문자열] -o yaml
kubectl get rc kubia -o yaml   # kubectl edit rc kubia <- spec의 replicas 설정 변경후 kubectl get po
kubectl delete rc kubia

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
# yaml 설명을 console에서 보고 싶을때
kubectl explain pods
kubectl explain pods.spec

# yaml을 이용해서 쿠버네티스 활용. production에서 사용시 이 yaml은 형상관리 대상
cd yaml
cat kubia-manual.yaml
kubectl create -f kubia-manual.yaml
kubectl get all
kubectl get all -o yaml
kubectl logs -f kubia-manual

#(minikube 되야하는데 안됨.)kubectl port-forward kubia-manual 8888:8080
#(안됨)curl localhost:8888

cat kubia-manual-with-labels.yaml
kubectl create -f kubia-manual-with-labels.yaml
kubectl get po --show-labels
kubectl label po kubia-manual-v2 env=debug --overwrite
kubectl label po kubia-manual-v2 env=debug --overwrite
# select by label
kubectl get po -l env
kubectl get po -l '!env'

# 특정 노드에 라벨을 추가하여 해당 노드에만 포드가 생겨나는 예제(패스해도 됨)
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

cat kubia-liveness-probe.yaml
kubectl create -f kubia-liveness-probe.yaml 
kubectl get po
kubectl describe po kubia-liveness
# 확인
kubectl expose po kubia-liveness --selector app=kubia-liveness --port 8080
kubectl get all
curl 10.96.165.28:8080 -I 
# You've hit kubia-liveness 메세지 이후 I'm not well. Please restart me! 이 메세지 받으면 
# kubectl get po를 통해 restart 했는지 확인
kubectl delete all --all



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
cat kubia-rc.yaml 
kubectl create -f kubia-rc.yaml 
cat kubia-svc.yaml
kubectl create -f kubia-svc.yaml
kubectl get all
kubectl get svc
curl [ip]

cat kubia-svc-loadbalancer.yaml
kubectl create -f kubia-svc-loadbalancer.yaml
kubectl get svc # minikube는 external loadbalancer가 없어서 external-ip는 pending 상태 유지. 클라우드를 쓰면 ip가 할당됨.
```

#### ingress
```shell
minikube addons list
minikube addons enable ingress

kubectl create -f kubia-ingress.yaml  kubectl run curl --image=radial/busyboxplus:curl -i --tty
kubectl get ingresses
curl localhost:80
```

## deployement
```
cat kubia-rc-and-service-v1.yaml
kubectl create -f kubia-rc-and-service-v1.yaml
kubectl get svc kubia
while true; do curl http://10.98.204.67; done
(ctrl + c)
kubectl rolling-update kubia-v1 kubia-v2 --image=luksa/kubia:v2
# Command "rolling-update" is deprecated, use "rollout" instead
# Created kubia-v2
# Scaling up kubia-v2 from 0 to 3, scaling down kubia-v1 from 3 to 0 (keep 3 pods available, don't exceed 4 pods)
# Scaling kubia-v2 up to 1
# Scaling kubia-v1 down to 2
# Scaling kubia-v2 up to 2
# Scaling kubia-v1 down to 1
# Scaling kubia-v2 up to 3
# Scaling kubia-v1 down to 0
# Update succeeded. Deleting kubia-v1
# replicationcontroller/kubia-v2 rolling updated to "kubia-v2"

kubectl get all
kubectl describe rc kubia-v2
kubectl describe rc kubia-v1
kubectl get po --show-labels
(delete all하고  `kubectl rolling-update kubia-v1 kubia-v2 --image=luksa/kubia:v2 --v 6` 이 명령으로 rollingupdate 로그를 상세히 확인해서 보면 좋음.) 
kubectl delete rc,svc --all

```
```
cat kubia-deployement-v1.yaml
kubectl create -f kubia-deployement-v1.yaml --record
kubectl get all
kubectl rollout status deployment kubia

kubectl expose deployment kubia --port 8080
while true; do curl http://10.106.231.90:8080; done
(새로운 터미널 실행)
kubectl set image deployment kubia nodejs=luksa/kubia:v2
(ctrl + c)

while true; do curl http://10.106.231.90:8080; done
kubectl set image deployment kubia nodejs=luksa/kubia:v3 # <- 오류있는 이미지를 배포
kubectl rollout status deployment kubia
# Waiting for deployment "kubia" rollout to finish: 2 out of 3 new replicas have been updated...
# Waiting for deployment "kubia" rollout to finish: 2 out of 3 new replicas have been updated...
# Waiting for deployment "kubia" rollout to finish: 2 out of 3 new replicas have been updated...
# Waiting for deployment "kubia" rollout to finish: 1 old replicas are pending termination...
# Waiting for deployment "kubia" rollout to finish: 1 old replicas are pending termination...
# deployment "kubia" successfully rolled out

kubectl rollout undo deployment kubia 

kubectl rollout history deployment kubia
kubectl rollout undo deployment kubia --to-revision=1

cat kubia-deployment-v3-with-readinesscheck.yaml
# apply 사용!!
kubectl apply -f kubia-deployment-v3-with-readinesscheck.yaml # v3 이미지는 동작 안하는 이미지임.
kubectl rollout status deployment kubia

####
while true; do curl http://10.106.231.90:8080; done   # <- curl 걸어놓고
kubectl set image deployment kubia nodejs=luksa/kubia:v2 # <- 동작하는 이미지로 이미지 바꾸고
kubectl set image deployment kubia nodejs=luksa/kubia:v3 # <- 동작 안하는 이미지로 바꿔보면 정확히 어떤 설정인지 모르지만(아마도 readinessProbe?) 배포 실패 때문에 자동으로 이전 버전으로 롤백하는 것을 볼 수 있다.


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


## 자체 dns 확인
```
 kubectl run curl --image=radial/busyboxplus:curl -i --tty
 nslookup mysql
```
