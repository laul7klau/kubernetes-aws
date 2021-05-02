In this section, you create a F5 Ingress Link.  
- NGINX Ingress Controller.  
- BIG-IP Instance.  
- BIG-IP Controller Ingress Services.  
- F5 Ingress Link.  

**Image source**: [F5 Clouddocs](https://clouddocs.f5.com/containers/latest/userguide/ingresslink/)  

![F5 Ingress Link](ingress-link-diagram.png)   

# Pre-requisites:
- You must have performed all the steps in the parent directory to create a BIG-IP instance and BIG-IP Controller Ingress Service.  
- The BIG-IP CIS is working in nodeport mode.

# Steps:
To create F5 Ingress Link, create NGINX ingress controller and BIG-IP Controller Ingress Service first.  
## Create NGINX ingress controller.   
1. Download the *create-nginx-ingress.sh* script.  
2. Run the script:  
   - chmod u+x create-ingress.sh    
   - ./create-nginx-ingress.sh   
   OR simply copy and paste the commands in the script all at together.   
   
## Modify existing BIG-IP Controller Ingress Service.  
For F5 Ingress link, the BIG-IP CIS must run in Custom Resource Mode, CRD mode. 
1. Delete the AS3 and BIG-IP CIS created previously in the parent [bigip-ctrl-ingress dir](https://github.com/laul7klau/kubernetes-aws/tree/main/bigip-ctrl-ingress). And make a new copy of the cis-deployment file for F5 Ingresslink.  
``kubectl delete -f as3.yaml``  
``kubectl delete -f cis-deployment.yaml``   
``cp cis-deployment.yaml cis-ingresslink-deployment.yaml``  

2. Edit *cis-ingresslink-deployment.yaml*:  
	 - Uncomment "--custom-resource-mode=true",  

## Create F5 Ingress Link
1. Create the following iRule on the BIG-IP instance:
   - Follow steps 4 and 5 in [Lab4.1 BIG-IP Setup](https://clouddocs.f5.com/training/community/containers/html/class1/module4/lab1.html) to create the iRule *Proxy_Protocol_iRule* on the BIG-IP instance.  
2. Copy and paste the following commands:  

``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/customresourcedefinitions.yaml``     

``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/ingresslink-customresourcedefinition.yaml``

``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/ingresslink.yaml``   

``kubectl apply -f ingresslink-customresourcedefinition.yaml``    
``kubectl apply -f customresourcedefinitions.yaml``   
``kubectl apply -f cis-ingresslink-deployment.yaml``   
``kubectl apply -f ingresslink.yaml``    

NGINX ingress controller, BIG-IP CIS, BIG-IP instance and F5 Ingress link are deployed.

# Verification:
- In the BIG-IP instance, 2 virtual servers (ports 80, 443) should be created with 2 pools (80, 443). 
  - Each VS corresponds to the services declared in *'nodeport.yaml'* when creating the nginx-ingress controller. The selector in ingresslink.yaml must match the *'label'* in *'nodeport.yaml'*
  - The iRule created in step 3 should automatically be associated with the VSs.
  Note: the https VS does not have ssl profiles. SSL is terminated at the NGINX Ingress controller. In production, you should terminate SSL on the BIG=IP instance.  
- Access http://cafe.example.com/coffee and https://cafe.example.com/tea, where cafe.example.com is matched to the aws external IP of the BIG-IP instance in the host file. The coffee and tea app deployed with the NGINX ingress controller should display.

# Destroy:
1. Download and run the *delete-all.sh* OR copy and paste its commands.  
2. On AWS portal, destroy the BIG-IP stack.  
   - Go to CloudFormation > Stacks > Name-of-Stack. 
   - Delete.  





 
