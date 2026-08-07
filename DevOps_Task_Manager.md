# DevOps Task Manager Project Guide (Phase 1 → Phase 9)

## Project Overview

This guide summarizes everything completed through **Phase 9** of the
project.

Topics covered:

-   Git & GitHub
-   Python & Virtual Environments
-   Flask
-   Linux Commands
-   Bash Scripting
-   Terraform
-   Docker & Docker Compose
-   Prometheus
-   Grafana
-   AWS EC2
-   Amazon ECR
-   GitHub Actions
-   Nginx Reverse Proxy

------------------------------------------------------------------------

## Git Configuration

``` bash
git config --global user.name "YOUR_NAME"
git config --global user.email "YOUR_EMAIL"
```

------------------------------------------------------------------------

## Create .gitignore

``` powershell
New-Item .gitignore
code .gitignore
```

------------------------------------------------------------------------

## VS Code

``` bash
code .
code ecr.tf
```

------------------------------------------------------------------------

## Python

`pip` is Python's standard package manager used to install, update, and
manage project dependencies.

``` bash
python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
pip install python-dotenv
pip show python-dotenv
```

------------------------------------------------------------------------

## EC2

``` bash
ssh -i Devops.pem ubuntu@EC2_PUBLIC_IP
```

------------------------------------------------------------------------

## Linux Commands

``` bash
rm -rf test
cp app.py backup.py
mv backup.py old.py

ps -ef | grep python
kill PID
lsof -i :5000

sudo apt install net-tools
netstat

df -h
du -sh *
free -h
top
sudo apt install htop
ps -ef
ss -tuln
tail -f logs/app.log
```

------------------------------------------------------------------------

## Manual Deployment

``` bash
git pull
source venv/bin/activate
pip install -r requirements.txt
python3 app.py
```

Deployment scripts:

``` bash
git pull
source venv/bin/activate
pip install -r requirements.txt

./scripts/stop.sh
./scripts/start.sh
./scripts/health-check.sh
```

------------------------------------------------------------------------

## Bash

``` bash
#!/bin/bash
echo "Hello DevOps"
```

``` bash
chmod +x hello.sh
./hello.sh
```

`set -e` stops a script immediately if any command fails.

Run Flask in background:

``` bash
nohup python3 app.py > output.log 2>&1 &
```

------------------------------------------------------------------------

## Docker

Docker packages the application, Python runtime, libraries,
dependencies, and runtime configuration into a portable **image**.

Installation:

``` bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run hello-world
```

Useful commands:

``` bash
docker images
docker ps -a
docker build -t task-manager .
docker run -d --name task-manager -p 5000:5000 task-manager
docker exec -it task-manager bash

docker compose up
docker compose up -d
docker compose down
docker compose logs
docker compose logs -f

docker network ls
docker inspect task-manager

docker system prune -a
```

------------------------------------------------------------------------

## Flask

Flask is a lightweight Python web framework for building web
applications and APIs.

Port mapping example:

    5001:5000
    Host Port -> Container Port

------------------------------------------------------------------------

## Prometheus & Grafana

Allow inbound security group rules for:

-   3000 (Grafana)
-   9090 (Prometheus)

Useful Prometheus queries:

    http_requests_total
    rate(http_requests_total[1m])

Load test:

``` bash
for i in {1..100}
do
curl http://localhost:5000/
done
```

------------------------------------------------------------------------

## AWS CLI

``` bash
aws configure
aws sts get-caller-identity
```

Use IAM roles where possible instead of long-lived credentials.

------------------------------------------------------------------------

## grep

``` bash
grep "word" filename
grep -n "instance_type" main.tf
grep -r "instance_type" .
grep -i "ubuntu" main.tf
```

------------------------------------------------------------------------

## Git Branch Workflow

``` bash
git checkout feature/login
git add .
git commit -m "Add login feature"
git push -u origin feature/login
```

------------------------------------------------------------------------

## Amazon ECR

``` bash
aws ecr get-login-password --region ap-south-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-south-2.amazonaws.com

docker tag task-manager:latest <ACCOUNT_ID>.dkr.ecr.ap-south-2.amazonaws.com/task-manager:latest

docker push <ACCOUNT_ID>.dkr.ecr.ap-south-2.amazonaws.com/task-manager:latest

aws ecr list-images --repository-name task-manager --region ap-south-2
```

Attach the `AmazonEC2ContainerRegistryPowerUser` policy to the EC2 IAM
role.

------------------------------------------------------------------------

## GitHub Actions

Generate an SSH key:

``` bash
ssh-keygen -t rsa -b 4096 -C "github-actions"
```

Add `id_rsa.pub` to `~/.ssh/authorized_keys` on the EC2 instance.

Store secrets in GitHub Repository Secrets.

------------------------------------------------------------------------

## Nginx Reverse Proxy

Nginx listens on the public HTTP port and forwards requests to the Flask
application over the internal Docker network.

    Internet
       |
    Nginx (80)
       |
    Docker Network
       |
    Flask (5000)

------------------------------------------------------------------------

## Best Practices

-   Never commit GitHub tokens, AWS keys, or private keys.
-   Use `.gitignore`.
-   Use environment variables or GitHub Secrets for sensitive values.
-   Prefer IAM roles over static AWS credentials.

------------------------------------------------------------------------

# End of Phase 9

At this point the project supports:

-   Infrastructure provisioning with Terraform
-   Dockerized Flask application
-   Image storage in Amazon ECR
-   Automated deployment with GitHub Actions
-   Monitoring with Prometheus and Grafana
-   Secure public access through Nginx Reverse Proxy
