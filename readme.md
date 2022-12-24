# Node Multiple CP

The Control Panel For NodeJS Multiple Apps And Domains.
This tool is suitable for those who want to run multiple NodeJS apps with domains on one server as the most straightforward way. Save time to create Nginx configuration and faster way to add, and remove `.conf` file.

## Instruction

### 1. Start Container
`docker-compose up -d --build`

### 2. Add Domain
- `docker exec nmcp add domain app_local_port`

Example: tantn.com

- `docker exec nmcp add tantn.com 1111`

### 3. Remove Domain
- `docker exec nmcp rm tantn.com`

### 4. List Domains
- `docker exec nmcp list`

----

## Setup NMCP in a new Ubuntu sv of AWS

#### 1. Clone this repository
`git clone https://github.com/tieutantan/Node-Multiple-CP.git`

#### 2. Install Docker, NodeJS19 on AWS Ubuntu20
`cd Node-Multiple-CP && chmod +x ./setup/aws-ubuntu20.sh && ./setup/aws-ubuntu20.sh`

#### 3. Start
`docker-compose up -d --build`

#### 4. Add, Remove and List your domains, applications.

----

## Others

#### Reload nginx
`docker exec nmcp nginx -s reload`