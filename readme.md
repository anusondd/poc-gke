# Provision VPC 
```
cd vpc
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

# Provision GKE
``` 
cd gke
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

# Get GKE Credentails
```
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials [cluster_name] --region asia-southeast1 --project [project_name]
```

# Install nginx-ingress-controller
```
kubectl create namespace foundation

helm repo add bitnami https://charts.bitnami.com/bitnami --force-update
helm search repo bitnami
helm install nginx-ingress-controller bitnami/nginx-ingress-controller -n foundation
helm delete nginx-ingress-controller -n foundation
```

# Install cert-manager
```
helm repo add jetstack https://charts.jetstack.io --force-update
helm search repo jetstack
helm install cert-manager jetstack/cert-manager --create-namespace --version v1.15.1 --set crds.enabled=true -n foundation
helm delete cert-manager -n foundation
```

# Install argo-cd
```
kubectl create namespace devsecops

cd ~/workspace/
mkdir -p argo-cd & cd argo-cd 
helm repo add argo https://argoproj.github.io/argo-helm
helm search repo argo
helm show values argo/argo-cd > values.yaml

helm install --values values.yaml argocd argo/argo-cd -n devsecops
helm upgrade --values values.yaml argocd argo/argo-cd -n devsecops
helm delete argocd -n devsecops
```

# Install harbor
```
cd ~/workspace/
mkdir -p harbor & cd harbor 
helm repo add harbor https://helm.goharbor.io
helm search repo harbor
helm show values harbor/harbor > values.yaml

helm install --values values.yaml harbor harbor/harbor -n devsecops
helm upgrade --values values.yaml harbor harbor/harbor -n devsecops
helm delete harbor -n devsecops
```

# Install jenkins
```
cd ~/workspace/
mkdir -p jenkins & cd jenkins
helm show values bitnami/jenkins > values.yaml

helm install --values values.yaml jenkins bitnami/jenkins -n devsecops
helm upgrade --values values.yaml jenkins bitnami/jenkins -n devsecops
helm delete jenkins -n devsecops
```

# Install sonarqube 
```
cd ~/workspace/
mkdir -p sonarqube & cd sonarqube
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

helm show values sonarqube/sonarqube > values.yaml
helm install --values values.yaml sonarqube sonarqube/sonarqube -n devsecops
helm upgrade --values values.yaml sonarqube sonarqube/sonarqube -n devsecops
helm delete sonarqube -n devsecops
```

# Install gitlab 
```
cd ~/workspace/
mkdir -p gitlab & cd gitlab
helm repo add gitlab helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm show values gitlab/gitlab > values.yaml
helm install --values values.yaml gitlab gitlab/gitlab -n devsecops
helm upgrade --values values.yaml gitlab gitlab/gitlab -n devsecops
helm delete gitlab -n devsecops
```

# Task:

1. Create a Dockerfile for a given application
Expected Output: Dockerfile
``` Answer : In Dockerfile ```

2. Build the image using the Dockerfile and push to Docker Hub
Expected Output: Build and push command and Docker Hub url
``` Answer : In build-go-12.Jenkinsfile, deployment-chart.Jenkinsfile, deployment-workflow.Jenkinsfile ```

3. Create a Kustomize manifest to deploy the image from the previous step. The Kustomize should have flexibility to allow Developer to adjust values without having to rebuild the Kustomize frequently
Expected Output: Kustomize manifest file to deploy the application
``` Answer : In directory chart ```

4. Setup GKE cluster with the related resources to run GKE like VPC, Subnets, etc. by following GKE Best Practices using any IaC tools (Terraform, OpenTufo, Pulumi) (Bonus point: use Terraform/Terragrunt)
Expected Output: IaC code
``` Answer : In directory chart ```

5. Condition: Avoid injecting the generated GCP access keys to the application directly. 
Expected Output: Kustomize manifest, IaC code or anything to complete this task.
``` Answer : In directory chart ```

6. Use ArgoCD to deploy this application. To follow GitOps practices, we prefer to have an ArgoCD application defined declaratively in a YAML file if possible.
Expected output: Yaml files and instruction how to deploy the application or command line
``` Answer : In build-go-12.Jenkinsfile, deployment-chart.Jenkinsfile, deployment-workflow.Jenkinsfile ```

7. Create CICD workflow using GitOps pipeline to build and deploy application 
Expected output: GitOps pipeline (Github, Gitlab, Bitbucket, Jenkins) workflow or diagram
``` Answer : In directory chart, workflow.png ```