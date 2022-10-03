# Harness Account provisioning with Terraform

This repo contains all the necessary to provision and onboard a new Harness account and will create the following architecture

![Enterprise Arch](./contrib/fixtures/harness-tf.jpg)

### **Directory**

Implementation code is organized with the following structure

```bash
.
├── contrib
│   ├── docker
│   │   └── devcontainer.Dockerfile
│   ├── fixtures
│   │   └── ...
│   ├── harness
│   │   └── templates
│   │       └── ...
│   └── manifests
│       └── ...
├── harness-provision
│   ├── main.tf
│   ├── provider.tf
│   └── variables.tf
└── tfvars
    └── cristian
        └── account.tfvars

```