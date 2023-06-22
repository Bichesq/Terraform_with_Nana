<h1>Terraform_with_Nana</h1>
<h2>Demo project. Part one</h2>
1. Create a vpc
2. create one subnet in one az
3. connect vpc to internet using igw
4. deploy ec2 instance in the subnet 
5. run ingnx docker image on the instance 
-first we used user_data to do the installations 
-then we moved the script to a file
6. Create and configure a security group with ports 80 for http and 22 for ssh