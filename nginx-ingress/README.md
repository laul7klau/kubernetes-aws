This section provides a one-command quick deployment of the NGINX ingress controller. 
The commands in the *create-ingress.sh* script implements the steps in the [NGINX ingress controller guide](https://github.com/laul7klau/kubernetes-aws/edit/main/nginx/README.md) and [NGINX example in Github](https://github.com/nginxinc/kubernetes-ingress/tree/master/examples/complete-example).  


<img src="https://github.com/laul7klau/kubernetes-aws/blob/main/nginx-ingress/nginxingress.png" width="70%" height="40%">

## Pre-requisites:
You must run the commands in the parent directory *kubernetes-aws* first to deploy a k8 cluster in AWS cloud which will also configure kube.config in your local directory.

## Steps:  
Copy and run the commands below:   
``wget https://raw.githubusercontent.com/laul7klau/kubernetes-aws/main/nginx-ingress/create-ingress.sh``    
``chmod u+x create-ingress.sh``   
``./create-ingress.sh``     

Or simply copy and paste to run the commands in the script.

## Verification:  
Perform the verification steps in [Step 4 Test the Application](https://github.com/nginxinc/kubernetes-ingress/tree/master/examples/complete-example)  

## Removal
Download and run *delete-ingress.sh*


