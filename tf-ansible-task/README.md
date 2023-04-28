## Technical Information:

- Terraform v1.4.6
- Ansible 2.9.6
- AWS Cloud
- Python 3

## Project Structure:

- ansible
- resources
- resources -> keys (Create a new SSH keypair using https://www.ssh.com/academy/ssh/keygen and upload the private(id_rsa)/public(id_rsa.pub) key pair to this directory)
- terraform

## Resources:

- Directory contains the security agent configuration file, installation script and SSH key pair to be used for server authentication from ansible.

## Terraform:

- Install the AWS CLI and Terraform CLI in the workstation. (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html, https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- Configure the AWS CLI with service accounts to connect and execute the terraform modules. (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- File 'main.tf' has the terraform resources to filter Ubuntu AMI, creates a new T2 micro EC2 instance out of it with SSH key pair based authentication. 
- It also creates and binds a security group to control inbound access for server port 22 and 443. The instance public DNS from terraform output will be stored as "tf_ansible_vars_file.yml" in the 'ansible' directory to be used by ansible playbooks.

## Ansible:

- Install the Ansible CLI. (https://docs.ansible.com/ansible/latest/command_guide/command_line_tools.html)
- File 'hosts' acts a adaptive ansible inventory to connect with terraform managed EC2 instance using SSH public key from 'resources/keys' directory.
- File 'setup_security_agent_playbook.yml' has the playbook tasks of copying the configuration, shell scripts to target server and performs the security agent installation process.
- File 'tf_ansible_vars_file.yml' will be auto-created/updated during terraform executions to update the EC2 instance public DNS from terraform output.

## Procedure to execute:

<b>Step 1:</b> Initialize terraform to connect with the AWS cloud provider using  '<b>terraform init</b>'
<b>Step 2:</b> Create a new terraform workspace using '<b>terraform workspace new "takehomechallenge"</b>'
<b>Step 3:</b> Dry run the terraform module to make sure of no errors and validating the AWS resources by '<b>terraform plan</b>'
<b>Step 4:</b> Create the AWS EC2 instance by executing '<b>terraform apply</b>'
<b>Step 5:</b> Validate the successful EC2 creation by logging into AWS Console (or) By navigating to 'ansible' directory and find the instance public DNS on 'tf_ansible_vars_file.yml' file.
<b>Step 6:</b> Upon successful AWS resource setup, execute the following ansible playbook command,
<b>ansible-playbook setup_security_agent_playbook.yml -i hosts --extra-vars=@tf_ansible_vars_file.yml --extra-vars "security_agent_token=CSG_$h4p3#7e"</b>
The ansible playbook command will connect with the newly terraform provisioned EC2 instance. Create a directory for security agent resources, moves the configuration/shell scripts from local to EC2 instance. Performs installation of security agent and closes the connection. 
<b>Step 7:</b> On successful installation and verification of security agent, to clean-up the resources, navigate to 'terraform' directory and execute '<b>terraform destroy</b>' to cleanup all the created resources.