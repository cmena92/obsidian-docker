#!/bin/bash
# Inyectar flags de GPU software para entorno virtual (Docker/Xvfb)
# Sin estos flags el renderer de Electron crashea en contenedores sin GPU física

sed -i 's|--no-sandbox \\|--no-sandbox \\\n  --disable-gpu \\\n  --disable-gpu-sandbox \\\n  --use-gl=swiftshader \\\n  --disable-dev-shm-usage \\\n  --disable-software-rasterizer \\|g' /usr/bin/obsidian
