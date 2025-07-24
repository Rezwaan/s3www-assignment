Senior Cloud Engineer - UP42 Assignment

## 📋 Table of Contents

- [Overall Solution](#overall)
- [Potential Shortcomings](#shortcoming)
- [Future Enhancements](#enhancement)


## Overall Solution

Solution and Implementation has three major parts which includes.  

### Deploying Helm Charts for s3www and MinIO 

While doing so, I simple added s3www Chart files, created templates and helper function to provide required/standard variables. Then I added MinIO as dependency for s3www chart. Below is the details process.

##### s3www Deployment.  
While deploying s3www, one of the task listed in assignment was to make sure that the gif (i-e object) should be there in MinIO bucket as an s3 object so that s3www can fetch the object and serve it as a web page. For that I had few ways in my mind.

1) **Terraform resource dependency**
In this apprach, I could have created a kubernetes deployment consisting of a pod as a terraform resource, this pod will be having the logic for cheking the MinIO liveliness, then download the gif, then upload it to MinIO and verify.   
And then I could have marked it as a dependency for the main s3www deployment resource in terraform.  
But the reason I didnt choose this approach is that fact that I wanted container level sequencing, not resource level sequencing. In this approach I will have to wait for a seperate deployment to spin up new pod, pass healthchecks then perform the logic and then get used by the primary deployment.  

2) **initContainer**. 
In this approach, I deployed an initContainer, which implements the above mentioned logic, achives container level sequencing and in a single deployment I get to achieve the purpose more efficiently and fast. For details about the logic please refer to the `run-file-fetcher-and-wait` initContainer in s3www-deployment within templates folder.  

**❗️took some help from chatgpt for using MinIO command line in order to write the script**

##### MinIO Deployment. 
First I went with simple approach where I used MinIO chart as is and deployed with default "rootUser" and "rootPassword", in this approach i didnt have to provide any custom value for MinIO chart and it works fine. But later I realised that everytime I was deploying the chart via terraform, its creating a new username and password, for which I have to run below command everytime to fetch credentials.

```bash
kubectl get secret -n s3www s3www-app-minio -o jsonpath='{.data.rootUser}' | base64 -d && echo
```
So, I moved to another approach where first I studied MinIO chart from here [MinIO Tenant Chart Values Reference](https://min.io/docs/minio/kubernetes/upstream/reference/tenant-chart-values.html#:~:text=%23%20%20%20existingSecret%3A%20false)
then I realized that I can use custom secrets for credentials as well, this way I wont have to fetch credentials again and again and we can setup cdredentials as per our need (e.g company policy etc).  

Similarly, I also realized that my minIO deployment was running multiple sts pods, which was unnecessary to have. so In the same values.yml file I shifted the minIO deployment from `distributed` to `standalone`.

```yaml
# Single instance mode (not distributed)
mode: standalone
replicas: 1

# MinIO access credentials
existingSecret: s3www-app-minio
```
### Kubernetes Secrets

The reason why I used sealed secret is the fact that when I was deploying custom secret for MinIO, I realized that when I will be committing to github repo, I will have to expose the credentials in the terraform resource section, So few ways came to my mind.
1) **GitHub Actions Secret** 

    Use github secrets and create github actions pipeline.I could have gone with this solution where I save credentials in github secrets in masked way and then fetch them in pipeline before running terraform apply command.  
    But this solution has its own flaws such as there is no way to update the credentials automatically (e.g via tf) other than going manually in github actions and change value there, which kills the purpose of IaC and the infrastructure in terraform will not be intact.  

2) **Secret using Kubectl**.  

    Create simple secret using kubectl and dont commit secret yaml code in github repo, but again it kills the purpose of IaC

3) **Sealed Secret**.  

    Use Sealed Secret, which is one of the best way of managing secrets in GitOps approach where all k8 resources needs to be in git. So I went with this approach.

