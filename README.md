# Terraform with Docker: 

- Terraform as IaC: https://developer.hashicorp.com/terraform/tutorials/docker-get-started/infrastructure-as-code

Terraform works in a way that **it automatically loads all `.tf` files** in the **current working directory** when you run a command such as `terraform init`, `terraform plan`, or `terraform apply`.

Here's a breakdown of how Terraform processes the files:

---

### **How Terraform Processes Multiple `.tf` Files**
1. **File Loading**:  
   - Terraform reads all `.tf` files in the directory **in no particular order**.
   - The filenames (e.g., `main.tf`, `terraform.tf`, `variables.tf`) are just for organization and readability; Terraform treats them as a single configuration.

2. **Merging Configurations**:  
   - Terraform **combines** all resources, providers, variables, and other blocks from all `.tf` files into a single configuration in memory.
   - This allows you to split your configuration into multiple files for better organization.

3. **Why It Works**:  
   - `terraform.tf` defines **requirements** for Terraform, such as the **provider source and version**.
   - `main.tf` uses the provider defined in `terraform.tf` to declare resources (like `docker_image` and `docker_container`).

---

### **Example of the Workflow**

1. **Files in Directory**:
   ```
   terraform_with_docker/
   ├── main.tf
   └── terraform.tf
   ```

2. **When You Run `terraform init`**:
   - Terraform scans the directory.
   - It finds both `main.tf` and `terraform.tf`.
   - It reads and combines:
     - The **provider configuration** from `terraform.tf`.
     - The **resource definitions** from `main.tf`.

3. **End Result**:
   Terraform combines the two files into a single configuration internally. The provider settings (`kreuzwerker/docker`) are applied, and the resources (`docker_image` and `docker_container`) are created.

---

### **Best Practices**
- **Split Configuration for Readability**:
   - Use `terraform.tf` for **Terraform version and provider requirements**.
   - Use `main.tf` (or similar files like `resources.tf`, `outputs.tf`, `variables.tf`) for actual resource definitions.
- **Keep Files in the Same Directory**:
   - Terraform automatically processes all `.tf` files in the current directory.
- **Use Comments**:
   - Add comments to explain how different files contribute to the overall configuration.

---

### **Key Note**
If you delete or rename `terraform.tf`, Terraform won't have the provider configuration (`kreuzwerker/docker`) it needs, and it will fail when you run `terraform plan` or `terraform apply`. Both files are needed because they complement each other.

---

Let me know if you want an example of splitting files further or a deeper dive into Terraform's file loading behavior! 🚀