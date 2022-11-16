# AppSec-K8S-demo

This terraform project is for demoing Check Point AppSec solution on EKS (AWS)

Prior to apply the tf You will need to define the following IAM roles:

  * eksClusterRole: AWS service (EKS Cluster) with attached AmazonEKSClusterPolicy policy
  * eksWorkerRole: AWS Service (EC2) with attached AmazonEKSWorkerNodePolic, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEBSCSIDriverPolicy policies

In terraform.tfvars add the AWS region you want the cluster is deployed to, AK and SK for authentication
