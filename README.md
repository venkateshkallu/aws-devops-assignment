# AWS DevOps Demo Application – Ashumat Foundation Assignment

**Public URL:** [http://aws-devops-app-alb-1040987424.eu-north-1.elb.amazonaws.com/](http://aws-devops-app-alb-1040987424.eu-north-1.elb.amazonaws.com/)  

Namaskaaram! 😄  

This project demonstrates **full DevOps workflow using AWS free-tier resources, Terraform, CI/CD, monitoring, and containerization**.

---

## 📋 Table of Contents
1. [Overview](#overview)  
2. [Architecture](#architecture)  
3. [Tech Stack & Justification](#tech-stack--justification)  
4. [Project Structure](#project-structure)  
5. [Prerequisites](#prerequisites)  
6. [Quick Start](#quick-start)  
7. [Deployment Steps](#deployment-steps)  
8. [CI/CD Pipeline](#cicd-pipeline)  
9. [Monitoring & Logging](#monitoring--logging)  
10. [Security](#security)  
11. [Cost Optimization & Scaling](#cost-optimization--scaling)  
12. [Troubleshooting](#troubleshooting)  
13. [Contributing](#contributing)  
14. [License](#license)  

---

## 🎯 Overview
- Simple **Node.js + Express.js app** with health check endpoint  
- Infrastructure as code using **Terraform**  
- **CI/CD** pipeline using GitHub Actions (code push → deployment)  
- **Containerization** using Docker  
- **AWS ECS Fargate** for serverless container orchestration  
- Basic **monitoring & logging** via CloudWatch  
- **Secure credentials** using IAM roles and OIDC federation (no hardcoded secrets)  

---

## 🏗️ Architecture
![Architecture Diagram](![alt text](image.png))  

**Flow:**
1. Developer pushes code → **GitHub repository**  
2. **GitHub Actions workflow** triggers: builds Docker image → pushes to **AWS ECR**  
3. **Terraform** provisions ECS cluster, ALB, VPC, and networking  
4. ECS service deploys containers → ALB routes traffic  
5. Logs & metrics automatically sent to **CloudWatch**  

---

## 🛠️ Tech Stack & Justification

| Layer | Tools | Why Chosen |
|-------|-------|------------|
| Application | Node.js + Express + EJS | Lightweight, fast, easy containerization |
| Container | Docker | Consistency across dev/staging/prod |
| Orchestration | ECS Fargate | Serverless, no EC2 management, auto-scaling |
| IaC | Terraform | Declarative, version-controlled infrastructure |
| CI/CD | GitHub Actions | Easy GitHub integration, triggers on push |
| Monitoring | CloudWatch | Logs + metrics for app & ECS |
| Security | IAM Roles, OIDC | No hardcoded secrets, least privilege |

**Note:** Used **AWS free-tier resources** wherever possible.

---

## 📁 Project Structure
```

aws-devops-demo-app/
├── app/          # Application code
│   ├── server.js
│   ├── package.json
│   ├── views/
│   ├── public/
│   └── Dockerfile
├── iac/          # Terraform code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── pipeline/     # CI/CD workflow
│   └── ci-cd.yml
└── README.md     # This file

````

---

## ✅ Prerequisites
**Local Development:**
- Node.js v18+  
- Docker  
- Terraform v1.6+  
- AWS CLI configured  

**AWS Setup:**
- AWS account with **free-tier resources**  
- IAM user with programmatic access  
- Proper permissions for ECS, ECR, ALB, CloudWatch  

**GitHub Setup:**
- GitHub repository  
- GitHub secrets for AWS authentication (OIDC recommended)  

---

## 🚀 Quick Start
1. Clone repo:
```bash
git clone <your-repo-url>
cd aws-devops-demo-app
````

2. Install dependencies and run locally:

```bash
cd app
npm install
npm run dev
curl http://localhost:3000
curl http://localhost:3000/health
```

3. Test Docker build:

```bash
docker build -t aws-devops-demo ./app
docker run -p 3000:3000 aws-devops-demo
curl http://localhost:3000
```

---

## 🏗️ Deployment Steps

1. Configure Terraform:

```bash
cd iac
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

2. Deploy infrastructure:

```bash
terraform init
terraform plan
terraform apply
```

3. Push code to GitHub → triggers CI/CD pipeline → ECS service updates automatically

4. Access live app via public ALB URL:
   [http://aws-devops-app-alb-1040987424.eu-north-1.elb.amazonaws.com/](http://aws-devops-app-alb-1040987424.eu-north-1.elb.amazonaws.com/)

---

## 🔄 CI/CD Pipeline

**Workflow steps:**

1. Checkout code
2. Configure AWS via OIDC
3. Build Docker image
4. Push to ECR
5. Update ECS service

**Trigger:** Push to `main` branch or manual workflow dispatch

---

## 📊 Monitoring & Logging

* **CloudWatch logs:** App stdout/stderr
* **ECS metrics:** CPU, memory, network
* **ALB metrics:** Request count, latency, error rates
* Health endpoint: `/health`

---

## 🔒 Security

* No hardcoded credentials
* OIDC federation for GitHub Actions
* Least privilege IAM policies
* VPC isolation & minimal security groups
* Optional: Use AWS Secrets Manager / SSM Parameter Store for sensitive info

---

## 💰 Cost Optimization & Scaling

* Fargate: Pay only for CPU/memory
* ALB: Charges per hour + LCU usage
* ECR: Minimal storage costs
* Auto-scaling: ECS service can scale based on metrics

---

## 🔧 Troubleshooting

* ECS service not starting → check events & task definitions
* CI/CD failures → verify credentials, IAM roles, ECR repo
* App inaccessible → check ALB security groups, target health, ECS tasks

---

## 🤝 Contributing

* Fork repo → create feature branch → make changes → test → PR

---

## 📄 License

MIT License – see package.json

---

*This project was developed as part of the Ashumat Foundation assignment. It demonstrates a complete AWS DevOps workflow using Terraform, ECS, and CI/CD automation.*


```
