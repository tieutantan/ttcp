# Node Multiple CP

The Control Panel For NodeJS Multiple Apps And Domains.

### 1. Start Containers
`docker-compose up -d --build`

### 2. Add Domain
- `docker exec nmcp add domain app_local_port`

Example: tantn.com

- `docker exec nmcp add tantn.com 1111`

### 3. Remove Domain
- `docker exec nmcp rm tantn.com`

### 4. List Domains
- `docker exec nmcp list`

### Commands

#### Reload nginx
`docker exec nmcp nginx -s reload`

#### Install Docker, NodeJS19 on AWS Ubuntu20
`chmod +x ./setup/aws-ubuntu20.sh && ./setup/aws-ubuntu20.sh`