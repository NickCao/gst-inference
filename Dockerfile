FROM registry.fedoraproject.org/fedora:42 AS builder
RUN dnf install -y fedora-packager
RUN dnf install -y gcc meson \
  "pkgconfig(gio-2.0)" \
  "pkgconfig(glib-2.0)" \
  "pkgconfig(gstreamer-1.0)" \
  "pkgconfig(gstreamer-base-1.0)" \
  "pkgconfig(gstreamer-check-1.0)" \
  "pkgconfig(libgvc)" \
  "pkgconfig(libxml-2.0)"
COPY ./SPECS /SPECS
WORKDIR /SPECS
RUN spectool -g gst-shark.spec
RUN fedpkg --release f42 local

FROM registry.fedoraproject.org/fedora:42
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN dnf install -y \
  gstreamer1-plugins-base \
  gstreamer1-plugins-good \
  python3-gstreamer1 \
  gcc \
  cairo-devel \
  python3-devel \
  cairo-gobject-devel \
  git-core
RUN git clone --depth 1 https://github.com/collabora/gst-python-ml.git /gst-python-ml
RUN uv pip install --system -r /gst-python-ml/requirements.txt pyopengl
ENV GST_PLUGIN_PATH=/gst-python-ml/plugins
RUN --mount=from=builder,src=/SPECS,dst=/SPECS \
  dnf install -y /SPECS/x86_64/gst-shark-0.8.2-1.fc42.x86_64.rpm
# RUN GST_DEBUG="2" GST_TRACERS="cpuusage;proctime;framerate" GST_SHARK_LOCATION="/tmp/trace" \
#   gst-launch-1.0 v4l2src ! videoconvert ! pyml_yolo model-name=yolo11n ! pyml_overlay ! videoconvert ! autovideosink
