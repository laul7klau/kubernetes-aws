In this section, you create a F5 Ingress Link. 

# Pre-requisites:
- You must have performed the steps in the parent directory to create a BIG-IP instance and BIG-IP Controller Ingress Service. The CIS is working in nodeport mode.

# Steps:
To create F5 Ingress Link, create NGINX ingress controller and BIG-IP Controller Ingress Service first.  
## Create NGINX ingress controller.   
1. Download the *create-ingress.sh* script.  
2. Run the script:  
   - chmod u+x create-ingress.sh    
   - ./create-ingress.sh   
   OR simply copy and paste the commands in the script all at together.   
   
## Create BIG-IP Controller Ingress Service.  
1. Delete the AS3 and BIG-IP CIS created previously. And make a new copy of the cis-deployment file for F5 Ingresslink.  
``kubectl delete -f as3.yaml`` 
``kubectl delete -f cis-deployment.yaml`` 
cp cis-deployment.yaml cis-ingresslink-deployment.yaml  

2. Edit *cis-ingresslink-deployment.yaml*:  
	 - Uncomment "--custom-resource-mode=true",  
3. Create the following iRule on the BIG-IP instance:
   - Follow steps 4 and 5 in [Lab4.1 BIG-IP Setup](https://clouddocs.f5.com/training/community/containers/html/class1/module4/lab1.html) to create the iRule *Proxy_Protocol_iRule* on the BIG-IP instance.  
4. Copy and paste the following commands:  

``wget https://github.com/laul7klau/kubernetes-aws/blob/main/bigip-ctrl-ingress/ingressLink/nodeport/config/customresourcedefinitions.yaml ``    
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/f5-hello-world-deployment.yaml`` 
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/f5-hello-world-service.yaml``    
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/ingresslink-customresourcedefinition.yaml`` 
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/bigip-ctrl-ingress/ingressLink/nodeport/config/ingresslink.yaml``   
``kubectl apply -f ingresslink-customresourcedefinition.yaml``    
``kubectl apply -f customresourcedefinitions.yaml``   
``kubectl apply -f cis-ingresslink-deployment.yaml``   
``kubectl apply -f ingresslink.yaml``    





 
