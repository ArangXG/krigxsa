FROM rocm/dev-ubuntu-24.04:7.2

RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Auto-deteksi rilis krig-miner TERBARU dari GitHub setiap kali image di-build,
# jadi nggak perlu update ARG KRIG_VERSION manual lagi.
# CACHEBUST dikasih nilai unik dari workflow tiap run, biar layer ini
# selalu dicek ulang (nggak ke-cache Docker) dan bisa nangkep rilis baru.
ARG CACHEBUST=1
RUN KRIG_TAG=$(wget -qO- https://api.github.com/repos/kryptex-miners-org/kryptex-miners/releases \
        | jq -r '[.[] | select(.tag_name | startswith("krig-"))][0].tag_name') \
    && KRIG_VERSION=$(echo "$KRIG_TAG" | sed -E 's/^krig-//; s/-/./g') \
    && echo ">>> Rilis krig-miner terdeteksi: $KRIG_VERSION ($KRIG_TAG)" \
    && wget -q "https://github.com/kryptex-miners-org/kryptex-miners/releases/download/${KRIG_TAG}/krig-miner-${KRIG_VERSION}-linux-x64.tar.gz" -O /tmp/krig.tar.gz \
    && mkdir -p /tmp/krig \
    && tar -xzf /tmp/krig.tar.gz -C /tmp/krig \
    && find /tmp/krig -type f -name "krig-miner" -exec cp {} /usr/local/bin/krig-miner \; \
    && chmod +x /usr/local/bin/krig-miner \
    && rm -rf /tmp/krig /tmp/krig.tar.gz

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ── GPU Mining · Krig · Pearl (PRL) · AMD/ROCm ───────────────
ENV PRL_POOL=
ENV PRL_WALLET=
ENV PRL_WORKER=
ENV KRIG_EXTRA_ARGS=

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
