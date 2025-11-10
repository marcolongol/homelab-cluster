# 🏠 Homelab Kubernetes Cluster

Welcome to my personal homelab Kubernetes cluster repository! This is a production-grade, GitOps-driven Kubernetes setup running on bare-metal with Talos Linux, managing my self-hosted applications and infrastructure.

## 📋 Overview

This repository contains the complete infrastructure-as-code for my homelab Kubernetes cluster. Everything is managed declaratively through Git, automatically synchronized via Flux CD, with secrets encrypted using SOPS and age.

**Cluster Details:**
- **Nodes**: 3 control plane nodes (all capable of running workloads)
- **OS**: Talos Linux v1.11.5
- **Kubernetes**: v1.34.1
- **CNI**: Cilium v1.17.6 (eBPF-based networking)

## ✨ Features

- **GitOps Workflow**: Flux CD automatically syncs cluster state from this Git repository
- **Encrypted Secrets**: All secrets encrypted with SOPS and age encryption
- **Immutable OS**: Talos Linux provides a secure, minimal attack surface
- **High Availability**: 3-node control plane with virtual IP for API endpoint
- **Automated Updates**: Renovate bot keeps dependencies up-to-date
- **Split DNS**: Internal and external DNS with k8s-gateway and external-dns
- **Secure Remote Access**: Cloudflare Tunnel for safe external access
- **Comprehensive Monitoring**: Prometheus and Grafana for observability
- **Distributed Storage**: OpenEBS Mayastor for high-performance replicated storage

## 🗂️ Repository Structure

```
.
├── kubernetes/
│   ├── flux/              # Flux GitOps configuration
│   │   ├── cluster/       # Main Kustomizations (meta, infra, apps)
│   │   └── meta/          # Helm/OCI repositories
│   ├── infra/             # Infrastructure components
│   │   ├── cert-manager/  # TLS certificate management
│   │   ├── external-secrets/ # 1Password integration
│   │   ├── kube-system/   # Core system services (Cilium, CoreDNS, etc.)
│   │   ├── network/       # Ingress controllers, DNS, Cloudflare Tunnel
│   │   ├── storage/       # OpenEBS, NFS drivers, Volsync
│   │   └── observability/ # Prometheus, Grafana monitoring
│   ├── apps/              # User applications
│   │   ├── default/       # Main apps (Minecraft, Paperless, Nexus, etc.)
│   │   ├── authelia/      # Authentication server
│   │   └── cloudnative-pg/ # PostgreSQL operator
│   └── components/        # Reusable Kustomize components
├── talos/                 # Talos Linux configuration
│   ├── patches/           # Talos node patches (global & controller)
│   └── talconfig.yaml     # Node definitions
├── bootstrap/             # Initial cluster bootstrap (Helmfile)
├── scripts/               # Automation scripts
└── .taskfiles/            # Task definitions for operations
```

## 🛠️ Tech Stack

