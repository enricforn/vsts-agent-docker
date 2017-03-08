# vsts-agent-docker

Image to compile netcore or nodejs applications

This image is useful to compile .netcore or nodejs applications in an isolated environment.


## How to build the image:

docker build -t tfs-agent-docker .


## How to create and run a container from the image:

docker run -e TFS_HOST=tfs.mycompany.com -e TFS_URL=https://tfs.mycompany.com -e AUTHTYPE=PAT -e VSTS_TOKEN=**************************************************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d tfs-agent-docker

or 

docker run -e TFS_HOST=tfs.mycompany.com -e TFS_URL=https://tfs.mycompany.com -e AUTHTYPE=Negotiate -e VSTS_USER=domain\user.to.connect.to.tfs -e VSTS_PASSWORD=******************** -e VSTS_WORK=_work -e VSTS_POOL=docker -d tfs-agent-docker



