# AutoOps 🚀

An automated cloud deployment platform that provisions infrastructure, containerizes applications, and deploys them automatically using a full CI/CD pipeline.

## What This Does

Push code to GitHub → AutoOps automatically:
- Builds a Docker image
- Deploys the container to AWS EC2
- Serves the app on a live public IP

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Infrastructure | Terraform, AWS EC2 |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Networking | AWS Security Groups |
| App | FastAPI (Python) |
| Monitoring | Prometheus, Grafana, Node Exporter |
| Reliability | Docker restart policies |

## Architecture

Developer pushes code
↓
GitHub Actions triggers
↓
SSH into EC2 server
↓
Pull latest code
↓
Build Docker image
↓
Deploy container on port 80
↓
App live at public IP

## Project Structure
autoops/
├── app/
│   ├── main.py          # FastAPI application
│   ├── requirements.txt # Python dependencies
│   └── Dockerfile       # Container definition
├── terraform/
│   └── main.tf          # AWS infrastructure as code
└── .github/
└── workflows/
└── deploy.yml   # CI/CD pipeline

## Live Endpoint

- `GET /` → returns system status
- `GET /health` → returns health check

## Observability & Reliability Engineering

- Prometheus monitoring & Grafana dashboards
- Auto-scaling with load balancing
- Ansible for configuration management
- Fault tolerance & auto-recovery

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Infrastructure | Terraform, AWS EC2 |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus, Grafana, Node Exporter |
| Reliability | systemd services, Docker restart policies |
| App | FastAPI (Python) |

## Architecture

Developer pushes code
↓
GitHub Actions triggers
↓
SSH into EC2 server
↓
Pull latest code → Build Docker image → Deploy container
↓
Prometheus scrapes metrics every 15s
↓
Grafana visualizes CPU, RAM, Disk, Network
↓
All services auto-restart on reboot via systemd

## What's Next (Phase 4)
- Load balancing across multiple servers
- Ansible configuration management
- Remote Terraform state in S3