# krig-amd

Docker image buat mining Pearl (PRL) pakai **Krig miner** di GPU **AMD (ROCm)**.
Pasangan dari repo `pelxsa` kamu yang pakai SRBMiner-MULTI + NVIDIA.

## Build

```bash
docker build -t krig-amd .
```

## Jalankan

```bash
docker run -d \
  --name krig-amd \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --group-add render \
  -e PRL_POOL="stratum+ssl://prl.kryptex.network:8048" \
  -e PRL_WALLET="prl1yourwallet" \
  -e PRL_WORKER="myworker" \
  krig-amd
```

## Catatan penting

- **Format wallet berbeda dari SRBMiner.** Krig pakai `--user wallet/worker`
  (dipisah slash `/`), bukan `wallet.worker` (titik) seperti SRBMiner-MULTI.
  Sudah ditangani otomatis di `entrypoint.sh`.
- **`--device=/dev/kfd` dan `--device=/dev/dri` wajib** di-mount ke container
  supaya ROCm bisa lihat GPU AMD dari host. Tanpa ini, `rocminfo` di dalam
  container tidak akan mendeteksi apa-apa.
- Host tetap harus sudah install driver `amdgpu` + ROCm kernel module —
  image ini cuma bawa ROCm userspace + krig-miner, bukan driver kernel.
- **Krig SSL-only**, jadi `--url` wajib pakai skema `stratum+ssl://`.
- Kalau mau tambah flag lain (misal `--devices 0,1` atau `--rocm-runtime 7`),
  isi lewat ENV `KRIG_EXTRA_ARGS`, contoh:
  `-e KRIG_EXTRA_ARGS="--rocm-runtime 7"`
- Kalau Krig rilis versi baru, update `ARG KRIG_VERSION` di Dockerfile —
  jangan lupa cek nama tag di GitHub release-nya karena formatnya
  `krig-<major>-<minor>-<patch>`.
