# 3-Tier-Terraform
Simple 3 tier setup to use a template for other projects.  Does not have HA or redundancy.

1 VPC with a public subnet and 2 private subnets and a security group dedicated to each subnet.  
Middle subnet has a NAT gateway to allow outward calls.
Each security group allows SSH from the subnet it sits behind.
Instance terraform file has a couple of instances used to test the setup.

Can use the following command to SSH into the instance without agent forwarding.

ssh -i "demokey.pem" -o "ProxyCommand ssh -W %h:%p -i "demokey.pem" [JUMPBOX LOGIN]" [PRIVATE INSTANCE]
