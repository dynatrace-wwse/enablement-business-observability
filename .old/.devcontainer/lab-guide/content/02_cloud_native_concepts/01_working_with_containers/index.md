## Working with Containers

In this lab you'll learn how to create a container image and how to run a container based on this image. During this activity you will pull an image from a global container registry to get hands-on experience with container registries in general.

### Step 1: Create the Dockerfile and script

1. Create a directory for the docker artifacts

   ```bash
   (bastion)$ cd ~
   (bastion)$ mkdir -p docker/
   (bastion)$ cd docker/
   ```

2. Create a new file named `Dockerfile` and add the following content:

   ```docker
   FROM alpine:latest
   COPY . /app
   WORKDIR /app
   RUN apk add --no-cache wget
   ENTRYPOINT [ "sh" ]
   CMD ["hello_world.sh"]
   ```

3. Create a new file named `hello_world.sh` and add the following content:

   ```bash
   echo "Hello World from a Docker Container."
   ```

4. Ensure that the script is an executable:

   ```bash
   (bastion)$ chmod +x hello_world.sh
   ```

### Step 2. Build and Tag a Container Image

5. Build the container image (`-t` specifies the repository and a tag). The `$USER` variable will tag the image with your username.

   ```bash
   (bastion)$ docker build -t acl/hello-world:$USER .
   ```

6. List all container images on your local machine.

   ```bash
   (bastion)$ docker images
   ```

7. Set another tag.

   ```bash
   (bastion)$ docker tag acl/hello-world:$USER acl/hello-world:$USER-stable
   ```

8. List all container images on your local machine.

   ```bash
   (bastion)$ docker images
   ```

### Step 3. Run a Container

1. Run the container based on a container image.

   ```bash
   (bastion)$ docker run acl/hello-world:$USER-stable
   ```
