# Obsidian Docker

Obsidian corriendo en Docker con acceso web (KasmVNC), REST API y MCP para integración con agentes IA.

## Stack

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| Obsidian GUI | `3010` → nginx `443` | Interfaz visual via browser (KasmVNC) |
| Local REST API | `27123` | CRUD de notas para agentes IA |
| MCP Server | `3001` | Protocolo MCP para Claude y otros |

## Servidor (contexto)

Este servidor ya corre:
- Odoo 19 → `asuacr.com`, `comoro.biz`
- Yii2 app → `feres44.webcomcr.com`, `webcomcr.com`
- Mail server (SMTP/IMAP)
- Minecraft panel

**Recursos disponibles:** ~1.5GB RAM libre, 3.2GB disco libre (ajustar si se amplía disco)

## Instalación

```bash
# 1. Clonar
git clone https://github.com/cmena92/obsidian-docker.git
cd obsidian-docker

# 2. Configurar variables
cp .env.example .env
# editar .env con tu API key (después del paso 4)

# 3. Levantar Obsidian
docker compose up -d obsidian

# 4. Abrir http://IP_SERVIDOR:3010 en el browser
#    → Instalar plugin "Local REST API" en Obsidian
#    → Copiar el API Key generado → pegarlo en .env

# 5. Levantar el MCP server
docker compose up -d mcp-obsidian

# 6. (Opcional) Configurar nginx con SSL
sudo cp nginx/obsidian.conf /etc/nginx/sites-enabled/obsidian.conf
# Editar dominios en el archivo
sudo certbot --nginx -d obsidian.tudominio.com
sudo nginx -t && sudo nginx -s reload

# 7. (Opcional) Proteger la GUI con usuario/contraseña
sudo htpasswd -c /etc/nginx/.htpasswd_obsidian tu_usuario
```

## Uso desde agentes IA

### REST API directa

```bash
# Crear nota
curl -X PUT https://obsidian-api.tudominio.com/vault/MiNota.md \
  -H "Authorization: Bearer TU_API_KEY" \
  -H "Content-Type: text/markdown" \
  --data "# Nota\n\nContenido creado por IA"

# Leer nota
curl https://obsidian-api.tudominio.com/vault/MiNota.md \
  -H "Authorization: Bearer TU_API_KEY"

# Buscar
curl "https://obsidian-api.tudominio.com/search/simple/?query=proyecto" \
  -H "Authorization: Bearer TU_API_KEY"
```

### MCP (Claude Desktop / Claude Code)

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["-y", "mcp-obsidian"],
      "env": {
        "OBSIDIAN_API_KEY": "tu_api_key",
        "OBSIDIAN_HOST": "https://obsidian-api.tudominio.com"
      }
    }
  }
}
```

## Persistencia de datos

El vault vive en `./vault/` en el host. Si el contenedor muere, los archivos `.md` permanecen intactos.

### Backup manual
```bash
tar -czf backup-vault-$(date +%Y%m%d).tar.gz ./vault/
```

### Backup automático con cron
```bash
# crontab -e
0 2 * * * cd /opt/projects/obsidian-docker && tar -czf /backups/vault-$(date +\%Y\%m\%d).tar.gz ./vault/
```

## Advertencias del servidor

- **Disco al 96%** — Antes de levantar, verificar espacio: `df -h /`
  - La imagen de Obsidian pesa ~2GB
  - Recomendado: limpiar imágenes Docker no usadas: `docker image prune -a`
- **RAM limitada** — El contenedor tiene `mem_limit: 1g` para no afectar Odoo y el mail server
