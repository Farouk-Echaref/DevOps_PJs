
# Terraform with Docker: Automating NGINX Container Deployment

This guide demonstrates how to use **Terraform** with the **Docker provider** to automate the creation and management of a Docker container running the **NGINX web server**. Additionally, it explains how Terraform processes multiple `.tf` files for better configuration management.

* reference: - Terraform as IaC: https://developer.hashicorp.com/terraform/tutorials/docker-get-started/infrastructure-as-code

---

## **Prerequisites**

Ensure the following tools are installed on your system:

1. **Terraform** (version `~> 1.7`)
   - Install from [Terraform official downloads](https://developer.hashicorp.com/terraform/downloads).

   Verify installation:
   ```bash
   terraform --version
   ```

2. **Docker**
   - Follow the [Docker installation guide](https://docs.docker.com/get-docker/) for your OS.

   Verify installation:
   ```bash
   docker --version
   docker ps
   ```

---

## **Project Structure**

This project is organized into two main files:

1. **`terraform.tf`**: Specifies Terraform version and provider requirements.
2. **`main.tf`**: Defines the resources to manage with Terraform (Docker image and container).

---

## **Understanding Terraform File Processing**

Terraform automatically loads all `.tf` files in the current directory when you execute commands like `terraform init`, `terraform plan`, or `terraform apply`. Here’s how it works:

1. **File Loading**:
   - Terraform reads all `.tf` files in the directory **in no specific order**.
   - Filenames (e.g., `main.tf`, `variables.tf`) are purely for organizational purposes.

2. **Merging Configurations**:
   - Terraform combines all resources, providers, variables, and other blocks from the `.tf` files into a single configuration in memory.

3. **Best Practices**:
   - Use separate `.tf` files for better readability:
     - `terraform.tf` for provider and version configurations.
     - `main.tf` for resource definitions.
   - Keep all files in the same directory.

---

## **File Breakdown**

### 1. `terraform.tf`

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
  required_version = "~> 1.7"
}
```

- **Purpose**:
  - Configures Terraform to use the **Docker provider**.
  - Ensures compatibility with Terraform version `1.7.x`.

---

### 2. `main.tf`

```hcl
provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"
  ports {
    internal = 80
    external = 8000
  }
}
```

- **Purpose**:
  - Pulls the latest `nginx` Docker image.
  - Creates a container named `tutorial`.
  - Maps host port `8000` to container port `80`.

---

## **How to Run the Project**

### Step 1: Initialize Terraform
Run the following command to initialize the project and download the Docker provider plugin:

```bash
terraform init
```

### Step 2: Plan the Changes
Preview the resources Terraform will create:

```bash
terraform plan
```

### Step 3: Apply the Changes
Apply the configuration to create the Docker resources:

```bash
terraform apply
```

Confirm with `yes`.

### Step 4: Verify the Container
Check if the container is running:

```bash
docker ps
```

Access the NGINX web server:

```
http://localhost:8000
```

---

## **Destroying the Resources**

To remove the Docker container and image created by Terraform, run:

```bash
terraform destroy
```

Confirm with `yes`.

---

## **Troubleshooting**

- **Docker not installed**:
   - Install Docker and ensure it’s running:  
     ```bash
     docker --version
     systemctl status docker
     ```

- **Port conflict**:
   - If port `8000` is already in use, change the `external` port in `main.tf`:
     ```hcl
     ports {
       internal = 80
       external = 8080
     }
     ```

- **Terraform version error**:
   - Ensure Terraform version is `1.7.x`:
     ```bash
     terraform --version
     ```

---

## **What Happens Behind the Scenes?**

1. **`terraform init`**:
   - Downloads the required Docker provider.
2. **`terraform apply`**:
   - Pulls the `nginx:latest` image from Docker Hub.
   - Creates a container named `tutorial`.
   - Maps port `8000` on the host to port `80` in the container.
3. **Terraform & Docker**:
   - Terraform communicates with Docker via the Docker API.
   - It assumes Docker is installed and running.

---

## **Summary**

This project demonstrates how Terraform simplifies the lifecycle management of Docker containers:

1. Automatically pulling the NGINX Docker image.
2. Creating and configuring the container.
3. Managing resources using a declarative approach.

Let me know if you'd like to enhance or extend this setup! 🚀