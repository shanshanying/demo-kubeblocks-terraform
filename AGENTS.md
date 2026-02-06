# KubeBlocks Terraform Deployment

## Project Overview

This is a Terraform-based infrastructure-as-code project for deploying [KubeBlocks](https://kubeblocks.io/) on Kubernetes clusters. KubeBlocks is an open-source database platform that enables users to run and manage multiple databases on Kubernetes.

The project uses a layered architecture to separate concerns by change frequency and data safety requirements:

| Layer | Directory | Purpose | Change Frequency | Destroy Safe |
|-------|-----------|---------|------------------|--------------|
| 00 | `00-crds/` | CRD Bootstrap | Rarely | **NO** - Data loss risk |
| 10 | `10-kubeblocks/` | Platform + Addons | Occasionally | Yes |
| 20 | `20-clusters/` | Database Clusters | Frequently | Yes |

## Technology Stack

- **Infrastructure as Code**: Terraform >= 1.5.0
- **Target Platform**: Kubernetes (any compliant cluster)
- **Package Management**: Helm 3.x
- **Terraform Providers**:
  - `hashicorp/helm` ~> 2.13 (Helm deployments)
  - `hashicorp/kubernetes` ~> 2.25 (K8s resource management)
  - `hashicorp/null` ~> 3.2 (CRD provisioning)

## Project Structure

```
.
├── 00-crds/              # Layer 00: Custom Resource Definitions
│   ├── main.tf           # CRD application using kubectl
│   ├── variables.tf      # CRD file path and force update options
│   ├── outputs.tf        # CRD hash and verification status
│   ├── terraform.tfvars  # Active configuration
│   └── README.md         # Layer-specific documentation
├── 10-kubeblocks/        # Layer 10: KubeBlocks Platform
│   ├── main.tf           # Helm release for KubeBlocks + addons
│   ├── variables.tf      # Repository, version, addon configurations
│   ├── outputs.tf        # Installed addons and platform status
│   ├── terraform.tfvars  # Active configuration
│   └── README.md         # Layer-specific documentation
├── 20-clusters/          # Layer 20: Database Clusters
│   ├── main.tf           # Helm releases for database clusters
│   ├── variables.tf      # Cluster definitions map
│   ├── outputs.tf        # Deployed cluster info and kubectl commands
│   ├── terraform.tfvars  # Active configuration
│   └── README.md         # Layer-specific documentation
├── data/                 # Static data files
│   ├── 101_crds.yaml     # KubeBlocks CRD definitions
│   └── kb-values.yaml    # Default KubeBlocks Helm values
├── kb-values.yaml        # Project-level KubeBlocks values override
├── .gitignore            # Terraform ignore patterns
└── README.md             # Project documentation
```

## Deployment Modes

The project supports two deployment modes for each layer:

### 1. Remote Helm Repository (Production)

Uses published Helm charts from ApeCloud's repository:

```hcl
# 10-kubeblocks/terraform.tfvars
kubeblocks_repository     = "https://apecloud.github.io/helm-charts"
kubeblocks_chart_version  = "1.0.1"
addons_repository         = "https://apecloud.github.io/helm-charts"

# 20-clusters/terraform.tfvars
clusters_repository = "https://apecloud.github.io/helm-charts"
```

### 2. Local Chart Path (Development)

Uses locally cloned chart repositories:

```hcl
# Leave *_repository empty to use local paths
kubeblocks_repository = ""
kubeblocks_chart_path = "../../kubeblocks"
addons_repository     = ""
addons_path           = "../../addons"
```

## Build and Deployment Commands

### Prerequisites

- Terraform >= 1.5.0 installed
- `kubectl` configured with access to target cluster
- Helm 3.x (for local development mode)

### Deployment Workflow

Deploy layers in order (00 → 10 → 20):

```bash
# 1. Bootstrap CRDs (once per cluster, rarely changes)
cd 00-crds
cp terraform.tfvars.example terraform.tfvars  # If not exists
terraform init
terraform apply

# 2. Install KubeBlocks Platform
cd 10-kubeblocks
cp terraform.tfvars.example terraform.tfvars  # Edit to configure
terraform init
terraform apply

# 3. Deploy Database Clusters
cd 20-clusters
cp terraform.tfvars.example terraform.tfvars  # Define your clusters
terraform init
terraform apply
```

### Upgrading CRDs

When upgrading KubeBlocks versions that include CRD changes:

```bash
cd 00-crds
terraform apply -var="crd_force_update=true"
```

### Destroying Resources

**WARNING**: Never destroy Layer 00 (CRDs) unless you intend to delete all database data.

```bash
# Safe to destroy (clusters only)
cd 20-clusters
terraform destroy

# Safe to destroy (platform, but will affect running clusters)
cd 10-kubeblocks
terraform destroy

# DANGEROUS: Only destroy CRDs when absolutely necessary
cd 00-crds
terraform destroy  # Has prevent_destroy lifecycle - may require state manipulation
```

## Configuration Reference

### Layer 00: CRD Bootstrap

**Key Variables** (`variables.tf`):
- `crds_file_path` - Path to CRD YAML file (default: `"../data/101_crds.yaml"`)
- `crd_force_update` - Force re-application for upgrades (default: `false`)

**Safety Features**:
- `prevent_destroy` lifecycle prevents accidental CRD deletion
- Verification step checks key CRDs are established

### Layer 10: KubeBlocks Platform

**Key Variables** (`variables.tf`):
- `kubeblocks_repository` - Helm repo URL (empty for local path)
- `kubeblocks_chart_path` - Local chart path (default: `"../../kubeblocks"`)
- `kubeblocks_chart_version` - Chart version constraint
- `kubeblocks_namespace` - Target namespace (default: `"kb-system"`)
- `kubeblocks_values_file` - Custom values file path
- `image_registry` - Container registry (default: `"docker.io"`)
- `addons_repository` - Addons Helm repo URL
- `addons_path` - Local addons path (default: `"../../addons"`)
- `addons` - List of addon configurations

**Addon Configuration Example**:
```hcl
addons = [
  {
    name          = "mysql"
    enabled       = true
    chart_version = "1.0.1"
    keep_resource = true
    values = {
      image = {
        registry   = "apecloud-registry.cn-zhangjiakou.cr.aliyuncs.com"
        repository = "apecloud/mysql"
      }
    }
  }
]
```

### Layer 20: Database Clusters

**Key Variables** (`variables.tf`):
- `clusters_repository` - Helm repo for cluster charts
- `addons_cluster_path` - Local path to cluster charts (default: `"../../addons-cluster"`)
- `clusters` - Map of cluster definitions

**Cluster Configuration Example**:
```hcl
clusters = {
  mysql-prod = {
    name               = "mysql-prod"
    engine             = "mysql"
    namespace          = "prod"
    version            = "8.0.39"
    replicas           = 2
    cpu                = 2
    memory             = 4
    storage            = 20
    chart_version      = "1.0.1"
    topology           = "semisync"
    termination_policy = "WipeOut"
    enabled            = true
  }
}
```

**Cluster Parameters**:
- `name` - Cluster name
- `engine` - Database engine (mysql, postgresql, redis, etc.)
- `namespace` - Target Kubernetes namespace
- `version` - Database version
- `replicas` - Number of replicas
- `cpu`/`memory`/`storage` - Resource specifications
- `topology` - Cluster topology (e.g., "semisync" for MySQL)
- `termination_policy` - Data retention policy ("Delete", "WipeOut", "Halt", "DoNotTerminate")

## Code Style Guidelines

### Terraform Conventions

1. **File Organization**: Each layer follows the standard Terraform file structure:
   - `main.tf` - Resources and data sources
   - `variables.tf` - Input variables with descriptions and types
   - `outputs.tf` - Output values
   - `terraform.tfvars` - Active configuration (gitignored, create from examples)
   - `README.md` - Layer-specific documentation

2. **Resource Naming**: Use descriptive names that indicate purpose:
   - `helm_release.kubeblocks` - Main platform release
   - `helm_release.addons` - Addons (using `for_each`)
   - `helm_release.clusters` - Database clusters (using `for_each`)
   - `null_resource.crds` - CRD provisioning

3. **Variable Definitions**: Always include:
   - Descriptive `description`
   - Explicit `type`
   - Sensible `default` values where appropriate

4. **Comments**: Use section headers and inline comments:
   ```hcl
   # Layer 10: KubeBlocks Platform
   # Depends on: Layer 00 (CRDs)
   ```

### Helm Values Files

The project includes a comprehensive KubeBlocks values file (`kb-values.yaml`) with:
- Image registry and repository configuration
- Resource limits and requests
- Node affinity and tolerations for controller/data plane separation
- Data protection and backup settings
- RBAC configuration
- Feature gates

## Testing and Verification

### Post-Deployment Verification

After deploying Layer 00:
```bash
kubectl get crd | grep kubeblocks
kubectl wait --for condition=established --timeout=120s crd/componentdefinitions.apps.kubeblocks.io
```

After deploying Layer 10:
```bash
kubectl get pods -n kb-system
kubectl get cmpd -n kb-system  # Check ComponentDefinitions
```

After deploying Layer 20:
```bash
kubectl get cluster -A
kubectl get pods -n <cluster-namespace> -l app.kubernetes.io/instance=<cluster-name>
```

### Validation Commands

Each layer provides useful outputs:
```bash
# Layer 10 outputs
terraform output platform_status
terraform output installed_addons

# Layer 20 outputs
terraform output cluster_info
terraform output kubectl_commands
```

## Security Considerations

1. **CRD Protection**: Layer 00 has `prevent_destroy` lifecycle to prevent accidental data loss
2. **RBAC**: KubeBlocks creates service accounts and roles for cluster management
3. **Image Registries**: Configure private registries via `image_registry` variable
4. **Termination Policies**: Use appropriate policies to prevent accidental data deletion:
   - `Delete` - Deletes PVCs but keeps backups
   - `WipeOut` - Deletes everything including backups
   - `Halt` - Stops cluster but keeps all resources
   - `DoNotTerminate` - Prevents any deletion

5. **Data Protection**:
   - Custom encryption keys recommended for backups
   - Backup repositories can be configured with object storage

## Common Operations

### Scale a Cluster

Edit `20-clusters/terraform.tfvars` and change `replicas`, then:
```bash
cd 20-clusters && terraform apply
```

### Disable a Cluster

Set `enabled = false` in cluster definition, then apply.

### Add an Addon

Edit `10-kubeblocks/terraform.tfvars` and add to `addons` list, then apply.

### Upgrade KubeBlocks

1. Update chart version in `10-kubeblocks/terraform.tfvars`
2. If CRD changes: `cd 00-crds && terraform apply -var="crd_force_update=true"`
3. `cd 10-kubeblocks && terraform apply`

## Troubleshooting

### CRD Not Established

If CRDs fail to apply:
```bash
kubectl get crd -w  # Watch CRD status
kubectl describe crd <crd-name>  # Check for errors
```

### Helm Release Failed

Check Helm release status:
```bash
helm list -n kb-system
helm history <release-name> -n kb-system
helm rollback <release-name> <revision> -n kb-system
```

### Provider Authentication

Ensure `kubectl` context is correct:
```bash
kubectl config current-context
export KUBECONFIG=/path/to/kubeconfig
```

## Additional Resources

- [KubeBlocks Documentation](https://kubeblocks.io/docs/)
- [ApeCloud Helm Charts](https://github.com/apecloud/helm-charts)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
