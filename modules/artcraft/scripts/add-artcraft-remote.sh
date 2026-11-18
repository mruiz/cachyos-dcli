#!/bin/bash
set -e
# user installs can't pull runtimes from system remotes, so flathub is needed in user scope too
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists --user artcraft https://getartcraft.com/artcraft-oci.flatpakrepo
