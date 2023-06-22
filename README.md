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

<h2>Modules Branch</h2>
- Here the configuration files are separated into two modules:<br>
    - server and<br>
    - subnet<br>
- Each module has its three files that are typical to modules:<br>
    - main.tf<br>
    - output.tf<br>
    - variable.tf<br>
3. In the main.tf in each module the references are adjusted accordingly. References to resources that are out of the modules are variablised.<br>
4. Then after the module done, it is now referenced in the root main.tf where the source is specified and then the variable which are defined in the modules. These variables are themselves set to the variables that are defined in the terraform.tfvars