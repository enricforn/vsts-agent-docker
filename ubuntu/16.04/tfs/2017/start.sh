#!/bin/bash
set -e

if [ -z "$TFS_HOST" -a -z "$TFS_URL" ]; then
  echo 1>&2 error: missing TFS_HOST environment variable
  exit 1
fi

if [ -z "$TFS_URL" ]; then
  export TFS_URL=http://$TFS_HOST:8080/tfs
fi

if [ "$AUTHTYPE" == "Negotiate" ]; then
  if [ -z "$VSTS_USER" ]; then
    echo 1>&2 error: missing VSTS_USER environment variable
    exit 1
  fi
  if [ -z "$VSTS_PASSWORD" ]; then
    echo 1>&2 error: missing VSTS_PASSWORD environment variable
    exit 1
  fi
elif [ "$AUTHTYPE" == "PAT" ]; then
  if [ -z "$VSTS_TOKEN" ]; then
    echo 1>&2 error: missing VSTS_TOKEN environment variable
    exit 1
  fi
else
    echo 1>&2 error: no authentication defined. Available authentication types: "Negotiate", "PAT"
    exit 1
fi

if [ -n "$VSTS_AGENT" ]; then
  export VSTS_AGENT=$(eval echo $VSTS_AGENT)
fi

if [ -n "$VSTS_WORK" ]; then
  export VSTS_WORK=$(eval echo $VSTS_WORK)
  mkdir -p "$VSTS_WORK"
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

cd /vsts/agent

cleanup() {
  if [ "$AUTHTYPE" == "PAT" ]; then
    ./bin/Agent.Listener remove --unattended \
      --auth PAT \
      --token "$VSTS_TOKEN"
  elif [ "$AUTHTYPE" == "Negotiate" ]; then
    ./bin/Agent.Listener remove --unattended \
    --auth Negotiate \
    --username "$VSTS_USER" \
    --password "$VSTS_PASSWORD"
  fi
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

export VSO_AGENT_IGNORE=_,MAIL,OLDPWD,PATH,PWD,VSO_AGENT_IGNORE,VSTS_AGENT,TFS_HOST,TFS_URL,VSTS_TOKEN,VSTS_POOL,VSTS_WORK
if [ -n "$VSTS_AGENT_IGNORE" ]; then
  export VSO_AGENT_IGNORE=$VSO_AGENT_IGNORE,VSTS_AGENT_IGNORE,$VSTS_AGENT_IGNORE
fi

source ./env.sh

if [ "$AUTHTYPE" == "PAT" ]; then
  ./bin/Agent.Listener configure --unattended \
    --agent "${VSTS_AGENT:-$(hostname)}" \
    --url "$TFS_URL" \
    --auth "PAT" \
    --token "$VSTS_TOKEN" \
    --pool "${VSTS_POOL:-Default}" \
    --work "${VSTS_WORK:-_work}" \
    --replace & wait $!
elif [ "$AUTHTYPE" == "Negotiate" ]; then
  ./bin/Agent.Listener configure --unattended \
    --agent "${VSTS_AGENT:-$(hostname)}" \
    --url "$TFS_URL" \
    --auth "Negotiate" \
    --username "$VSTS_USER" \
    --password "$VSTS_PASSWORD" \
    --pool "${VSTS_POOL:-Default}" \
    --work "${VSTS_WORK:-_work}" \
    --replace & wait $!
fi

./bin/Agent.Listener run & wait $!