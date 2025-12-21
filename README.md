# 🚀 Code-Keeper - DevOps CI/CD Pipeline Project

**Project**: Complete CI/CD Pipeline for Microservices Architecture
**Technologies**: GitLab CI/CD, Ansible, Terraform, Docker, Kubernetes
**Environments**: Staging + Production
**Cloud Provider**: AWS

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Pipelines](#pipelines)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Audit Preparation](#audit-preparation)

---

## 🎯 Overview

**Code-Keeper** is a complete DevOps project that implements industry best practices for:
- **Continuous Integration (CI)**: Build, Test, Scan, Containerize
- **Continuous Deployment (CD)**: Deploy to Staging → Manual Approval → Deploy to Production
- **Infrastructure as Code (IaC)**: Terraform for AWS infrastructure
- **Configuration Management**: Ansible for GitLab deployment
- **Security**: Vulnerability scanning, secret management, least privilege

### Applications

This project includes **3 microservices**:

1. **Inventory App** - Manages product inventory
   - Connected to PostgreSQL database
   - RESTful API

2. **Billing App** - Processes orders and billing
   - Connected to PostgreSQL database
   - Consumes RabbitMQ messages

3. **API Gateway** - Single entry point for all requests
   - Routes requests to microservices
   - Load balancing

### Repositories

The project is split into **4 repositories**:
- `inventory-app/` - Inventory microservice + CI/CD pipeline
- `billing-app/` - Billing microservice + CI/CD pipeline
- `api-gateway/` - API Gateway + CI/CD pipeline
- `infrastructure/` - Terraform IaC + Infrastructure pipeline

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         GITLAB CI/CD                            │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Inventory    │  │ Billing      │  │ API Gateway  │         │
│  │ Repository   │  │ Repository   │  │ Repository   │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                  │                  │                 │
│         ├──────────────────┴──────────────────┤                 │
│         │         CI Pipeline (Each Repo)     │                 │
│         │  Build → Test → Scan → Containerize │                 │
│         └──────────────────┬──────────────────┘                 │
│                            │                                     │
│         ┌──────────────────┴──────────────────┐                 │
│         │         CD Pipeline (Each Repo)     │                 │
│         │  Deploy Staging → Approval → Prod   │                 │
│         └──────────────────┬──────────────────┘                 │
└────────────────────────────┼──────────────────────────────────┘
                             │
         ┌───────────────────┴───────────────────┐
         │    Infrastructure Repository          │
         │  Init → Validate → Plan → Apply       │
         └───────────────────┬───────────────────┘
                             │
         ┌───────────────────┴───────────────────┐
         │                                       │
    ┌────▼────────┐                    ┌────────▼─────┐
    │  STAGING    │                    │  PRODUCTION  │
    │ Environment │                    │ Environment  │
    │             │                    │              │
    │ ┌─────────┐ │                    │ ┌─────────┐  │
    │ │EKS      │ │                    │ │EKS      │  │
    │ │Cluster  │ │                    │ │Cluster  │  │
    │ │         │ │                    │ │         │  │
    │ │ - API   │ │                    │ │ - API   │  │
    │ │ - Inv   │ │                    │ │ - Inv   │  │
    │ │ - Bill  │ │                    │ │ - Bill  │  │
    │ └─────────┘ │                    │ └─────────┘  │
    │             │                    │              │
    │ ┌─────────┐ │                    │ ┌─────────┐  │
    │ │RDS x2   │ │                    │ │RDS x2   │  │
    │ │RabbitMQ │ │                    │ │RabbitMQ │  │
    │ └─────────┘ │                    │ └─────────┘  │
    └─────────────┘                    └──────────────┘
```

---

## 📦 Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **GitLab** | Latest | CI/CD Platform |
| **Ansible** | >= 2.9 | GitLab deployment |
| **Terraform** | >= 1.6.0 | Infrastructure provisioning |
| **Docker** | >= 20.x | Containerization |
| **kubectl** | >= 1.28 | Kubernetes management |
| **AWS CLI** | >= 2.x | AWS operations |

### Cloud Provider

- **AWS Account** with AdministratorAccess or equivalent
- **AWS credentials** configured
- **Budget**: ~$400-500/mois for 2 environments

### Knowledge Prerequisites

- GitLab CI/CD syntax
- Ansible playbooks
- Terraform modules
- Docker & Kubernetes basics
- AWS services (EKS, RDS, EC2)

---

## 📁 Project Structure

```
code-keeper/
├── README.md                           # This file
├── AUDIT_PREPARATION.md                # Audit Q&A guide
│
├── ansible/                            # Ansible for GitLab deployment
│   ├── playbooks/
│   │   ├── deploy-gitlab.yml           # Main playbook
│   │   ├── configure-runners.yml       # Runners setup
│   │   └── inventory/
│   │       └── hosts.yml               # Inventory file
│   └── roles/
│       ├── gitlab/                     # GitLab installation role
│       │   ├── tasks/main.yml
│       │   ├── templates/gitlab.rb.j2
│       │   ├── handlers/main.yml
│       │   └── defaults/main.yml
│       └── runners/                    # Runners installation role
│           ├── tasks/main.yml
│           ├── templates/config.toml.j2
│           └── defaults/main.yml
│
├── repositories/                       # 4 separate repositories
│   ├── inventory-app/
│   │   ├── .gitlab-ci.yml              # CI/CD pipeline
│   │   ├── Dockerfile                  # Multi-stage build
│   │   ├── src/                        # Application code
│   │   │   ├── server.js
│   │   │   ├── routes/
│   │   │   └── models/
│   │   ├── tests/                      # Unit & integration tests
│   │   ├── k8s/                        # Kubernetes manifests
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   └── configmap.yaml
│   │   └── README.md
│   │
│   ├── billing-app/
│   │   ├── .gitlab-ci.yml
│   │   ├── Dockerfile
│   │   ├── src/
│   │   ├── tests/
│   │   ├── k8s/
│   │   └── README.md
│   │
│   ├── api-gateway/
│   │   ├── .gitlab-ci.yml
│   │   ├── Dockerfile
│   │   ├── src/
│   │   ├── tests/
│   │   ├── k8s/
│   │   └── README.md
│   │
│   └── infrastructure/
│       ├── .gitlab-ci.yml              # Infrastructure pipeline
│       ├── terraform/
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── backend.tf
│       │   ├── modules/                # Terraform modules
│       │   │   ├── vpc/
│       │   │   ├── eks/
│       │   │   ├── rds/
│       │   │   └── mq/
│       │   └── environments/
│       │       ├── staging/
│       │       │   └── terraform.tfvars
│       │       └── production/
│       │           └── terraform.tfvars
│       └── README.md
│
├── scripts/                            # Utility scripts
│   ├── setup-gitlab.sh                 # GitLab setup automation
│   ├── deploy-infrastructure.sh        # Infrastructure deployment
│   ├── create-secrets.sh               # Secret management
│   └── test-pipelines.sh               # Pipeline testing
│
└── docs/                               # Additional documentation
    ├── ARCHITECTURE.md                 # Architecture details
    ├── PIPELINES.md                    # Pipeline explanations
    ├── SECURITY.md                     # Security guidelines
    └── TROUBLESHOOTING.md              # Common issues
```

---

## 🚀 Quick Start

### Step 1: Deploy GitLab with Ansible

```bash
# Navigate to ansible directory
cd ansible/

# Update inventory with your server IP
nano playbooks/inventory/hosts.yml

# Deploy GitLab
ansible-playbook playbooks/deploy-gitlab.yml -i playbooks/inventory/hosts.yml

# Configure Runners
ansible-playbook playbooks/configure-runners.yml -i playbooks/inventory/hosts.yml

# Verify GitLab is running
systemctl status gitlab-runsvdir
```

### Step 2: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
```

### Step 3: Deploy Infrastructure

```bash
# Navigate to infrastructure repository
cd repositories/infrastructure/terraform/

# Initialize Terraform
terraform init

# Deploy Staging Environment
terraform workspace new staging
terraform plan -var-file="environments/staging/terraform.tfvars"
terraform apply -var-file="environments/staging/terraform.tfvars"

# Deploy Production Environment
terraform workspace new production
terraform plan -var-file="environments/production/terraform.tfvars"
terraform apply -var-file="environments/production/terraform.tfvars"
```

### Step 4: Push Code to GitLab

```bash
# For each repository (inventory, billing, api-gateway, infrastructure)
cd repositories/inventory-app/

# Initialize git and push
git init
git remote add origin http://your-gitlab-ip/your-group/inventory-app.git
git add .
git commit -m "Initial commit"
git push -u origin main
```

### Step 5: Verify Pipelines

1. Go to GitLab UI: `http://your-gitlab-ip`
2. Navigate to each repository
3. Check CI/CD > Pipelines
4. Verify all stages pass

---

## 🔧 Detailed Setup

### 1. GitLab Deployment with Ansible

#### 1.1 Prepare Inventory

Edit `ansible/playbooks/inventory/hosts.yml`:

```yaml
all:
  hosts:
    gitlab_server:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/your-key.pem
```

#### 1.2 Configure Variables

Edit `ansible/roles/gitlab/defaults/main.yml`:

```yaml
gitlab_external_url: "http://your-gitlab-ip"
gitlab_root_password: "YourSecurePassword"
gitlab_edition: "gitlab-ce"
```

#### 1.3 Run Playbook

```bash
ansible-playbook playbooks/deploy-gitlab.yml -i playbooks/inventory/hosts.yml
```

#### 1.4 Configure Runners

```bash
ansible-playbook playbooks/configure-runners.yml -i playbooks/inventory/hosts.yml
```

---

### 2. Infrastructure Setup

#### 2.1 Terraform Backend

Create S3 bucket for Terraform state:

```bash
aws s3api create-bucket \
  --bucket code-keeper-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket code-keeper-terraform-state \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

#### 2.2 Configure Environments

**Staging** (`environments/staging/terraform.tfvars`):
```hcl
environment     = "staging"
vpc_cidr        = "10.1.0.0/16"
eks_node_count  = 2
rds_instance    = "db.t3.micro"
```

**Production** (`environments/production/terraform.tfvars`):
```hcl
environment     = "production"
vpc_cidr        = "10.2.0.0/16"
eks_node_count  = 3
rds_instance    = "db.t3.small"
```

---

### 3. Application Setup

#### 3.1 Create GitLab Projects

In GitLab UI:
1. Create Group: `code-keeper`
2. Create Projects:
   - `inventory-app`
   - `billing-app`
   - `api-gateway`
   - `infrastructure`

#### 3.2 Configure Protected Branches

For each repository:
1. Settings → Repository → Protected Branches
2. Protect `main` branch
3. Allowed to merge: Maintainers
4. Allowed to push: No one

#### 3.3 Add CI/CD Variables

For each application repository (Settings → CI/CD → Variables):

```
AWS_ACCESS_KEY_ID          = <your_key>
AWS_SECRET_ACCESS_KEY      = <your_secret>
AWS_DEFAULT_REGION         = us-east-1
DOCKER_REGISTRY            = <your_registry>
DOCKER_USERNAME            = <username>
DOCKER_PASSWORD            = <password>
SONARQUBE_TOKEN            = <token>
STAGING_KUBECONFIG         = <base64_encoded_kubeconfig>
PRODUCTION_KUBECONFIG      = <base64_encoded_kubeconfig>
```

For infrastructure repository:
```
AWS_ACCESS_KEY_ID          = <your_key>
AWS_SECRET_ACCESS_KEY      = <your_secret>
TF_VAR_db_password         = <secure_password>
```

---

## 🔄 Pipelines

### Application Pipelines (CI/CD)

Each application has a `.gitlab-ci.yml` with the following stages:

#### CI Pipeline Stages

1. **Build**
   - Compile application
   - Install dependencies
   - Run linting

2. **Test**
   - Unit tests
   - Integration tests
   - Code coverage > 80%

3. **Scan**
   - SonarQube: Code quality
   - Snyk: Dependency vulnerabilities
   - Trivy: Container image scan

4. **Containerization**
   - Build Docker image
   - Tag with commit SHA
   - Push to Docker registry

#### CD Pipeline Stages

5. **Deploy to Staging**
   - Update Kubernetes manifests
   - Deploy to staging EKS cluster
   - Run smoke tests

6. **Approval**
   - Manual approval required
   - Stakeholder review
   - Deployment window check

7. **Deploy to Production**
   - Deploy to production EKS cluster
   - Blue/Green deployment
   - Health checks
   - Rollback if failed

**Pipeline Flow**:
```
Commit → Build → Test → Scan → Containerize
                                     ↓
                          Deploy to Staging
                                     ↓
                          Manual Approval ⏸️
                                     ↓
                        Deploy to Production
```

---

### Infrastructure Pipeline

`.gitlab-ci.yml` in infrastructure repository:

1. **Init**
   - Initialize Terraform
   - Configure backend

2. **Validate**
   - `terraform validate`
   - `terraform fmt -check`
   - `tfsec` (security scan)

3. **Plan**
   - Generate execution plan
   - Show resources to create/update/delete

4. **Apply to Staging**
   - Apply Terraform for staging
   - Automatic on main branch

5. **Approval**
   - Manual approval for production
   - Stakeholder review

6. **Apply to Production**
   - Apply Terraform for production
   - Only after approval

**Pipeline Flow**:
```
Commit → Init → Validate → Plan
                             ↓
                    Apply to Staging
                             ↓
                    Manual Approval ⏸️
                             ↓
                  Apply to Production
```

---

## 🔒 Security

### Implemented Security Measures

#### 1. Protected Branches
- Pipelines trigger only on `main` branch
- No direct push to main
- Merge requests required

#### 2. Secret Management
- All credentials in GitLab CI/CD Variables
- Marked as "Protected" and "Masked"
- No secrets in code or Terraform files
- AWS Secrets Manager for application secrets

#### 3. Least Privilege
- IAM roles with minimum permissions
- IRSA (IAM Roles for Service Accounts) for pods
- Separate credentials per environment

#### 4. Dependency Updates
- Automated security scans (Snyk)
- Dependabot/Renovate for updates
- Regular image updates

#### 5. Code Scanning
- SonarQube: Code quality + security hotspots
- Snyk: Known vulnerabilities in dependencies
- Trivy: Container image vulnerabilities

#### 6. Network Security
- Private subnets for databases
- Security groups restrict access
- VPC isolation between staging/production

---

## 🛠️ Troubleshooting

### GitLab Issues

**Problem**: GitLab not accessible
```bash
# Check status
systemctl status gitlab-runsvdir

# Restart GitLab
gitlab-ctl restart

# Check logs
gitlab-ctl tail
```

**Problem**: Runners not connecting
```bash
# Check runner status
gitlab-runner verify

# Re-register runner
gitlab-runner register
```

---

### Pipeline Failures

**Problem**: Build stage fails
- Check dependencies in package.json
- Verify Node.js version

**Problem**: Test stage fails
- Check test configuration
- Verify database connection in tests

**Problem**: Deploy fails
- Check kubeconfig is correct
- Verify cluster is accessible
- Check resource quotas

---

### Infrastructure Issues

**Problem**: Terraform apply fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Terraform state
terraform show

# Check for state lock
aws dynamodb scan --table-name terraform-locks
```

---

## 📊 Audit Preparation

See [AUDIT_PREPARATION.md](AUDIT_PREPARATION.md) for:
- Complete Q&A guide (20+ questions)
- Demonstration scenarios
- Roleplay preparation
- Technical deep-dives

---

## 📞 Support

- **Documentation**: `/docs` folder
- **Issues**: GitLab Issues tracker
- **Email**: devops@example.com

---

## 📝 License

MIT License

---

## 🏆 Project Highlights

✅ **4 GitLab Repositories** with full CI/CD
✅ **2 Environments** (Staging + Production)
✅ **Ansible Automation** for GitLab deployment
✅ **Terraform IaC** for AWS infrastructure
✅ **Security Scanning** (SonarQube, Snyk, Trivy)
✅ **Manual Approvals** for production deployments
✅ **Complete Documentation** with diagrams

---

**Version**: 1.0.0
**Date**: 2025-12-21
**Author**: Code-Keeper DevOps Team
