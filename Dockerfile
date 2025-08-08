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
RUN dnf install -y gstreamer1-plugins-good
RUN --mount=from=builder,src=/SPECS,dst=/SPECS \
  dnf install -y /SPECS/x86_64/gst-shark-0.8.2-1.fc42.x86_64.rpm
RUN GST_DEBUG="GST_TRACER:7" GST_TRACERS="cpuusage;proctime;framerate" \
  gst-launch-1.0 videotestsrc ! videorate max-rate=15 ! fakesink num-buffers=60
