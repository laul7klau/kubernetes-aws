This is a step by step guide to deploy BIG-IP Controller Ingress Service, CIS. This section creates the following:
- [BIG-IP instance](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress#create-the-big-ip-instance)
- [BIG-IP Controller Ingress Service](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress#create-the-big-ip-controller-ingress-service)

# Pre-requisites
- You have performed the steps in the previous directory to create a Kubernetes cluster in AWS.

# Steps  
### Create the BIG-IP instance
1. From the K8 cluster created, gather and record down the following information:
   - **VPC:** ID where eksctl deployed the k8 cluster. Go to Services > VPC
   - **Subnet ID:** to deploy the BIG-IP instance. Go to Services > Subnets. Example: Subnet ID of  eksctl-<name>-cluster/SubnetPublicUSWEST2A

2. Enter the following to download the script to deploy a 1 NIC PAYG BIG-IP instance.  
   ``wget https://raw.githubusercontent.com/F5Networks/f5-aws-cloudformation/master/supported/standalone/1nic/existing-stack/payg/deploy_via_bash.sh``  

   ``chmod u+x deploy_via_bash.sh``

3. Upload the public key you generated in the previous procedure (kubernetes-aws directory) when creating the kubernetes cluster. If you didn't, simply run *ssh-keygen*.  
```aws ec2 import-key-pair --key-name mykey --public-key-material fileb://~/.ssh/id_rsa.pub```

4. Fill in the ???subnet ID and ???VPC ID from step 1 in the command below and run the script.    
``./deploy_via_bash.sh --stackName bigipstack --licenseType Hourly --sshKey mykey --subnet1Az1 subnet-??? --imageName Good200Mbps --restrictedSrcAddressApp 0.0.0.0/0 --Vpc vpc-??? --instanceType m5.large --restrictedSrcAddress 0.0.0.0/0``  
If the task takes longer than 5mins, you may observe the following error:  
```In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=5pooknn8bmapsmdkegu5ikyng (Service: AmazonEC2; Status Code: 401; ```   
Visit the link in your error message to accept the terms and subscribe. This is required only once.

#### BIG-IP instance tasks. 

1. Login to the BIG-IP
   - ``ssh -i ~/.ssh/id_rsa admin@<BIG-IP IP>``
   - ``bash``
   - Create a CIS partition
     ``tmsh create auth partition cispartition``
   - Change admin password:  
     ``passwd``
   - Login to BIG-IP GUI *https://<BIG-IP IP>:8443*
   - Verify AS3 is installed at *iApps* > *Package Managment LX*. See "*f5-appsvcs*"

### Create the BIG-IP Controller Ingress Service
#### Configure the CIS deployment files:  
1. Copy and paste the following commands:   

``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/cis-deployment.yaml``  
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/as3.yaml``  
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/f5-hello-world-deployment.yaml``  
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/f5-hello-world-service.yaml``  

2. *cis-deployment.yaml*: 
   - Fill in the value of "--bigip-url" in  with the self IP of the BIG-IP. This is the private IP address of the BIG-IP that the controller will contact. Using the external IP may work but is not secure.  
   - Configure the **"--pool-member-type=cluster"** field in the *cis-deployment.yaml* file.  
     - For CIS nodeport deployment, set this to *nodeport*.   
     - For CIS clusterIP deployment, set this to *cluster*.  
3. *as3.yaml*: Fill in the value of the "virtualAddresses" value. This is the IP address of the virtual server on the BIG-IP. For single NIC, this is  the "Private IPv4 address" associated to the external IP of the BIG-IP.   
4. Add the security group (eksctl-azkubecluster-cluster-ClusterSharedNodeSecurityGroup-XXXX0 to the BIG-IP instance.  
   1. Go to Services > EC2 > Instances   
   2. Select Name of BIG-IP instance.  
   3. Select Actions > Security > Change Security Group
   4. Search for (eksctl-azkubecluster-cluster-ClusterSharedNodeSecurityGroup-XXXX)
   5. Add Security group. 
   6. Save.

#### [Perform this only for CIS clusterIP deployment]  
1. Enter the following commands to create the VXLAN config on the BIG-IP:  

``tmsh create net tunnels vxlan fl-vxlan port 8472 flooding-type none``   
``tmsh create net tunnels tunnel k8s-tunnel key 1 profile fl-vxlan local-address <bigip-selfip. node subnet>``    
``tmsh create net self k8tunnelselfip address <assigned ip in pod subnet>/255.255.0.0 allow-service none vlan k8s-tunnel``   

View the resources created on the BIG-IP at **Network > Tunnels** and **Network > Self IP**   

#### Create and deploy BIG-IP Controller Ingress Service and application pods.  
1. Replace the ???? chars in the next line with the your BIG-IP password. 

``kubectl create secret generic f5-bigip-ctlr-login -n kube-system --from-literal=username=admin --from-literal=password=????``  

2. Copy and paste the following commands:     

``kubectl create -f https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/k8s-rbac.yaml``  

``kubectl create serviceaccount bigip-ctlr -n kube-system``   
``kubectl create -f cis-deployment.yaml``  

``#Create application pods and services ``  
``kubectl create -f f5-hello-world-deployment.yaml``  
``kubectl create -f f5-hello-world-service.yaml`` 
  
``#Create as3 definition to configure BIG-IP ``  
``kubectl create -f as3.yaml``  

BIG-IP Controller Ingress Service is deployed.  

## Verification:
- Access the BIG-IP virtual server: http://??bigip external IP address??   
- The following should be configured on the BIG-IP:
  - New partition with virtual server, pool, and the Kubernetes nodes as pool members. 
  - The pool members port numbers will be ephemeral random port numbers when using CIS **nodeport deployment**.   
  - It would be a fixed port number such as 8080, configured in the application yanl file. Or the actual port number thee pod is listening at for CIS **clusterIP deployment**.  
- The BIG-IP Controller is deployed as a pod in the kube-system namespace.  
  $ kubectl get pods -n kube-system  
  NAME                                         READY   STATUS    RESTARTS   AGE   
  [...]   
  k8s-bigip-ctlr-deployment-7f56b674ff-lj5kk   1/1     Running   0          85s  
  [...]   

## What's next:  
Go to the sub directory *ingresslink*, to create NGINX ingress controller and F5 Ingress Link.  

## Destroy
1. Copy and paste the following commands:  

``kubectl delete -f as3.yaml``  
``kubectl delete -f cis-deployment.yaml``  
``kubectl delete -f https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/k8s-rbac.yaml``  
``kubectl delete serviceaccount bigip-ctlr -n kube-system``  
``kubectl delete secret f5-bigip-ctlr-login -n kube-system``  
``kubectl delete -f f5-hello-world-deployment.yaml``  
``kubectl delete -f f5-hello-world-service.yaml`` 


2. On AWS portal, destroy the BIG-IP stack.  
   - Go to CloudFormation > Stacks > Name-of-Stack  
   - *Delete*.   

## Source
[F5 CIS on Clouddocs](https://clouddocs.f5.com/containers/latest/userguide/kubernetes/#examples-repository).  
The [F5Networks / k8s-bigip-ctlr repository](https://github.com/F5Networks/k8s-bigip-ctlr).  
