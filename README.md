# KubeBlocks Terraform Deployment

Layered Terraform architecture for deploying KubeBlocks and database clusters.

## Architecture

```
Layer 00: CRD Bootstrap      (Rarely changes)  - Custom Resource Definitions
Layer 10: KubeBlocks Platform (Occasionally)    - Core operator + Addons
Layer 20: Database Clusters  (Frequently)       - Actual database instances
```

## Deployment Modes

### Remote Helm Repository (Production)

```hcl
# 10-kubeblocks/terraform.tfvars
kubeblocks_repository = "https://apecloud.github.io/helm-charts"
kubeblocks_chart_version = "1.0.1"

addons_repository = "https://apecloud.github.io/helm-charts"

# 20-clusters/terraform.tfvars
clusters_repository = "https://apecloud.github.io/helm-charts"
```

### Local Chart Path (Development)

```hcl
# Leave *_repository empty to use local paths
kubeblocks_repository = ""
kubeblocks_chart_path = "../../kubeblocks"
```

## Quick Start

```bash
# 1. Bootstrap CRDs (once per cluster)
cd 00-crds && terraform init && terraform apply

# 2. Install Platform
cd 10-kubeblocks
cp terraform.tfvars.example terraform.tfvars
# Edit to add repository URLs and enable addons
terraform init && terraform apply

# 3. Deploy Clusters
cd 20-clusters
cp terraform.tfvars.example terraform.tfvars
# Edit to define clusters
terraform init && terraform apply
```

## Layer Details

| Layer | Contents | Change Frequency | Destroy Safe? |
|-------|----------|------------------|---------------|
| 00-crds | CRDs | Rarely | **NO** - Data loss risk |
| 10-kubeblocks | Platform + Addons | Occasionally | Yes |
| 20-clusters | Database clusters | Frequently | Yes |

## Directory Structure

```
terraform/
├── 00-crds/              # CRD bootstrap
├── 10-kubeblocks/        # Platform + addons
├── 20-clusters/          # Database clusters
├── deprecated/           # Old monolithic files
├── .gitignore            # Terraform ignore patterns
├── MIGRATION.md          # Migration guide
└── README.md             # This file
```

## Safety Features

- **CRD Protection**: `prevent_destroy` lifecycle prevents accidental CRD deletion
- **Layer Independence**: Destroying clusters won't affect platform or CRDs
- **Version Pinning**: Support for chart version constraints
