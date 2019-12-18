# Quartus_MiSTer_build
Docker for building [MiSTer](https://github.com/MiSTer-devel) Cores

## Description

First stage is building a docker, that in essence is a debian installation with
the build requirements, cross compiler is downloaded and unpacked, MiSTer
sources are downloaded and unpacked, and a kernel is buildt with default
configuration.

### Using Docker

```
docker build -t quartus181 https://github.com/DwaineGarden/Quartus_MiSTer_build.git . --network=host -t quartus181
docker run -it --rm --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v /etc/machine-id:/etc/machine-id quartus181
```

