# Node Multiple Simple

The Control Panel For NodeJS Multiple Apps And Domains.

This tool is ideal for individuals who want to run multiple native NodeJS apps and dockerized nginx instances with domains on a single server in **a straightforward manner**. It provides a convenient and efficient way to create Nginx configuration files and add or remove `.conf` files.

## Instruction

### 1. Add Domain
- `docker exec nms add domain app_local_port`

Example: tantn.com

- `docker exec nms add tantn.com 1111`

### 2. List Domains as domain-port
- `docker exec nms list`

### 3. Remove Domain
- `docker exec nms remove tantn.com`

----

## Setup NMS in a new AWS Ubuntu server

#### 1. Clone this repository
`git clone https://github.com/tieutantan/Node-Multiple-Simple.git`

#### 2. Install Docker, Node v19 on AWS Ubuntu v20
`cd Node-Multiple-Simple && chmod +x ./setup/aws-ubuntu20.sh && ./setup/aws-ubuntu20.sh`

#### 3. Start
`docker-compose up -d --build`

#### 4. Add, Remove and List your domains, applications.

----

## Others

#### Reload nginx
`docker exec nms nginx -s reload`

----

If you run into a bug or want to work with me to improve it, 
please consider submitting a pull request. 
Your help will be much appreciated by the entire community. Thank you!