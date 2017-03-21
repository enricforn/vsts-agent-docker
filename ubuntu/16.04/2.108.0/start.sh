#!/bin/bash
set -e

if [ -z "$VSTS_ACCOUNT" ]; then
  echo 1>&2 error: missing VSTS_ACCOUNT environment variable
  exit 1
fi

if [ -z "$VSTS_TOKEN" ]; then
  echo 1>&2 error: missing VSTS_TOKEN environment variable
  exit 1
fi

if [ -n "$VSTS_AGENT" ]; then
  export VSTS_AGENT=$(eval echo $VSTS_AGENT)
fi

if [ -n "$VSTS_WORK" ]; then
  export VSTS_WORK=$(eval echo $VSTS_WORK)
  mkdir -p "$VSTS_WORK"
  chown -R vsts:vsts "$VSTS_WORK"
fi

#Start docker daemon
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- docker "$@"
fi

# if our command is a valid Docker subcommand, let's invoke it through Docker instead
# (this allows for "docker run docker ps", etc)
if docker help "$1" > /dev/null 2>&1; then
	set -- docker "$@"
fi

# if we have "--link some-docker:docker" and not DOCKER_HOST, let's set DOCKER_HOST automatically
if [ -z "$DOCKER_HOST" -a "$DOCKER_PORT_2375_TCP" ]; then
	export DOCKER_HOST='tcp://docker:2375'
fi

exec "$@"

#Start agent configuration
cd /home/vsts/agent

cleanup() {
  su vsts -s /bin/bash -c './config.sh remove --unattended \
    --auth PAT \
    --token "$VSTS_TOKEN"'
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

export VSO_AGENT_IGNORE=_,MAIL,PATH,VSO_AGENT_IGNORE,VSTS_AGENT,VSTS_ACCOUNT,VSTS_TOKEN,VSTS_POOL,VSTS_WORK
if [ -n "$VSTS_AGENT_IGNORE" ]; then
  export VSO_AGENT_IGNORE=$VSO_AGENT_IGNORE,VSTS_AGENT_IGNORE,$VSTS_AGENT_IGNORE
fi

su vsts -s /bin/bash -c './config.sh --unattended \
  --agent "${VSTS_AGENT:-$(hostname)}" \
  --url "https://$VSTS_ACCOUNT.visualstudio.com" \
  --auth PAT \
  --token "$VSTS_TOKEN" \
  --pool "${VSTS_POOL:-Default}" \
  --work "${VSTS_WORK:-_work}" \
  --replace' & wait $!

su vsts -s /bin/bash -c ./run.sh & wait $!