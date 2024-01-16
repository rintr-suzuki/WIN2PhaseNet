#!/bin/bash

name=$1

## check OS
OSname="Mac-Linux"
which ipconfig # only exists Windows
if [[ $? == 0 ]]; then # check exit code
    OSname="Windows"
fi

## set config
docker_head="sudo"
if [[ $OSname == "Windows" ]]; then
    docker_head="winpty"
fi

if [[ $name == "" ]]; then
    name="win2npz"
fi

## pull and run win2npz container
if [[ $name == "win2npz" ]]; then
    # イメージがない場合はpullする
    image_name='win2npz'
    if ! $docker_head docker images --format '{{.Repository}}' | grep -q "^$image_name$"; then
        $docker_head docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/win2npz:latest
        $docker_head docker tag ghcr.io/rintr-suzuki/docker-registry-win2phasenet/win2npz:latest win2npz:latest
        $docker_head docker image rm ghcr.io/rintr-suzuki/docker-registry-win2phasenet/win2npz:latest
        # $docker_head docker load -i images/win2npz-image.tar
    fi

    # container起動
    workdir=`pwd`
    $docker_head docker run -it --rm \
    -v $workdir:/data/win2npz \
    $image_name

## pull and run phasenet container
elif [[ $name == "phasenet" ]]; then
    # イメージがない場合はpullする
    image_name='phasenet'; tag_name='v1.2'
    if ! $docker_head docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$image_name:$tag_name"; then
        $docker_head docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:v1.2
        $docker_head docker tag ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:v1.2 phasenet:v1.2
        $docker_head docker image rm ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:v1.2
        # $docker_head docker load -i images/phasenet-image.tar
    fi

    # container起動
    workdir=`pwd`
    phasenetdir="$HOME/PhaseNet"
    $docker_head docker run -it --rm \
    -v $phasenetdir:/data/PhaseNet \
    -v $workdir:/data/WIN2PhaseNet \
    $image_name:$tag_name \
    bash

# phasenet image for 'release' branch of PhaseNet
# for WIN2PhaseNet v1.1
elif [[ $name == "phasenet-old" ]]; then
    # イメージがない場合はpullする
    image_name='phasenet'; tag_name='latest'
    if ! $docker_head docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$image_name:$tag_name"; then
        $docker_head docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:latest
        $docker_head docker tag ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:latest phasenet:latest
        $docker_head docker image rm ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:latest
        # $docker_head docker load -i images/phasenet-image.tar
    fi

    # container起動
    workdir=`pwd`
    phasenetdir="$HOME/PhaseNet"
    $docker_head docker run -it --rm \
    -v $phasenetdir:/data/PhaseNet \
    -v $workdir:/data/WIN2PhaseNet \
    $image_name:$tag_name \
    /bin/bash
fi

# コンテナから抜ける場合
# container> exit 