## The project is a simple docker-compose file to run a laravel project with traefik as a reverse proxy

### 1. Create the trafiik network

```bash
docker network create traefik-net
```

### 2. Give the start.sh script executable permission (only if you neeed to run special commands on the build.)
```bash
sudo chmod +x project/start.sh
```

### 3. Add you laravel project to the project/application folder

### 4. run *make build* and up the docker-compose file

### 5. run *make start* the docker-compose file
