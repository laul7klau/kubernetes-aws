This is a step by step guide to deploy BIG-IP Container Ingress Service, CIS. This section creates the following:
- [BIG-IP instance](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress#create-the-big-ip-instance)
- [BIG-IP Container Ingress Service](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress#create-the-big-ip-controller-ingress-service)  


<img src="https://github.com/laul7klau/kubernetes-aws/blob/main/bigip-ctrl-ingress/BIGIP-CIS.png" width="70%" height="40%">


# Pre-requisites
- You have performed the steps in the previous directory to create a Kubernetes cluster in AWS.

# Steps  
### Create the BIG-IP instance
1. Upload the public key you generated in the previous procedure (kubernetes-aws directory) when creating the kubernetes cluster. If you didn't, simply run *ssh-keygen*.  You will use this key to login to the BIG-IP.   
```aws ec2 import-key-pair --key-name mykey --public-key-material fileb://~/.ssh/id_rsa.pub```

2. Fill in the ???subnet ID and ???VPC ID below and run the following by copying and pasting:   
   - **VPC:** ID where eksctl deployed the k8 cluster. Go to Services > VPC
   - **Subnet ID:** to deploy the BIG-IP instance. Go to Services > VPC > Subnets.   
     Example: Subnet ID of  eksctl: eksctl-<name>-cluster/SubnetPublicUSWEST2A or kops: us-west-2a.<name>.k8s.local.  
   
   ``BIGIP_VPC_ID=???``   
   ``BIGIP_SUBNET_ID=???``        

   ``wget https://raw.githubusercontent.com/F5Networks/f5-aws-cloudformation/master/supported/standalone/1nic/existing-stack/payg/deploy_via_bash.sh``  

   ``chmod u+x deploy_via_bash.sh``  
   ``./deploy_via_bash.sh --stackName bigipstack --licenseType Hourly --sshKey mykey --subnet1Az1 $BIGIP_SUBNET_ID --imageName Good200Mbps --restrictedSrcAddressApp 0.0.0.0/0 --Vpc $BIGIP_VPC_ID --instanceType m5.large --restrictedSrcAddress 0.0.0.0/0``  

3. Monitor the progress at Services > CloudFormation. Find the BIG-IP at Services > EC2 > Instances.   
   If the task takes longer than 5mins, you may observe the following error:  
    ```In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=5pooknn8bmapsmdkegu5ikyng (Service: AmazonEC2; Status Code: 401; ```   
    Visit the link in your error message to accept the terms and subscribe. This is required only once.

4. Login to the BIG-IP
   - ``ssh -i ~/.ssh/id_rsa admin@<BIG-IP IP>``
   - ``bash``
   - Create a CIS partition
     ``tmsh create auth partition cispartition``
   - Change admin password:  
     ``passwd``
   - Login to BIG-IP GUI *https://<BIG-IP IP>:8443*
   - Verify AS3 is installed at *iApps* > *Package Managment LX*. See "*f5-appsvcs*"

### Create the BIG-IP Container Ingress Service
#### Configure the CIS deployment files:  
1. Copy and paste the following commands:   

     ``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/cis-deployment.yaml``  
     ``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/as3.yaml``  
     ``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/f5-hello-world-deployment.yaml``  
     ``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/f5-hello-world-service.yaml``  

2. **cis-deployment.yaml**: 
   - Fill in the value of "--bigip-url" with the self IP of the BIG-IP. This is the private IP address of the BIG-IP that the controller will contact. Using the external IP may work but is not secure.  
   - Verify that **"--pool-member-type=nodeport"** in the *cis-deployment.yaml* file.  
     - For CIS nodeport deployment, set this to *nodeport*.   
     - For CIS clusterIP deployment, set this to *cluster*.  
3. **as3.yaml**:   
   Fill in the value of the "virtualAddresses".    
   This is the IP address of the virtual server on the BIG-IP. For single NIC, this is  the "Private IPv4 address" associated to the external IP of the BIG-IP.   
4. Add the security **node** group to the BIG-IP instance.  
   1. Go to Services > EC2 > Instances   
   2. Select Name of BIG-IP instance.  
   3. Select Actions > Security > Change Security Group
   4. Search for either of the **node** security group (depending on whether you used eksctl or kops to deploy):
      - **eksctl**: eksctl-xxx-cluster-ClusterSharedNodeSecurityGroup-xxx
      - **kops**: nodes.xxx.k8s.local
   5. Add Security group. 
   6. Save.

#### Create and deploy BIG-IP Container Ingress Service and application pods.  
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

BIG-IP Container Ingress Service is deployed!  

Optional: Change from Nodeport to Cluster IP mode   
The setup is currently running in Nodeport mode. See the verification section below to verify the nodeport vs clusterIP set up.  
To switch to ClusterIP mode, run:  
``kc edit -f cis-deployment.yaml -n kube-system``  

Replace 
``- --pool-member-type=nodeport``  with   ``- --pool-member-type=cluster``   

## Verification:   
- Access the BIG-IP virtual server: http://??bigip external IP address??   
- The following should be configured on the BIG-IP:
  - New partition with virtual server, pool, and the Kubernetes nodes as pool members. 
  - In CIS **nodeport**, the pool members are the Node IP addresses and port numbers are different ephemeral random port numbers  
  - In CIS **ClusterIP**, pool members are Pod IP addresses and port number is the one defined in the *f5-hello-world-deployment.yaml* file.  
- The BIG-IP Controller is deployed as a pod in the kube-system namespace.  
  $ kubectl get pods -n kube-system  
  NAME                                         READY   STATUS    RESTARTS   AGE   
  [...]   
  k8s-bigip-ctlr-deployment-7f56b674ff-lj5kk   1/1     Running   0          85s  
  [...]   

## What's next:  
Go to the sub directory [*ingresslink*](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress/ingressLink), to create NGINX ingress controller and F5 Ingress Link.  

## Destroy
1. Copy and paste the following commands:  

    ``kubectl delete -f as3.yaml``  
    ``kubectl delete -f f5-hello-world-deployment.yaml``  
    ``kubectl delete -f f5-hello-world-service.yaml``   
    ``kubectl delete -f cis-deployment.yaml``  
    ``kubectl delete -f https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/config/k8s-rbac.yaml``  
    ``kubectl delete serviceaccount bigip-ctlr -n kube-system``  
    ``kubectl delete secret f5-bigip-ctlr-login -n kube-system``  
 
2. On AWS portal, destroy the BIG-IP stack.  
   - Go to CloudFormation > Stacks > Name-of-Stack  
   - *Delete*.   

## Source
[F5 CIS on Clouddocs](https://clouddocs.f5.com/containers/latest/userguide/kubernetes/#examples-repository).  
The [F5Networks / k8s-bigip-ctlr repository](https://github.com/F5Networks/k8s-bigip-ctlr).  
