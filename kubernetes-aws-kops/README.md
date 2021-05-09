# kubernetes-aws-kops
This repository is a step by step guide for the QUICK deployment of NGINX Ingress Controller or BIG-IP Container Ingress Service for Kubernetes.  

## Map:
- **kubernetes-aws**:  
  Perform the steps in this README.md to first deploy a Kubernetes cluster on AWS using kops.  
  ** NOTE**: kops needs only 5-8 mins to create a k8 cluster. However, if you need the full k8 resources, eksctl creates, go to [ekctl](https://github.com/laul7klau/kubernetes-aws).  
     - **nginx-ingress**: Perform the steps here to deploy NGINX ingress controller.  
     OR
     - **bigip-ctrl-ingress**: Perform the steps here if you want to deploy BIG-IP CIS.  

## Pre-requisites:
1. Install aws cli on your client device. Refer to [Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. Configure your AWS credentials.
   - Go to IAM role > Users > <User> > Security Credentials, select **Create access key**.
   - Enter *aws configure*
3. Generate SSH key pair. The key is referenced by kube-cluster.yaml to enable login to kubernetes nodes.
   - Enter: *ssh-keygen*
4. Install [kubectl and kops](https://kops.sigs.k8s.io/getting_started/install/).  

For the explanation on the commands, refer to [Creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kops/).  

## Steps:
1. Copy and paste the following commands: (Replace the name of the cluster if you want)   
export NAME=dev.k8s.local
export KOPS_STATE_STORE=s3://$NAME
export SSH_PUBLIC_KEY=~/.ssh/id_rsa.pub  

2. 
