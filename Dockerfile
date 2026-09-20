FROM rocm/dev-ubuntu-22.04:6.2

RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download & install krig-miner (build Linux x64) langsung dari release resmi Kryptex.
# Kalau versinya sudah update, ganti URL ini sesuai versi terbaru di
# https://github.com/kryptex-miners-org/kryptex-miners/releases
ARG KRIG_VERSION=1.5.1
RUN wget -q "https://github.com/kryptex-miners-org/kryptex-miners/releases/download/krig-${KRIG_VERSION//./-}/krig-miner-${KRIG_VERSION}-linux-x64.tar.gz" -O /tmp/krig.tar.gz \
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
