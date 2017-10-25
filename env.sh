#!/usr/bin/env bash
#Read the version from the pom file
function readversion {
  cat $(dirname $0)/pom.xml | \
    docker run -i --rm jakubsacha/docker-xmlstarlet \
    sel -N m=http://maven.apache.org/POM/4.0.0 \
    -t -v '/m:project/m:version' -
}

if [[ -n $PWD_FOR_COMMAND ]]; then
  cd $PWD_FOR_COMMAND
fi
GITROOT=$(git rev-parse --show-toplevel)
VERSION=$(readversion)
GROUP_ADDS=$(for group in $(id --groups); do echo "--group-add=${group}"; done)

#NOTE: You need to have your id in the 'docker' group to mount the docker.sock. You can do that with the below command.
#sudo usermod -a -G docker $USER
docker run \
    --rm=true `#Trash the container after we are done running it. We never want to use this container again.` \
    --net=host `#Share the same network as our host` \
    --user=$(id -u):$(id -g) `#Be ourselves inside the container, not root` \
    -e MAVEN_CONFIG=${HOME}/.m2 \
    -e TERM=${TERM} `#Preserves your terminal settings inside the container. Keeps less, top, and nano from complaining` \
    -it `#Connect standard in/out to our terminal and a TTY in case we need to input something.` \
    --workdir=$(pwd) `#Run our command inside the docker at the same directory we are invoking the command from` \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix `#Share the same X-server socket as the Docker as our host has. Allows GUIs to write to our display` \
    -e DISPLAY=$DISPLAY `#Share the same X11 display as the Docker as our host has. Allows GUIS to write to our display.` \
    --volume=/etc/passwd:/etc/passwd `#Get the same passwords, users, and groups as our docker as our host. Allows us to be ourselves inside the container.` \
    --volume=/etc/group:/etc/group \
    $GROUP_ADDS \
    --volume=/var/run/docker.sock:/var/run/docker.sock `#And mount the socket on our host inside the container. This way if we are using Docker inside of our build environment it will create containers. That are siblings of this container, not children. Dockers inside of Dockers does have a whole host of issues.` \
    --volume=/etc/localtime:/etc/localtime `#Share the timezone with our host` \
    --volume=/etc/timezone:/etc/timezone \
    --volume=${HOME}:${HOME} `#We set ourselves as the user earlier, and we want the hosts user directory (ours) to appear inside of the container as well.` \
    --volume=${GITROOT}:${GITROOT} `#Mount the current git directory into the container. This makes our git project code, etc. avaliable to the build tools running inside the Docker container` \
    sasquatch-technology-build-environment:${VERSION} "$@" `#Run on our build environment image. The "@" is a bashism that passes in the parameters to this shell script. It makes the shell script a "pass through".`
