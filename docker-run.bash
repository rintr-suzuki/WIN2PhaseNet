#!/bin/bash

## params
name=$1

## check OS
OSname="Mac-Linux"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OSname="Windows"
fi

## set config
docker_head="sudo"; docker_head_images="sudo"
if [[ $OSname == "Windows" ]]; then
    docker_head="winpty"; docker_head_images=""
fi

if [[ $name == "" ]]; then
    name="win2npz"
fi

if [[ $name == "win2npz" ]]; then
    # win2npz container
    image_name='win2npz'; tag_name='latest'

elif [[ $name == "phasenet" ]]; then
    # phasenet container
    image_name='phasenet'; tag_name='v1.2'

elif [[ $name == "phasenet-old" ]]; then
    # phasenet image for 'release' branch of PhaseNet
    # for WIN2PhaseNet v1.1
    image_name='phasenet'; tag_name='latest'
fi

## pull image
if ! $docker_head_images docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$image_name:$tag_name"; then
    $docker_head docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/$image_name:$tag_name
    $docker_head docker tag ghcr.io/rintr-suzuki/docker-registry-win2phasenet/$image_name:$tag_name $image_name:$tag_name
    $docker_head docker image rm ghcr.io/rintr-suzuki/docker-registry-win2phasenet/$image_name:$tag_name
    # $docker_head docker load -i images/win2npz-image.tar
fi

## run container
workdir=`pwd`
if [[ $name == "win2npz" ]]; then
    $docker_head docker run -it --rm \
    -v $workdir:/data/win2npz \
    $image_name

elif [[ $name == "phasenet" ]] || [[ $name == "phasenet-old" ]]; then
    phasenetdir="$HOME/PhaseNet"
    $docker_head docker run -it --rm \
    -v $phasenetdir:/data/PhaseNet \
    -v $workdir:/data/WIN2PhaseNet \
    $image_name:$tag_name \
    bash
fi