#### Sealed Secret. 
In order to deploy sealed secret, I simply added sealed secret helm chart in the repo and installed it as mentioned [here](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#helm-chart). 

Once the sealed secrets were deployed, I installed kubeseal as mentioned [here](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#homebrew:~:text=Kubeseal-,Homebrew,-The%20kubeseal%20client)

After install kubeseal, I created sealed secret from a simple secret yaml file, this simple yaml file has the actual secret values we want to have, for example in our case I used this file.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: s3www-app-minio
  namespace: s3www
  annotations:
    sealedsecrets.bitnami.com/managed: "true"
type: Opaque
stringData:
  rootUser: admin
  rootPassword: password123
```

Then once I generated the sealed secrets, I deployed them in k8 cluster using terraform in proper order so that s3www deployment can use it.  
In `.gitignore` you can see one folder named as `.tmp`, This folder actually consists of the above mentioned file, Thanks to sealed secret we dont have to commit it in the repo and dont have to expose credentials.


### Terraform
1) First, I wrote simple terraform code in a single `main.tf` file since I wanted it to work in first iteration, so I created resources like `kubernetes_namespace_v1` and `helm_release`. Once I deployed the terraform it worked pretty fine other than small issues which I fixed with few iterations, the issues were like variables exposing secrets even after using `sensitive` tag, similarly, the minIO deployment was distributed which was consuming alot of my Docker Desktop resources so had to make it standalone.   
2) Then, I read about lifecycle management in the assignment, which is a very important aspect, so I pulled out terraform documentation and implemented lifecycle management for the resources.  
3) During the interview with Ben, I came to know that you are modularizing the terraform already. keeping that in mind, I tried to modularize the terraform resources (helm_release specifically), so that it can be reused later if we want to create more helm releases.  
4) I also worked on managing multiple environments, I actually created a dev workspace using  `terraform workspace new dev` and used the statefile for specific environment only, Although since its a local statefile, we dont get much benefit out of workspaces atm but for production deployment it will help us alot.



## Concern and Limitations 
There are few potential short comings I think are there with my solution, due to time constraint and the nature of assignment, I decided to list them here.
##### Security
There is no Network Policy defined which restricts the communication between MinIO pod and s3www pod, along with interaction of the Load Balancer service, which makes the internal communication less secure.
MinIO bucket is not secure properly, there is no TLS encryption, which makes the communication, like uploading, downloading files in MinIO bucket insecure.  
Similarly, our s3www web application is not not secure and is not serving on 443, I could have deployed Nginx ingress load balancer and use lets encrypt certificate to secure it but I think thats out of scope for this assignment.
No Guardrails/SAST checks for terraform code, atm i will have to check code to look for any security escalated permissions that are requested in tf as well as helm files and then act upon it. we need to have guardrails in webhooks or tools like `checkov` for this purpose

##### Code Quality
We should have seperate repositories for Helm Charts, Terraform Modules and Terraform main code, Ideally there should be 3 repositories, one containing helm chart release so that we can just reference the chart and we just have to provide values.yaml in main repo. Similarly, we should have seperate repo for terraform module for better module management

##### Code Metrics and Logs
We should make sure that the application is generating metrics and proper logs so that we can use different tools like prometheus (for metrics) and Loki (for logs aggregation) or other compatible tools.

## Future Enhancements

We can enhance the code and make it production ready by having below enhancements.  

##### CICD Pipeline
We can have CICD pipeline, which implements all standard ways like Continous testing along with CI/CD, Implement Guardrails like checkov and manage multiple terraform workspaces and deploy in a proper way.

##### Chart Museum
We can deploy [chart museum](https://chartmuseum.com/) for better management of Helm Charts and release the charts in an organize way.

##### Service Mesh
We can implement Service Mesh like Istio, Traefik for better management, communication and observability of microservices within cluster. This will also help us in achiving Zero trust policy.

##### Security
As we talked earlier we need to enhance security by implementing Load Balancer, Network Policies, Policy as code (OPA, Gatekeeper) and Guardrails for k8 as well as tf.

##### Backup and Disaster Recovery
We need to make sure we have proper backup setup for MinIO as well as persistant data. along with a good DR plan, so that we can be highly available and more reliable.