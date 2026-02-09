### configmap.yaml
[ ]

### deployment.yaml
1. Label selector does not match with label/s defined in the template
2. `imagePullSecrets` is not defined though it's mandatory when images from private container registry are used
3. `image` is set to a dummy value
4. the only port defined in `ports` points to wrong destination port
5. configmap `api-config` is not used
6. value for `DATABASE_URL` env var is hardcoded
7. value for `PORT` env var is incorrect

### service.yaml
1. label selector does not match with label/s set in deployment template
2. the only port defined in `ports` points to wrong destination port
3. using different listening and target ports for a service without a reason may cause confuses
4. LoadBalancer service is an overkill for the case, plus ingress resources is not needed to expose the app if `LoadBalancer` type is used

### ingress.yaml
1. service name reference does not match with the real service name
2. the only port defined in `ports` points to wrong destination port
3. `ingressClassName` definition or ingress class annotation is missing, e.g:
```yaml
...
  annotations:
    kubernetes.io/ingress.class: nginx
...
```

> [!NOTE]
> it's a common used best practice to isolate kubernetes resources in dedicated namespaces.  Run
>  ```bash
>  kubectl create ns devops-api
>  ```
>  or save the below definition to a `namespace.yaml` file
>  ```yaml
>  apiVersion: v1
>  kind: Namespace
>  metadata:
>    labels:
>      app: devops-api
>    name: devops-api
>  ```
>  and run
>  ```bash
>  kubectl apply -f namespace.yaml
>  ```
>  to add a namespace named `devops-api`.
>  Add the following line to metadata of all resources to place them in the newly created namespace:
>  ```yaml
>  ...
>  metadata:
>    name: <name>
>    namespace: devops-api
>  ...
>  ```
>  or use `-n` flag when executing `kubectl`:
>  ```bash
>  kubectl apply -f ./k8s/deployment.yaml -n devops-api
>  ```

> [!IMPORTANT]
> Changing `DATABASE_PASSWORD` and storing it at a safe/encrypted place is strongly recommended.  Kubernetes External Secrets Operator can be used as a consistent solution.
