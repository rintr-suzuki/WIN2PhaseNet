#!/bin/bash

name=$1

if [[ $name == "" ]]; then
    name="win2npz"
fi

if [[ $name == "win2npz" ]]; then
    # イメージがない場合はpullする
    image_name='win2npz'
    if ! sudo docker images --format '{{.Repository}}' | grep -q "^$image_name$"; then
        sudo docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/win2npz:latest
        # sudo docker load -i images/win2npz-image.tar
    fi

    # container起動
    workdir=`pwd`
    sudo docker run -it --rm \
    -v $workdir:/data/win2npz \
    $image_name

elif [[ $name == "phasenet" ]]; then
    # イメージがない場合はpullする
    image_name='phasenet'
    if ! sudo docker images --format '{{.Repository}}' | grep -q "^$image_name$"; then
        sudo docker pull ghcr.io/rintr-suzuki/docker-registry-win2phasenet/phasenet:latest
        # sudo docker load -i images/phasenet-image.tar
    fi

    # container起動
    workdir=`pwd`
    phasenetdir="$HOME/PhaseNet"
    sudo docker run -it --rm \
    -v $phasenetdir:/data/PhaseNet \
    -v $workdir:/data/WIN2PhaseNet \
    $image_name \
    /bin/bash
fi

# コンテナから抜ける場合
# container> exit 