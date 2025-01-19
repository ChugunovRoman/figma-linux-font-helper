FROM debian:12.8-slim AS binary
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
      xz-utils && \
    echo "progress = bar:force:noscroll" > ~/.wgetrc && \
    wget --show-progress -qO- "http://github.com/Figma-Linux/figma-linux-font-helper/releases/download/v0.1.8/fonthelper.tar.xz" \
        | tar xJf - ./fonthelper && \
    chmod +x /app/fonthelper

FROM debian:12.8-slim
COPY --from=binary /app/fonthelper /fonthelper
RUN useradd user && \
    install -vpdo user /home/user/.config/figma-linux /home/user/.cache/figma-fonthelper && \
    tee <<EOF /home/user/.config/figma-linux/settings.json
{
    "host": "0.0.0.0",
    "port": "44950",
    "app": {
        "fontDirs": [
            "/usr/share/fonts"
        ]
    }
}
EOF
USER user
CMD ["/fonthelper"]
