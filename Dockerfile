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
RUN dnf install -y gstreamer1-plugins-base gstreamer1-plugins-good python3-gstreamer1
RUN dnf install -y gcc
RUN dnf install -y cairo-devel
RUN dnf install -y python3-devel
RUN dnf install -y cairo-gobject-devel
RUN dnf install -y git-core
RUN uv pip install --system \
  pygobject pycairo torch torchvision transformers numpy ultralytics \
  git+https://github.com/collabora/gst-python-ml.git
RUN git clone --depth 1 https://github.com/collabora/gst-python-ml.git /gst-python-ml
ENV GST_PLUGIN_PATH=/gst-python-ml/plugins
RUN --mount=from=builder,src=/SPECS,dst=/SPECS \
  dnf install -y /SPECS/x86_64/gst-shark-0.8.2-1.fc42.x86_64.rpm
RUN GST_DEBUG="4" GST_TRACERS="cpuusage;proctime;framerate" \
  gst-launch-1.0 videotestsrc ! videorate max-rate=15 ! pyml_yolo model-name=yolo11m track=True ! pyml_overlay ! fakesink num-buffers=60
