FROM debian:12.8-slim AS source
RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      ca-certificates && \
    echo "progress = bar:force:noscroll" > ~/.wgetrc && \
    wget --show-progress -qO- "https://github.com/Figma-Linux/figma-linux-font-helper/archive/refs/tags/v0.1.8.tar.gz" \
        | tar xzf - --transform='s|^[^/]*/|figma-fonthelper/|'

FROM rust:1.84-slim-bookworm AS binary
WORKDIR /app
COPY --from=source /figma-fonthelper .
RUN cargo build --release

FROM debian:12.8-slim
COPY --from=binary /app/target/release/font_helper /fonthelper
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
