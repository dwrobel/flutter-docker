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

FROM fedora:32

LABEL maintainer="dwrobel@ertelnet.rybnik.pl" description="Podman/Docker image for cross compiling flutter apps for CPE"

RUN dnf install -y ccache git-core sudo

RUN echo >/etc/sudoers.d/wheel-no-passwd '%wheel	ALL=(ALL)	NOPASSWD: ALL'

RUN dnf update -y

RUN dnf install -y binutils rsync buildah which file xz cpio unzip cmake ninja-build clang pkgconfig\(gtk+-3.0\) weston mesa-dri-drivers xorg-x11-server-Xvfb findutils python3-xlrd

COPY sdk-docker /
ADD flutter-wayland-test-app-image /sdk/flutter/bin/

RUN rm -rf /flutter-wayland-app/files/flutter-wayland-app.tar
RUN chmod -R a+rwx /sdk
RUN chmod a+w /flutter-wayland-app/files
RUN echo r50 >/sdk-release

RUN dnf clean all
ADD entrypoint.sh /
