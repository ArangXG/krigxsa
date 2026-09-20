#!/bin/bash

echo "================================================"
echo " Krig Miner · Pearl (PRL) · AMD/ROCm Startup Check"
echo "================================================"

# Cek ROCm / GPU AMD terdeteksi atau tidak
if command -v rocminfo >/dev/null 2>&1; then
    GPU_COUNT=$(rocminfo 2>/dev/null | grep -c "Marketing Name")
    if [ "$GPU_COUNT" -eq 0 ]; then
        echo "⚠️  WARNING: rocminfo jalan tapi tidak ada GPU AMD terdeteksi!"
        echo "    GPU mining kemungkinan tidak akan berjalan."
    else
        echo "✅ ROCm terdeteksi — $GPU_COUNT GPU AMD ditemukan."
    fi
else
    echo "⚠️  WARNING: rocminfo tidak ditemukan di dalam container!"
    echo "    Pastikan host sudah install driver amdgpu + ROCm,"
    echo "    dan container dijalankan dengan --device=/dev/kfd --device=/dev/dri"
fi

# Validasi ENV wajib
MISSING=0

if [ -z "$PRL_WALLET" ]; then
    echo "❌ PRL_WALLET belum diisi!"
    MISSING=1
fi

if [ -z "$PRL_POOL" ]; then
    echo "❌ PRL_POOL belum diisi! (contoh: stratum+ssl://prl.kryptex.network:8048)"
    MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
    echo ""
    echo "Isi semua ENV yang wajib lalu restart container."
    exit 1
fi

# Gabungkan wallet + worker jadi satu string "wallet/worker"
# karena Krig pakai format ini di flag --user (bukan titik seperti SRBMiner)
if [ -n "$PRL_WORKER" ]; then
    FULL_USER="${PRL_WALLET}/${PRL_WORKER}"
else
    FULL_USER="$PRL_WALLET"
fi

echo ""
echo " PRL_POOL   : $PRL_POOL"
echo " PRL_WORKER : $PRL_WORKER"
echo " USER       : $FULL_USER"
echo "================================================"
echo ""

/usr/local/bin/krig-miner \
    --url "$PRL_POOL" \
    --user "$FULL_USER" \
    --no-cuda \
    ${KRIG_EXTRA_ARGS} 2>&1

EXIT_CODE=$?

echo ""
echo "❌ Krig miner berhenti dengan exit code: $EXIT_CODE"
exit $EXIT_CODE
