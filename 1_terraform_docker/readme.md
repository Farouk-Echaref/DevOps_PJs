# Terraform with Docker: Setting Up and Running an NGINX Container

This project demonstrates how to use **Terraform** with the **Docker provider** to automate creating a Docker container that runs the **NGINX web server**.

---

## **Prerequisites**

Before running this project, ensure the following tools are installed on your host system:

1. **Terraform** (version `~> 1.7`)
   - Install from [Terraform official downloads](https://developer.hashicorp.com/terraform/downloads).

   Verify installation:
   ```bash
   terraform --version
   ```

2. **Docker** (already installed and running on your host)
   - Install Docker by following the [Docker installation guide](https://docs.docker.com/get-docker/).

   Verify installation:
   ```bash
   docker --version
   docker ps
   ```

---

## **Project Structure**

The project contains the following files:

1. **`terraform.tf`**: Configures Terraform requirements, including the provider and version.
2. **`main.tf`**: Defines the resources Terraform will manage (Docker image and container).

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
  - Configures Terraform to use the **Docker provider** (`kreuzwerker/docker`).
  - Ensures compatibility with Terraform version `1.7.x`.

- **Key Details**:
  - `source`: Specifies the Docker provider location on the Terraform Registry.
  - `version`: Locks the provider to version `3.0.2` or compatible updates (`< 4.0.0`).
  - `required_version`: Ensures Terraform itself is version `1.7.x`.

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
  - Creates a Docker container named `tutorial` using that image.
  - Maps **port 8000** on the host to **port 80** inside the container.

- **Key Components**:
  - **`docker_image`**: Ensures the `nginx:latest` image is pulled from Docker Hub.
    - `keep_locally = false`: Removes the image if no containers are using it.
  - **`docker_container`**:
    - Starts a container based on the image.
    - Exposes NGINX on host port `8000` so it’s accessible via `http://localhost:8000`.

---

## **How to Run the Project**

### Step 1: Initialize Terraform
Run the following command to initialize the project. This downloads the Docker provider plugin locally.

```bash
terraform init
```

You should see output indicating the provider is being installed:
```
- Installing kreuzwerker/docker v3.0.2...
```

---

### Step 2: Plan the Changes
Preview the changes Terraform will make (what resources it will create).

```bash
terraform plan
```

Example output:
```
Plan: 2 to add, 0 to change, 0 to destroy.
```

---

### Step 3: Apply the Changes
Run Terraform to create the Docker resources (image and container).

```bash
terraform apply
```

When prompted, confirm with `yes`.

**Example Output**:
```
docker_image.nginx: Creating...
docker_container.nginx: Creating...
Apply complete! Resources: 2 added.
```

---

### Step 4: Verify the Container
Check if the container is running:

```bash
docker ps
```

You should see something like this:
```
CONTAINER ID   IMAGE          COMMAND                  PORTS                  NAMES
1234567890ab   nginx:latest   "nginx -g 'daemon of…"   0.0.0.0:8000->80/tcp   tutorial
```

Access the NGINX web server by visiting:

```
http://localhost:8000
```

---

## **Destroying the Resources**

To remove the Docker container and image created by Terraform, run:

```bash
terraform destroy
```

Confirm with `yes`. Terraform will clean up all resources it managed.

---

## **What Happens Behind the Scenes?**

1. **`terraform init`**:
   - Downloads the required Docker provider (`kreuzwerker/docker` version 3.0.2).
2. **`terraform apply`**:
   - Pulls the `nginx:latest` image from Docker Hub.
   - Creates a container named `tutorial`.
   - Maps port `8000` on the host to port `80` in the container.
3. **Docker Integration**:
   - Terraform communicates with Docker via the **Docker API**.
   - Terraform **does not install Docker**; it assumes Docker is already installed.

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

## **Summary**

This project automates the following:
1. Pulling the latest NGINX Docker image.
2. Creating a Docker container named `tutorial`.
3. Mapping host port `8000` to container port `80`.

You can manage the container lifecycle (create, update, destroy) easily using Terraform commands.

