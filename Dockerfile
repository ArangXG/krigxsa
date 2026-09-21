FROM rocm/dev-ubuntu-24.04:7.2

RUN apt-get update && apt-get install -y \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Auto-deteksi link download krig-miner TERBARU langsung dari halaman resmi
# miner.download (khusus krig, jadi nggak ketimpa rilis produk lain kayak
# kalau ambil dari API GitHub repo mono-releases-nya Kryptex).
# CACHEBUST dikasih nilai unik dari workflow tiap run, biar layer ini
# selalu dicek ulang (nggak ke-cache Docker) dan bisa nangkep rilis baru.
ARG CACHEBUST=1
RUN KRIG_URL=$(wget -qO- https://miner.download/en/krig/description/ \
        | grep -oE 'https://github\.com/kryptex-miners-org/kryptex-miners/releases/download/[^"]+linux-x64\.tar\.gz' \
        | head -n1) \
    && test -n "$KRIG_URL" \
    && echo ">>> URL krig-miner terdeteksi: $KRIG_URL" \
    && wget -q "$KRIG_URL" -O /tmp/krig.tar.gz \
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
