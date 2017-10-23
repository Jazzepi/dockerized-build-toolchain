#!/usr/bin/env bash
#Read the version from the pom file
function readversion {
  cat $(dirname $0)/pom.xml | \
    docker run -i --rm jakubsacha/docker-xmlstarlet \
    sel -N m=http://maven.apache.org/POM/4.0.0 \
    -t -v '/m:project/m:version' -
}

GITROOT=$(git rev-parse --show-toplevel)
VERSION=$(readversion)
GROUP_ADDS=$(for group in $(id --groups); do echo "--group-add=${group}"; done)
if [[ -n $PWD_FOR_COMMAND ]]; then
  cd $PWD_FOR_COMMAND
fi

#NOTE: You need to have your id in the 'docker' group to mount the docker.sock. You can do that with the below command.
#sudo usermod -a -G docker $USER
docker run \
    --rm=true `#Trash the container after we are done running it. We never want to use this container again.` \
    --net=host `#Share the same network as our host` \
    --user=$(id -u):$(id -g) -it \
            `#Be ourselves inside the container, not root` \
    -e USER=${USER} \
    -e MAVEN_CONFIG=${HOME}/.m2 \
    -e TERM=${TERM} `#Preserves your terminal settings inside the container. Keeps less, top, and nano from complaining` \
    --workdir=$(pwd) `#Run our command inside the docker at the same directory we are invoking the command from` \
    -e DOCKER_URL=unix:///var/run/docker.sock `#Make sure we are using the directory based socket inside the container` \
    -e DOCKER_API_VERSION=1.23 \
    -e DISPLAY=unix$DISPLAY \
    --volume=/etc/passwd:/etc/passwd `#Get the same passwords, users, and groups in our docker as our host. Allows us to be ourselves inside the container.` \
    --volume=/etc/group:/etc/group \
    $GROUP_ADDS \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix \
    --volume=/var/run/docker.sock:/var/run/docker.sock `#And mount the socket on our host inside the container. This way if we are using Docker inside of our build environment it will create containers. That are siblings of this container, not children. Dockers inside of Dockers does have a whole host of issues.` \
    --volume=/etc/localtime:/etc/localtime `#Share the timezone with our host` \
    --volume=/etc/timezone:/etc/timezone \
    --volume=${HOME}:${HOME} `#We set ourselves as the user earlier, and we want the hosts user directory (ours) to appear inside of the container as well.` \
    --volume=${GITROOT}:${GITROOT} `#Mount the current git directory into the container. This makes our git project code, etc. avaliable to the build tools running inside the Docker container` \
    sasquatch-technology-build-environment:${VERSION} "$@" `#Run on our build environment image. The "@" is a bashism that passes in the parameters to this shell script. It makes the shell script a "pass through".`
