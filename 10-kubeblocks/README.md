# Layer 10: KubeBlocks Platform

Install and manage the KubeBlocks platform and its addons.

## Deployment Modes

### 1. Remote Helm Repository (Production)

```hcl
kubeblocks_repository = "https://apecloud.github.io/helm-charts"
kubeblocks_chart_version = "1.0.1"
addons_repository = "https://apecloud.github.io/helm-charts"
```

### 2. Local Chart Path (Development)

```hcl
# Leave repository URLs empty
kubeblocks_repository = ""
kubeblocks_chart_path = "../../kubeblocks"
```

## Usage

```bash
cd terraform/10-kubeblocks
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform apply
```

## Managing Addons

```hcl
addons = [
  {
    name          = "mysql"
    enabled       = true
    chart_version = "1.0.1"  # Optional: pin version
    keep_resource = true
    values        = {}
  }
]
```
