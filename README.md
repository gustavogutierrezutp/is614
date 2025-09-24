# is614

The goal of this repo is to provide my students with a simple starting point for
their quartus projects. It consists of a Docker container with quartus and a dev
container configuration that allows them to use quartus in a simple way.

The first time you will open the dev container, it will take a while to build.
This is because it will download the quartus installer and install it inside the
container. The quertus installer is a bit heavy and after installing it Docker
will take a while when exporting the layers. Hopefully the next time you open
the dev container it will be much faster.
 
- https://github.com/dorssel/usbipd-win
- 

## Dev Container


## Docker image

Inside the `.devcontainer` folder there is a Dockerfile
that will create a dev container with quartus installed and with the appropriate
support for the Cyclone V FPGA.

Quartus version: 24.1 is a bit heavy and therefore it will take a while to build
the container the first time. After that, starting the container will be much
faster. Feel free to modify the Dockerfile to install a different version of
quartus or to add/remove components.

If the docker images will be used alone without the dev container:

- To build the image:
```bash
docker build -t quartus-lite-24.1 -f .devcontainer/Dockerfile .
```


- To run it:

```bash
docker run --rm 
    --net=host 
    -v /sys:/sys:ro 
    -v /tmp/.X11-unix:/tmp/.X11-unix 
    -e DISPLAY=$DISPLAY 
    -v $HOME:$HOME 
    -w $PWD 
    --device-cgroup-rule='c *:* rmw' 
    --security-opt seccomp=unconfined 
    --privileged 
    -v /dev/bus/usb:/dev/bus/usb 
    quartus-lite-24.1
```

```bash
docker run --rm `
  --net=host `
  -v /sys:/sys:ro `
  --device-cgroup-rule='c *:* rmw' `
  --security-opt seccomp=unconfined `
  --privileged `
  -v /dev/bus/usb:/dev/bus/usb `
  -v /tmp/.X11-unix:/tmp/.X11-unix `
  -e DISPLAY=$env:DISPLAY `
  quartus-lite-24.1

```


The string `quartus-lite-24.1` is a suggestion for the image name, you can
change it. Just make it consistent with the `docker build` command. Be aware of
the options `--device-cgroup-rule`, `--security-opt seccomp=unconfined`, and
`--privileged`. They are necessary to allow the container to access the FPGA but
you might want to remove them if you are concerned about security.
