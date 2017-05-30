# vsts-agent-docker

First of all you need to initialize your environment:

ubuntu


rhel


Image to compile netcore or nodejs applications

This image is useful to compile .netcore or nodejs applications in an isolated environment.

You must map a docker host volume

## How to build the image:

docker build --build-arg ARG_DOTNET_SDK_VERSION=1.0.1 --build-arg ARG_NODE_VERSION=6.9.4 -t tfs-agent-docker .

or 

docker build --build-arg ARG_DOTNET_SDK_VERSION=1.0.1 --build-arg ARG_NODE_VERSION=6.9.4 -t vsts-agent-docker .

## How to create and run a container from the image:

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e TFS_HOST=tfs.mycompany.com -e TFS_URL=https://tfs.mycompany.com -e AUTHTYPE=PAT -e VSTS_TOKEN=**************************************************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d tfs-agent-docker

or 

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e TFS_HOST=tfs.mycompany.com -e TFS_URL=https://tfs.mycompany.com -e AUTHTYPE=Negotiate -e VSTS_USER=domain\user.to.connect.to.tfs -e VSTS_PASSWORD=******************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d tfs-agent-docker

or

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e VSTS_ACCOUNT=enformat -e AUTHTYPE=PAT -e VSTS_TOKEN=**************************************************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d vsts-agent-docker

or 

docker run --privileged -v /var/run/docker.sock:/var/run/docker.sock -e AUTHTYPE=Negotiate -e VSTS_USER=domain\user.to.connect.to.tfs -e VSTS_PASSWORD=******************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d vsts-agent-docker
