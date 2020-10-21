#!/bin/bash -xe
#
# Copyright (C) 2018-2020 Damian Wrobel <dwrobel@ertelnet.rybnik.pl>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# Wraps commands with docker
#
# Usage: flutter-wrapper.sh <command-to-execute-within-container>
#
# Note: It has also access to the entire $HOME directory

CWD=$PWD

DIRECTORY=$(cd `dirname $0` && pwd)

if [ $# -lt 1 ]; then
    set +x
    echo ""
    echo "docker/podman wrapper by Damian Wrobel <dwrobel@ertelnet.rybnik.pl>"
    echo ""
    echo "      Usage: $0 <command-to-execute-within-container>"
    echo "    Example: $0 bash"
    echo ""
    exit 1
fi

DOCKER_CMD=$(which podman || which docker)

config_file="${DW_CONFIG_PATH:-${HOME}/.config/docker-wrapper.sh/dw-config.conf}"

if [ -e "${config_file}" ]; then
    # Allows to specify additional options to docker build/run commands
    # DOCKER_BUILD=("--pull=false")
    # DOCKER_RUN=("-v" "/data:/data")
    source "${config_file}"
fi

if [ -z "${DOCKER_IMG}" ]; then
    DOCKER_IMG=docker.io/dwrobel/flutter-wrapper:latest
    #echo sudo ${DOCKER_CMD} build --network=host "${DOCKER_BUILD[@]}" -t ${DOCKER_IMG} $DIRECTORY
    #exit 0
fi

VDIR="$HOME"

if [ -n "${DISPLAY}" ]; then
    display_opts="-e DISPLAY=$DISPLAY"
fi

if [ -n "${WAYLAND_DISPLAY}" ]; then
    wayland_display_opts="-e WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
fi

if [ -n "${XDG_RUNTIME_DIR}" ]; then
    xdg_runtime_opts="-e XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} -v ${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}"
fi

if [ -n "${CC}" ]; then
    cc_opts="-e CC=$CC"
fi

if [ -n "${CXX}" ]; then
    cxx_opts="-e CXX=$CXX"
fi

if [ -n "${SEMAPHORE_CACHE_DIR}" ]; then
    cache_dir="-e CACHE_DIR=$SEMAPHORE_CACHE_DIR"
fi

test -t 1 && USE_TTY="-t"

sudo ${DOCKER_CMD} run --network=host "${DOCKER_RUN[@]}" --entrypoint=/entrypoint.sh --privileged -p 3389:3389 -v /dev/dri:/dev/dri -i ${USE_TTY} ${cache_dir} ${cc_opts} ${cxx_opts} ${wayland_display_opts} -e USER=$USER -e UID=$UID -e GID=$(id -g $USER) -e CWD="$CWD" ${display_opts} ${xdg_runtime_opts} -v /tmp/.X11-unix:/tmp/.X11-unix -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v "${VDIR}":"${VDIR}" ${DOCKER_IMG} "$@"
