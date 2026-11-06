# Enterprise Azure Hub-and-Spoke Network Architecture

[![Azure Network CI/CD Security & Deploy](https://github.com/YOUR_USERNAME/azure-hub-spoke-network/actions/workflows/network-deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/azure-hub-spoke-network/actions/workflows/network-deploy.yml)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.5.0%2B-purple.svg)](https://www.terraform.io/)
[![Cloud Adoption Framework](https://img.shields.io/badge/CAF-Compliant-blue.svg)](https://cloudadoption.microsoft.com/)

This repository contains an enterprise-grade, production-ready **Hub-and-Spoke networking topology** deployed on Microsoft Azure using **Terraform** and automated via **GitHub Actions CI/CD**. The architecture strictly follows the **Microsoft Cloud Adoption Framework (CAF)** and Zero Trust security principles.

---

## 🏗️ Architecture Overview

- **Connectivity Subscription (Hub VNet - `10.0.0.0/16`)**:
  - `AzureFirewallSubnet`: Hosts a centralized Standard Azure Firewall for traffic inspection.
  - `AzureBastionSubnet`: Reserved for secure management access.
- **Workload Subscription (Spoke Prod VNet - `10.1.0.0/16`)**:
  - `AppSubnet` & `DBSubnet`: Isolated application and database tiers.
- **Traffic Routing**:
  - **User Defined Routes (UDR)**: Forces all spoke outbound and inter-spoke traffic (`0.0.0.0/0`) through the central Azure Firewall.
  - **VNet Peering**: Hub-to-spoke bidirectional peering with forwarded traffic enabled.

---

## 📁 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── network-deploy.yml       # CI/CD pipeline (Lint, Security Scan, Apply)
└── terraform/
    ├── modules/
    │   ├── vnet/                    # Reusable Virtual Network & Subnet module
    │   └── firewall/                # Azure Firewall & UDR routing module
    └── environments/
        └── dev/
            ├── main.tf              # Environment entry point & remote backend
            ├── variables.tf
            └── outputs.tf

🚀 CI/CD Pipeline & Security
The GitHub Actions pipeline enforces a strict security and validation gate on every commit:

TFLint: Static code analysis for Terraform.
Checkov: Infrastructure-as-Code (IaC) security scanner (CIS Benchmarks / Azure Security Benchmark).
OIDC Authentication: Passwordless, short-lived token authentication with Azure (no stored client secrets).
Environment Promotion: terraform plan on PRs, automated terraform apply on pushes to main.