# BIG-IP Controller Ingress Service  

This is a step by step guide to deploy BIG-IP Controller Ingress Service CIS

## Pre-requisites
You have performed the steps in the previous directory to create a Kubernetes cluster in AWS.

## Steps  
### Create the BIG-IP instance
1. From the K8 cluster created, gather and record down the following information:
   - **VPC:** ID where eksctl deployed the k8 cluster. Go to Services > VPC
   - **Subnet ID:** to deploy the BIG-IP instance. Go to Services > Subnets. Example: Subnet ID of  eksctl-<name>-cluster/SubnetPublicUSWEST2A

2. Enter the following to download the script to deploy a 1 NIC PAYG BIG-IP instance.  
   ``wget https://raw.githubusercontent.com/F5Networks/f5-aws-cloudformation/master/supported/standalone/1nic/existing-stack/payg/deploy_via_bash.sh``  

   ``chmod u+x deploy_via_bash.sh``

3. Upload the public key you generated in the previous procedure (kubernetes-aws directory) when creating the kubernetes cluster. If you didn't, simply run *ssh-keygen*.  
```aws ec2 import-key-pair --key-name mykey --public-key-material fileb://~/.ssh/id_rsa.pub```

4. Run the script. Enter the subnet ID and VPC ID from step 1.  
``./deploy_via_bash.sh --stackName bigipstack --licenseType Hourly --sshKey mykey --subnet1Az1 subnet-??? --imageName Good200Mbps --restrictedSrcAddressApp 0.0.0.0/0 --Vpc vpc-??? --instanceType m5.large --restrictedSrcAddress 0.0.0.0/0``  

### BIG-IP instance tasks. 

1. Login to the BIG-IP
   - ``ssh -i ~/.ssh/id_rsa admin@<BIG-IP IP>``
   - ``bash``
   - Create a CIS partition
     ``tmsh create auth partition cispartition``
   - Change admin password:  
     ``passwd``
   - Login to BIG-IP GUI *https://<BIG-IP IP>:8443*
   - Verify AS3 is installed at *iApps* > *Package Managment LX*. See "*f5-appsvcs*"

## For CIS NodePort mode deployment:
- Fill in the value of "--bigip-url" in cis-deployment.yaml with the "Private IPv4 address" of the BIG-IP instance.
- Fill in the value of the "virtualAddresses" value in the as3.yaml file. This is the IP address of the virtual server on the BIG-IP.
- Add the security group (eksctl-azkubecluster-cluster-ClusterSharedNodeSecurityGroup-XXXX0 to the BIG-IP instance.  
  1. Go to Services > EC2 > Instances   
  2. Select Name of BIG-IP instance.  
  3. Select Actions > Security > Change Security Group
  4. Search for (eksctl-azkubecluster-cluster-ClusterSharedNodeSecurityGroup-XXXX)
  5. Add Security group. 
  6. Save.

## Create and deploy CIS
Replace the ???? chars in the next line with the your BIG-IP password. 
``kubectl create secret generic f5-bigip-ctlr-login -n kube-system --from-literal=username=admin --from-literal=password=????``  
Copy and paste the following commands:  
``kubectl create serviceaccount bigip-ctlr -n kube-system``  
``kubectl create -f k8s-rbac.yaml``  
``kubectl create -f customresourcedefinitions.yaml``  
``kubectl create -f cis-deployment.yaml ``  

``#Create application pods and services ``  
``kubectl create -f f5-hello-world-deployment.yaml``  
``kubectl create -f f5-hello-world-service.yaml ``  

``#Create as3 definition to configure BIG-IP ``  
``kubectl create -f as3.yaml``  

BIG-IP Controller Ingress Service is deployed.  

## Verification:
- Access the BIG-IP virtual server: http://??bigip external IP address??   
- The following should be configured on the BIG-IP:
  - New partition with virtual server, pool, and the Kubernetes nodes as pool members.  
- The BIG-IP Controller is deployed as a pod in the kube-system namespace.  
$ kubectl get pods -n kube-system. 
NAME                                         READY   STATUS    RESTARTS   AGE   
[...]  
k8s-bigip-ctlr-deployment-7f56b674ff-lj5kk   1/1     Running   0          85s  
[...]   

## Destroy
Copy and paste the following commands:  

``kubectl delete -f as3.yaml``  
``kubectl delete -f f5-hello-world-service.yaml``  
``kubectl delete -f f5-hello-world-deployment.yaml``  
``kubectl delete -f cis-deployment.yaml``  
``kubectl delete -f customresourcedefinitions.yaml``  
``kubectl delete -f k8s-rbac.yaml``  
``kubectl delete serviceaccount bigip-ctlr -n kube-system``  
``kubectl delete secret f5-bigip-ctlr-login -n kube-system``  

On AWS portal, destroy the BIG-IP stack.  
- Go to CloudFormation > Stacks > Name-of-Stack, 
- *Delete*