### Core Infrastructure
- **[Talos Linux](https://www.talos.dev/)** - Immutable Kubernetes OS
- **[Flux](https://fluxcd.io/)** - GitOps continuous delivery
- **[Cilium](https://cilium.io/)** - eBPF-based networking and security
- **[cert-manager](https://cert-manager.io/)** - Automated TLS certificates
- **[SOPS](https://github.com/getsops/sops)** - Encrypted secrets management

### Storage
- **[OpenEBS Mayastor](https://openebs.io/)** - High-performance distributed storage
- **[csi-driver-nfs](https://github.com/kubernetes-csi/csi-driver-nfs)** - NFS persistent volumes
- **[Volsync](https://volsync.readthedocs.io/)** - PVC backup and replication

### Networking & Access
- **[ingress-nginx](https://kubernetes.github.io/ingress-nginx/)** - Internal and external ingress
- **[k8s-gateway](https://github.com/ori-edge/k8s_gateway)** - Internal DNS for services
- **[external-dns](https://github.com/kubernetes-sigs/external-dns)** - Cloudflare DNS automation
- **[Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/)** - Secure external access

### Security
- **[Authelia](https://www.authelia.com/)** - Authentication and authorization
- **[External Secrets](https://external-secrets.io/)** - 1Password integration
- **Age encryption** - SOPS encryption backend

### Monitoring
- **[Prometheus](https://prometheus.io/)** - Metrics collection
- **[Grafana](https://grafana.com/)** - Visualization dashboards
- **[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)** - Alert routing

### Development Tools
- **[mise](https://mise.jdx.dev/)** - Tool version management
- **[Task](https://taskfile.dev/)** - Task automation
- **[Renovate](https://www.mend.io/renovate)** - Dependency automation

## 📦 Deployed Applications

- **[Paperless-NGX](https://github.com/paperless-ngx/paperless-ngx)** - Document management system
- **[Minecraft Server](https://www.minecraft.net/)** - Multiplayer game server
- **[Nexus3](https://www.sonatype.com/products/nexus-repository)** - Repository manager
- **[Actual Budget](https://actualbudget.org/)** - Personal finance tracking
- **[OrcaSlicer](https://github.com/SoftFever/OrcaSlicer)** - 3D printing slicer
- **[FreeCAD](https://www.freecad.org/)** - CAD modeling application
- **[Authelia](https://www.authelia.com/)** - SSO authentication server
- **[CloudNative-PG](https://cloudnative-pg.io/)** - PostgreSQL operator for databases

## 🚀 Getting Started

### Prerequisites

- 3 bare-metal nodes or VMs (minimum 4 cores, 16GB RAM, 256GB disk each)
- A Cloudflare account with a domain
- Basic knowledge of Kubernetes, Git, and YAML

### Setup

1. **Install tools** using mise:
   ```bash
   mise trust
   pip install pipx
   mise install
   ```

2. **Initialize configuration**:
   ```bash
   task init
   ```

3. **Configure your cluster** by editing `cluster.yaml` and `nodes.yaml`

4. **Template configuration files**:
   ```bash
   task configure
   ```

5. **Bootstrap Talos and Kubernetes**:
   ```bash
   task bootstrap:talos
   task bootstrap:apps
   ```

6. **Watch your cluster come online**:
   ```bash
   kubectl get pods --all-namespaces --watch
   ```

## 🔧 Common Operations

### Cluster Management
```bash
# Force Flux to sync from Git
task reconcile

# Check Flux status
flux check
flux get ks -A
flux get hr -A

# Check Cilium status
cilium status
```

### Talos Operations
```bash
# Apply configuration to a node
task talos:apply-node IP=10.0.10.10

# Upgrade Talos on a node
task talos:upgrade-node IP=10.0.10.10

# Upgrade Kubernetes version
task talos:upgrade-k8s

# Reset cluster (use with caution!)
task talos:reset
```

## 🔐 Secrets Management

All secrets are encrypted using SOPS with age encryption before being committed to Git. The private age key is stored locally at `./age.key` and never committed.

- **Cluster secrets**: `kubernetes/components/common/cluster-secrets.sops.yaml`
- **External secrets**: Synced from 1Password via External Secrets Operator
- **Encryption**: Only `data` and `stringData` fields are encrypted; metadata remains visible

## 🤖 Automation

### GitOps with Flux
Flux continuously monitors this Git repository and automatically applies changes to the cluster. The reconciliation hierarchy:

1. **cluster-meta** - Helm/OCI repositories and Git sources
2. **cluster-infra** - Infrastructure components (depends on meta)
3. **cluster-apps** - Applications (depends on infra)

### Dependency Updates with Renovate
Renovate automatically creates pull requests for:
- Container image updates (Docker, Helm charts)
- Kubernetes manifests
- GitHub Actions
- Tool versions

Auto-merge is enabled for patch and minor updates after a 3-day hold period.

### GitHub Actions
- **Renovate**: Runs hourly to check for dependency updates
- **Flux-Local**: Validates and previews changes in pull requests
- **Label Sync**: Manages repository labels

## 📊 Monitoring

Access Grafana dashboards for:
- Cluster health and resource usage
- Cilium network metrics
- OpenEBS storage performance
- Application-specific metrics
- Prometheus alerts

## 🌐 DNS Configuration

### Internal DNS (Home Network)
Configure your home DNS server to forward queries for your domain to the k8s-gateway IP. This enables accessing services via friendly DNS names on your local network.

### External DNS (Internet)
external-dns automatically creates Cloudflare DNS records for services with the `external` ingress class. Cloudflare Tunnel provides secure access without exposing ports.

## 🙏 Acknowledgments

This repository is based on the excellent [onedr0p/cluster-template](https://github.com/onedr0p/cluster-template). Huge thanks to the Home Operations community for their guidance and inspiration!

## 📄 License

This repository is available for reference and learning purposes. Feel free to learn from it and adapt it to your own needs!

---

**Built with** ❤️ **using GitOps principles**
