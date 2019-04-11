# prepcka
pasting some useful resources for cka


# tips for during the exam

## first thing
```
source <(kubectl completion bash)
```
## generating useful yaml files
These would avoid typing since apparently copying more than two lines is not possible

```
kubectl run dep --image=nginx -o yaml --dry-run # creates a deployment
kubectl expose deployment dep -o yaml --dry-run # creates a service
```
TODO: check expose options for the ports; check how "kubectl explain" works
