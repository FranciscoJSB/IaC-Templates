# Azure Infrastructure Templates

This repository contains a collection of infrastructure-as-code (IaC) templates for deploying and managing resources on Microsoft Azure using Terraform and Bicep. These templates help automate and streamline the provisioning of Azure services, ensuring consistent and reproducible deployments across different environments.

## Contents

- **Terraform Templates**: Comprehensive Terraform scripts for deploying various Azure resources, including virtual networks, virtual machines, storage accounts, Azure Kubernetes Service (AKS), and more.
- **Bicep Templates**: Modular Bicep templates for defining Azure resources, offering a more concise and readable alternative to ARM templates. These templates cover a wide range of Azure services and configurations.

## Features

- **Modular Design**: Each template is designed to be modular, allowing you to easily customize and extend them to fit your specific needs.
- **Best Practices**: Templates follow Azure best practices for security, scalability, and performance.
- **Documentation**: Detailed documentation for each template, including usage instructions, parameters, and examples.
- **Version Control**: Templates are version-controlled to track changes and improvements over time.

## Getting Started

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/azure-infrastructure-templates.git
    ```
2. **Navigate to the Desired Template**: Browse the directory structure to find the template that meets your requirements.
3. **Customize the Template**: Modify the parameters and configurations as needed for your deployment.
4. **Deploy the Template**: Follow the instructions in the documentation to deploy the template to your Azure environment.

## Directory Structure

```plaintext
azure-infrastructure-templates/
│
├── terraform/
│   ├── virtual-network/
│   ├── virtual-machine/
│   ├── storage-account/
│   └── aks/
│
├── bicep/
│   ├── virtual-network/
│   ├── virtual-machine/
│   ├── storage-account/
│   └── aks/
│
└── README.md
