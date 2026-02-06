# Layer 00: CRD Bootstrap

Apply KubeBlocks CRDs once per cluster lifecycle.

## ⚠️ Warning

CRDs are cluster-scoped and **persistent**. Incorrect management can lead to data loss across all KubeBlocks clusters.

## Usage

```bash
cd terraform/00-crds
terraform init
terraform apply
```

## Upgrading CRDs

When `101_crds.yaml` changes (e.g., KubeBlocks upgrade):

```bash
terraform apply -var="crd_force_update=true"
```

## Safety

- `prevent_destroy` lifecycle prevents accidental deletion
- Server-side apply avoids field ownership conflicts
- Verification step ensures key CRDs are established
