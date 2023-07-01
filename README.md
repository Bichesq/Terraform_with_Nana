<h1>Terraform_with_Nana</h1>
<h2>Demo project. Part one</h2>
1. Create a vpc <br>
2. create one subnet in one az<br>
3. connect vpc to internet using igw<br>
4. deploy ec2 instance in the subnet <br>
5. run ingnx docker image on the instance <br>
-first we used the inline attribute in the user_data block to do the installations <br>
-then we moved the script to a file and used the script attribute in the user_data block<br>
6. Create and configure a security group with ports 80 for http and 22 for ssh

<h2> eks Branch</h2>
1. Here a new cluster is created, so since we dont have a couldformation template, we will use a vpc module in terraform. A simple google search will give the basic provider usage.<br>
2. A file vpc.tf is created to hold the configuration code for the vpc. The vpc module has not required attribute, however we define:<br>
   - source<br>
   - version<br>
   - cidr<br>
   - private_subnet_cidr<br>
   - public_subnet_cidr<br>
   - azs<br>
   - and tags<br>
3. Note that tags are<br>
    - For human consumption to have more information about the intrastucture<br>
    - As well as for referencing components from other components - programmatically. So tags are actually required so the (eks) cloud contoller manager can use to identify and communicate to our created resources in the cluster.<br>
    - So tags are created for the vpc as well as for the subnet. With these the CCM will be able to tell which vpc the subnets belong to and so on.<br>
    - For the subnets extra tags are also required for the loadbalancer controllers to know what loadbalancer types to be created in each: external elb for the public subnets and an internal elb for the private subnet.<br>
4. Another configuration file, eks.tf is created for the cluster configuration code. An eks cluster module from the terraform documentation is used. <br>
The eks module has no required inputs but the following are defined here:<br>
    - the sourse of course<br>
    - version<br>
    - cluster_name<br>
    - cluster_version<br>
    - subnet_ids (referenced from the output of the vpc module)<br>
    - vpc_id (referenced from the output of the vpc module)<br>
    - tags (environment and application)<br>
    - then the worker_group: these are a non-managed option. two ec2 instances are specified on which the worker nods will be created. Other options are fully managed nodes, semi-managed nodes and Fargate.<br>
5. For each of the instances the following attributes are specified:<br>
    - instance_type<br>
    - name<br>
    - asg_desired_capasity


    <h2>ISSUES ENCOUNTERED AND REMEDIES</h2>
    1. The argument work_groups for eks module is not valid after version 17.24.0. It has been replased with self_managed_node_groups. I did not need to change the arguments.<br>
    2. In the kubernetes provider, we do not need to use the argument load_config_file = "false". In recent versions the provider does not use the KUBECONFIG file by detault. Use config_path/s to set a path or paths to config files.<br>