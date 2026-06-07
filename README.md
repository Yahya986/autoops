# AutoOps

A production-grade cloud deployment platform built to automate the full DevOps lifecycle — from infrastructure provisioning to containerized deployments, real-time observability, and auto-scaling.

## Overview

AutoOps eliminates manual deployment workflows. Every push to the main branch triggers a fully automated pipeline that builds, tests, and deploys the application across a load-balanced, auto-scaling AWS infrastructure — with zero downtime.

## Architecture

Developer pushes code to GitHub
│
▼
GitHub Actions CI/CD Pipeline
│
▼
AWS Auto Scaling Group
┌─────────────────────┐
│  EC2 Instance 1     │
│  EC2 Instance 2     │  ← scales up to 4 under load
└─────────────────────┘
│
▼
AWS Application Load Balancer
(health checks every 30s)
│
▼
Live Application
│
▼
Prometheus → Grafana
(metrics, dashboards, alerts)

## Tech Stack

| Layer | Technology |
|---|---|
| Infrastructure | Terraform, AWS EC2 |
| Networking | AWS ALB, Auto Scaling Group |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus, Grafana, Node Exporter |
| Reliability | systemd, Docker restart policies |
| Application | FastAPI (Python) |

## Key Features

**Infrastructure as Code**
All AWS resources — EC2, ALB, Auto Scaling Groups, and Security Groups — are defined and provisioned using Terraform. The entire infrastructure can be created or torn down with a single command.

**Automated CI/CD**
GitHub Actions triggers on every push to main. The pipeline builds a fresh Docker image and initiates an AWS Auto Scaling Group instance refresh, ensuring zero-downtime deployments across all running instances.

**Observability Stack**
Prometheus scrapes server metrics every 15 seconds. Grafana dashboards visualize CPU, memory, disk, and network in real time. All monitoring services run as systemd units and survive server reboots automatically.

**Auto Scaling & Load Balancing**
The AWS Application Load Balancer distributes traffic across a minimum of 2 EC2 instances, scaling up to 4 under high load. Unhealthy instances are automatically detected and replaced via ALB health checks.

**Self-Healing Infrastructure**
All services (Prometheus, Grafana, Node Exporter, Docker) are registered as systemd services. On server reboot, every service restarts automatically with no manual intervention required.

## Project Structure

autoops/
├── app/
│   ├── main.py              # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile           # Container definition
├── terraform/
│   └── main.tf              # AWS infrastructure as code
└── .github/
└── workflows/
└── deploy.yml       # CI/CD pipeline


## API

| Method | Endpoint | Description |
|---|---|---|
| GET | `/` | Returns system status |
| GET | `/health` | Health check — used by AWS ALB |

## Infrastructure Setup

```bash
# Provision all AWS infrastructure
cd terraform
terraform init
terraform apply

# Tear down all resources
terraform destroy
```

## Live

**Load Balancer:** http://autoops-alb-573839267.us-east-1.elb.amazonaws.com