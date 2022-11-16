# AppSec-K8S-demo

This terraform project is for demoing Check Point AppSec solution on EKS (AWS) using bkimminich/juice-shop image.

AWS cli, kubectl and helm are needed.

Prior to apply the tf you will need to define the following IAM roles:

  * eksClusterRole: AWS service (EKS Cluster) with attached AmazonEKSClusterPolicy policy
  * eksWorkerRole: AWS Service (EC2) with attached AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEBSCSIDriverPolicy policies

In terraform.tfvars add the AWS region you want the cluster is deployed to, AK and SK for authentication.

If TLS is enabled for the Ingress, a Secret containing the certificate and key for juice.yourdomain.com must also be provided in secret-juice.yaml:

	apiVersion: v1
	kind: Secret
		namespace: foo
	data:
		tls.crt: <base64 encoded cert>
 		tls.key: <base64 encoded key>
	type: kubernetes.io/tls
	
In Check Point Infinity portal (https://portal.checkpoint.com) has to be defined the following Asset (using K8S deployment):



After init/plan/apply terraform update the active K8S context:

aws eks update-kubeconfig --region <region_in_terraform.tfvars> --name eks-appsec

Create the deployment:

kubectl apply -f '/.../.../juiceshop.yml'

In case TLS is enabled, create a secret on the K8S cluster:

kubectl apply -f '/.../.../secret-juice.yaml'

