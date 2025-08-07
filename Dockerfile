FROM registry.fedoraproject.org/fedora:42
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN dnf install -y gstreamer1 gstreamer1-plugins-good
RUN <<EOF
set -euxo pipefail
dnf install -y git-core meson ninja-build
dnf install -y gcc glib2-devel gstreamer1-devel graphviz-devel
git clone https://github.com/RidgeRun/gst-shark/
EOF
RUN <<EOF
set -euxo pipefail
cd gst-shark
meson setup builddir --prefix /usr/
meson compile -C builddir
meson install -C builddir
EOF
# RUN GST_DEBUG="GST_TRACER:7" GST_TRACERS="cpuusage;proctime;framerate" \
#   gst-launch-1.0 videotestsrc ! videorate max-rate=15 ! fakesink
