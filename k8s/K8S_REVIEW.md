### configmap.yaml



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
1. align service name with reference in `ingress.yaml`
2. the only port defined in `ports` points to wrong destination port
