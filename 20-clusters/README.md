# Layer 20: Database Clusters

Deploy and manage actual database clusters.

## Deployment Modes

### 1. Remote Helm Repository (Production)

```hcl
clusters_repository = "https://apecloud.github.io/helm-charts"
```

### 2. Local Chart Path (Development)

```hcl
clusters_repository = ""  # Use local path
addons_cluster_path = "../../addons-cluster"
```

## Usage

```bash
cd terraform/20-clusters
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to define your clusters
terraform init
terraform apply
```

## Defining Clusters

```hcl
clusters = {
  my-mysql = {
    name               = "my-mysql"
    engine             = "mysql"
    namespace          = "demo"
    version            = "8.0.39"
    replicas           = 2
    cpu                = 0.5
    memory             = 0.5
    storage            = 20
    chart_version      = "1.0.1"  # Optional
    topology           = "semisync"
    termination_policy = "Delete"
    enabled            = true
  }
}
```

## Operations

- **Scale**: Change `replicas` and run `terraform apply`
- **Disable**: Set `enabled = false` and run `terraform apply`
- **Destroy**: `terraform destroy` (platform remains intact)
