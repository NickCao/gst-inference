FROM registry.fedoraproject.org/fedora:42
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN dnf install -y gstreamer1 gstreamer1-plugins-good
RUN GST_DEBUG="GST_TRACER:7" gst-launch-1.0 videotestsrc ! videorate max-rate=15 ! fakesink
