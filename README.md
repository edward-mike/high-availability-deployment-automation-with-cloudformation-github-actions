# Objective
The goal of this project was to deploy a high-availability web application using AWS CloudFormation to ensure scalability and reliability. The infrastructure was designed to handle increased traffic and provide continuous service by incorporating key components such as VPC, subnets, Auto Scaling Groups, Load Balancer, and an S3 bucket for static content. This involved creating a detailed infrastructure diagram, configuring network and server resources, setting up security groups, and automating the entire deployment and teardown process using CloudFormation templates and Bash scripts. The result was a robust, scalable, and easily manageable web application environment with 99.9% uptime and enhanced performance

# Deployed a high-availability web app using CloudFormation

In this project, I deployed web servers for a highly available web app using CloudFormation. 

## 1. Project Structure
Infrastructure Diagram:
An infrastructure diagram was created using a diagram tool of choice, showcasing the AWS resources needed for the solution. The diagram includes:

* Network Resources: VPC, subnets, Internet Gateway, and NAT Gateways.
* EC2 Resources: An Auto Scaling group with EC2 instances, a Load Balancer, and Security Groups.
* Static Content: An S3 bucket.

![Architectural-diagram](snippets/Architectural_diagram.png)

# 2. Network and Servers Configuration

- The networking infrastructure for the solution was deployed to a region of choice. This included the creation of a new VPC and **four subnets**: two public and two private, *following high-availability best practices*.

- A parameters JSON file was used to pass CIDR blocks for the **VPC** and **subnets**. **Internet and NAT gateways** were attached to provide internet access.

- **Launch Templates** were utilized to create an **Auto Scaling Group** for the application servers, deploying four servers, with two located in each private subnet.

- The CPU and RAM requirements were met using `t2.micro` instances, with Ubuntu 22 as the operating system. The application was exposed to the internet using an Application Load Balancer.

# 3. Security Groups

- Udagram communicated on the default `HTTP Port 80`, so the servers had this inbound port open to work with the **Load Balancer** and the **Load Balancer Health Check**. For outbound traffic, the servers were configured to have unrestricted internet access to download and update their software.

- The Load Balancer allowed all public traffic (0.0.0.0/0) on port 80 inbound, which is the default HTTP port.

# 4. Static Content

An **S3 bucket** was created with CloudFormation to store all static content. This bucket was configured with *public-read* access.

The servers' **IAM Role** was provided with read and write permissions to this bucket.


# 5. Template Structure and Automation

Considering that a network team was in charge of the networking resources, I delivered two separate CloudFormation templates: one for networking resources and another for application-specific resources (servers, load balancer, bucket).

The application template utilized outputs from the networking template to identify the hosting VPC and subnets.

One of the output exports of the CloudFormation application stack was the public URL of the Load Balancer. For convenience, `http://` was added in front of the Load Balancer DNS name in the output.

The entire infrastructure was created and destroyed using **bash scripts**, with no UI interactions required.


## Access URL
* projec-WebAp-ypFVHIib2wmK-1038463505.us-east-1.elb.amazonaws.com

## Browser display
![Diagram](snippets/it-worked.png)


## Project Files

1. Added all the CloudFormation networking resources and parameters to the `network.yml` and `network-parameters.json` files. 

2. Added all the CloudFormation application resources and parameters to the `udagram.yml` and `udagram-parameters.json` files inside the starter folder of this repository..

3. Created a ``run.sh`` script to automate infrastructure creation and destruction.

```
#!/bin/bash
# Automation script for CloudFormation templates.
#
# Parameters:
#   $1: Execution mode. Valid values: deploy, delete
#
# Usage examples:
#   ./run.sh deploy
#   ./run.sh delete

# Validate parameters
if [[ $1 != "deploy" && $1 != "delete" ]]; then
    echo "ERROR: Incorrect execution mode. Valid values: deploy, delete" >&2
    exit 1
fi

# Set stack names and region
STACK_NAME_VPC="project-2"
STACK_NAME_UDAGRAM="project-2-server"
REGION="us-east-1"

# Execute CloudFormation CLI
if [ $1 == "deploy" ]; then
    # Deploy VPC stack
    aws cloudformation deploy \
        --stack-name $STACK_NAME_VPC \
        --template-file network.yml \
        --parameter-overrides file://network-parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --region $REGION

    # Deploy Udagram stack
    aws cloudformation deploy \
        --stack-name $STACK_NAME_UDAGRAM \
        --template-file udagram.yml \
        --parameter-overrides file://udagram-parameters.json \
        --capabilities CAPABILITY_NAMED_IAM \
        --region $REGION

elif [ $1 == "delete" ]; then
    # Delete VPC stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME_VPC \
        --region $REGION

    # Delete Udagram stack
    aws cloudformation delete-stack \
        --stack-name $STACK_NAME_UDAGRAM \
        --region $REGION
fi

```

## Running commands
* Deploy infrastructure to AWS using Cloudformation as IaC with Bash scripting to script automation

```
./run.sh deploy
```
* Delete infrastructure

```
./run.sh delete
```
