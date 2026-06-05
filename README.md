# ☕🍜 ChaiChaatCharcha AutoBlog

A personal food & coffee diary blog built on AWS. Drop a photo, write a short review, give it a rating — and it auto-publishes to a beautiful public blog page. Built to explore and showcase a wide range of AWS services with security best practices.

**GitHub:** https://github.com/abila98/ChaiChaatCharcha-AutoBlog

---

## What it does

- You log in (Cognito) and post a food/coffee entry with a photo, review, and star rating
- Photo is stored in S3, metadata in DynamoDB
- Anyone can view your public blog — no login needed
- Images served via CloudFront signed URLs (private S3 bucket)
- Runs on Node.js + Express, containerised with Docker, hosted on EC2 in a private subnet behind an ALB

---

## AWS Services Used

| Service | Purpose |
|---|---|
| EC2 | Runs the Node.js app in a private subnet |
| ALB | Public-facing load balancer |
| S3 | Stores food/coffee photos |
| CloudFront | Serves images via CDN |
| DynamoDB | Stores blog entries |
| Cognito | Admin login (only you can post) |
| VPC + Subnets | Private networking |
| NAT Gateway | Outbound internet for private EC2 |
| VPC Endpoints | Private access to ECR, SSM without internet |
| ECR | Docker image registry |
| IAM | Roles and policies |
| SSM Session Manager | Secure shell access, no SSH keys needed |

---

## Project Structure

```
ChaiChaatCharcha-AutoBlog/
├── terraform/          # All AWS infrastructure as code
├── codebase/           # Node.js backend + HTML frontend
│   ├── server.js
│   ├── public/
│   │   └── index.html
│   ├── package.json
│   └── Dockerfile
└── README.md
```

---

## Setup Guide

### Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform >= 1.3 installed
- Node.js >= 20 installed
- Docker installed

---

### Step 1 — Provision Infrastructure with Terraform

```bash
# Navigate to terraform folder
cd terraform

# Initialise Terraform — downloads providers and sets up workspace
terraform init

# Preview what will be created
terraform plan

# Apply — creates VPC, subnets, EC2, ALB, S3, DynamoDB, IAM roles etc.
terraform apply
```

> After apply completes, Terraform will output your ALB DNS, S3 bucket name, and DynamoDB table name. Note these down.

---

### Step 2 — SSH into EC2 via SSM (no key pair needed)

```bash
# Get your instance ID from AWS console or Terraform output
aws ssm start-session --target <instance-id> --region us-east-1
```

---

### Step 3 — Install prerequisites on EC2

```bash
# Update packages
sudo yum update -y

# Install Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install -y nodejs

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker

# Verify
node --version
docker --version
```

---

### Step 4 — Run the Node.js app

```bash
# Clone the repo
git clone https://github.com/abila98/ChaiChaatCharcha-AutoBlog.git
cd ChaiChaatCharcha-AutoBlog/codebase

# Install dependencies
npm install

# Create environment file
cat > .env << EOF
AWS_REGION=us-east-1
S3_BUCKET=ccc-images-abila
DYNAMO_TABLE=ccc-entries
PORT=3000
EOF

# Run the app
node server.js
```

> App runs on port 3000. Access it via your ALB DNS — `http://<alb-dns-name>`

---

### Step 5 — Dockerise the app

```bash
# Build the Docker image
docker build -t chaichaatcharcha .

# Test locally
docker run -d \
  -p 3000:3000 \
  --env-file .env \
  --name chaichaatcharcha \
  chaichaatcharcha

# Check logs
docker logs chaichaatcharcha
```

---

### Step 6 — Push to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag the image
docker tag chaichaatcharcha:latest \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/chaichaatcharcha:latest

# Push
docker push \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/chaichaatcharcha:latest
```

---

### Tear down infrastructure

```bash
cd terraform
terraform destroy
```

---

## Author

**Abila** — [@abila98](https://github.com/abila98)
