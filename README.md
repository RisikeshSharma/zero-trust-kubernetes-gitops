# ☸️ Zero-Trust Kubernetes GitOps

[![GitOps CI](https://github.com/RisikeshSharma/zero-trust-kubernetes-gitops/actions/workflows/ci.yml/badge.svg)](https://github.com/RisikeshSharma/zero-trust-kubernetes-gitops/actions)
[![Cilium eBPF](https://img.shields.io/badge/Cilium-eBPF_Security-f59e0b?style=flat&logo=cilium)](https://cilium.io)
[![Argo CD](https://img.shields.io/badge/ArgoCD-GitOps_Sync-orange?style=flat&logo=argo)](https://argo-cd.readthedocs.io)

Hardened Multi-Tenant Kubernetes (AKS) cluster architecture driven strictly by **ArgoCD GitOps pipelines**, **Cilium eBPF network security**, **HashiCorp Vault** secret injection, and **Open Policy Agent (OPA) Gatekeeper**.

---

## 🛡️ Architecture & Security Mesh

```mermaid
flowchart TD
    subgraph GitOps["GitOps Automation"]
        GitRepo[Git Repository\nDeclarative Manifests] --> ArgoCD[Argo CD Controller]
    end

    subgraph Cluster["Zero-Trust Kubernetes Runtime"]
        ArgoCD -->|Sync State| K8s[AKS Cluster]
        OPA[OPA Gatekeeper Admission Controller] -->|Enforce Policies| K8s
        Cilium[Cilium eBPF Data Plane] -->|Default-Deny L3/L4/L7| K8s
        Vault[External Secrets Operator] -->|Inject Secrets| K8s
    end

    subgraph Security["Supply Chain Security"]
        Trivy[Trivy Vulnerability Scan] --> GitRepo
        Cosign[Sigstore Cosign Signature Gate] --> OPA
    end
```

---

## ⚡ Key Engineering Patterns

* **Cilium eBPF Network Security ([`cilium-policies/`](./cilium-policies)):** Default-deny network security policies with DNS-aware egress whitelisting.
* **OPA Gatekeeper ([`gatekeeper/`](./gatekeeper)):** Restricts root containers, requires read-only root filesystems, and enforces image digest verification.
* **Vault Integration ([`vault-external-secrets/`](./vault-external-secrets)):** External Secrets Operator syncs ephemeral dynamic credentials into Kubernetes Secrets.
* **Terraform Modular Engine ([`terraform/`](./terraform/)):**
  * `for_each`: Multi-tenant secondary node pools with dedicated taints and labels.
  * `dynamic "upgrade_settings"`: Enforces zero-downtime rolling upgrades with custom surge capacity.
  * Conditional iteration: Key Vault CSI rotation and Azure CNI with Cilium data plane.

---

## 👤 Author

**Rishikesh Sharma**  
Senior DevSecOps Engineer & Cloud Solutions Architect  
[GitHub Profile](https://github.com/RisikeshSharma) · [LinkedIn](https://linkedin.com)
