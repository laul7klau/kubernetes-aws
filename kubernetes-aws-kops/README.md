# kubernetes-aws-kops
This repository is a step by step guide for the QUICK deployment of NGINX Ingress Controller or BIG-IP Container Ingress Service for Kubernetes.  

**NOTE**: *kops* needs only 5-8 mins to create a k8 cluster. However, if you need some AWS k8 resources *eksctl* creates, go to [ekctl](https://github.com/laul7klau/kubernetes-aws).   

## Repository Map:  
- **kubernetes-aws**:  
  Perform the steps in this README.md to first deploy a Kubernetes cluster on AWS using kops.  
 
     - [**nginx-ingress**](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress): Perform the steps here to deploy NGINX ingress controller.  
     OR
     - [**bigip-ctrl-ingress**](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress): Perform the steps here if you want to deploy BIG-IP CIS.  
       - [**ingressLink**](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress/ingressLink): Create a F5 Ingress Link with the BIG-IP CIS & the NGINX ingress controller.  

## Pre-requisites:
1. Install *aws cli* on your client device. Refer to [Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. Configure your AWS credentials.
   - Go to IAM role > Users > <User> > Security Credentials, select **Create access key**.
   - Enter *aws configure*
3. Generate SSH key pair. The key is referenced by kube-cluster.yaml to enable login to kubernetes nodes.
   - Enter: *ssh-keygen*
4. Install [kubectl and kops](https://kops.sigs.k8s.io/getting_started/install/).  

For the explanation on the commands, refer to [Creating a cluster](https://kubernetes.io/docs/setup/production-environment/tools/kops/).  

## Steps:
1. Set up iam roles in AWS by copying and pasting the following:   
``#Setup iam roles in AWS``   
``aws iam create-group --group-name kops``  
``aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops``  
``aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops``  
``aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops``  
``aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops``  
``aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops``  
``aws iam create-user --user-name kops``  
``aws iam add-user-to-group --user-name kops --group-name kops``  
``aws iam create-access-key --user-name kops``   
  
2. Copy and paste the following commands to create your cluster.     
**NOTE: Replace the *CLUSTER_NAME* of the cluster if you want, but $NAME must give rise to a unique name for S3 bucket in AWS. If unsure, do not make any edits.**   
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/kubernetes-aws-kops/cluster-config.tpl``   
``export CLUSTER_NAME=dev888clustername``    
``export NAME=$CLUSTER_NAME.k8s.local``   
``export KOPS_STATE_STORE=s3://$NAME``  
``export SSH_PUBLIC_KEY=~/.ssh/id_rsa.pub``  

   ``#Creates S3 bucket to store cluster data. S3 bucket name must be AWS globally unique. If you see an error, rename $CLUSTERNAME in the first line``  
   ``aws s3 mb $KOPS_STATE_STORE``  
   
   ``#Create cluster.yaml from template file.``   
   ``sed "s/{{NAME}}/$NAME/g" cluster-config.tpl > cluster-config.yaml``   
   
   ``#Apply the cluster-config yaml file. You may want to view the settings first.``  
   ``kops create -f cluster-config.yaml``  
   ``kops create secret sshpublickey admin -i $SSH_PUBLIC_KEY --name $NAME --state $KOPS_STATE_STORE``  
   
   ``#Enter this command to create your cluster.``  
   ``kops update cluster --name $NAME --yes --admin``   
   ``kops validate cluster --wait 10m``   
   
   **Note**: If you encounter the error, "unexpected error during validation: error listing nodes: Unauthorized", run the following command:  
   ``kops export kubecfg --admin``  
   For more information, refer to [stackoverflow link](https://stackoverflow.com/questions/66341494/kops-1-19-reports-error-unauthorized-when-interfacing-with-aws-cluster).  

## Verification:  
You should observe the following output. 1 master and 3 nodes will be created.:  
```
$ kops validate cluster $NAME
Validating cluster dev.iexample.k8s.local

INSTANCE GROUPS
NAME			ROLE	MACHINETYPE	MIN	MAX	SUBNETS
master-us-west-2a	Master	t3.medium	1	1	us-west-2a
nodes-us-west-2a	Node	t3.medium	3	3	us-west-2a

[...]
Your cluster dev.k8s.local is ready    
```
## Destroy:  
Enter the following command:  
``kops delete cluster $NAME --yes``   

## What's next:  
- Go to the sub directory, [nginx-ingress](https://github.com/laul7klau/kubernetes-aws/tree/main/nginx-ingress), to create NGINX Ingress Controller.    
OR
- Go to the sub directory [bigip-ctrl-ingress](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress) to create the BIG-IP Controller Ingress Service, CIS.  
  -  Then go to the sub-sub directory *Ingress link*, to create the NGINX Ingress Controller and F5 Ingress Link.  