# kubernetes-aws
This section describes the steps to deploy a Kubernetes cluster on AWS based on the configuration in kube-cluster.yaml.

## Pre-requisites:
1. Install aws cli on your client device. Refer to [Installing AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. Configure your AWS credentials.
   - Go to IAM role > Users > <User> > Security Credentials, select **Create access key**.
   - Enter *aws configure*
3. Generate SSH key pair to login to kubernetes nodes if necessary.
   - Enter: *ssh-keygen*
4. Install **eksctl** on your client device to manage k8 cluster. [Installing eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

## Steps:
1. View *kube-cluster.yaml* which contains the basic configuration for a cluster on AWS. Make changes as appropriate.
2. Create the cluster by entering:
*eksctl create cluster -f kube-cluster.yaml*
The cluster creation process on AWS will typically take 25-30mins. 
