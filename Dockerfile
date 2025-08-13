# FROM registry.fedoraproject.org/fedora:41 AS builder
# RUN dnf install -y fedora-packager
# RUN dnf install -y gcc meson \
#   "pkgconfig(gio-2.0)" \
#   "pkgconfig(glib-2.0)" \
#   "pkgconfig(gstreamer-1.0)" \
#   "pkgconfig(gstreamer-base-1.0)" \
#   "pkgconfig(gstreamer-check-1.0)" \
#   "pkgconfig(libgvc)" \
#   "pkgconfig(libxml-2.0)"
# COPY ./gst-shark /SPECS
# WORKDIR /SPECS
# RUN spectool -g gst-shark.spec
# RUN fedpkg --release f42 local

FROM registry.fedoraproject.org/fedora:41
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN dnf copr enable -y ncaorh/gst-shark
RUN dnf install -y \
  gst-shark \
  gstreamer1 \
  gstreamer1-plugins-base \
  gstreamer1-plugins-base-tools \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-ugly-free \
  gstreamer1-rtsp-server \
  python3-devel \
  python3-pip \
  python3-gstreamer1 \
  libglvnd-gles \
  gcc \
  cairo-devel \
  cairo-gobject-devel \
  yaml-cpp \
  bsdtar \
  git-core
RUN git clone --depth 1 https://github.com/collabora/gst-python-ml.git /gst-python-ml
RUN uv pip install --system -r /gst-python-ml/requirements.txt pyopengl --torch-backend cpu
ENV GST_PLUGIN_PATH=/gst-python-ml/plugins

RUN curl -L 'https://api.ngc.nvidia.com/v2/resources/org/nvidia/deepstream/7.1/files?redirect=true&path=deepstream_sdk_v7.1.0_jetson.tbz2' -o /tmp/deepstream_sdk_v7.1.0_jetson.tbz2 && \
  bsdtar xf /tmp/deepstream_sdk_v7.1.0_jetson.tbz2 -C / && \
  /opt/nvidia/deepstream/deepstream-7.1/install.sh && \
  rm /tmp/deepstream_sdk_v7.1.0_jetson.tbz2

ENV GST_PLUGIN_PATH=/opt/nvidia/deepstream/deepstream/lib/gst-plugins:${GST_PLUGIN_PATH}

# RUN GST_DEBUG="2" GST_TRACERS="cpuusage;proctime;framerate" GST_SHARK_LOCATION="/tmp/trace" \
#   gst-launch-1.0 v4l2src ! videoconvert ! pyml_yolo model-name=yolo11n ! pyml_overlay ! videoconvert ! autovideosink
