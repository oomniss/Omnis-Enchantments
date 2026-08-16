#!/usr/bin/env bash

# ============================================================
#  Omins's Enchantments — Auto-Sync Resource Pack
#  Monitora alterações na pasta e sincroniza o .zip automaticamente
#  Compatível com Zorin OS (inotify-tools)
# ============================================================

# ── Configurações ───────────────────────────────────────────
WATCH_DIR="/home/murilofacchini/Documentos/Omnis's Enchantments"
DEST_DIR="/home/murilofacchini/.var/app/com.modrinth.ModrinthApp/data/ModrinthApp/profiles/Fabric 1.21.11/resourcepacks"
ZIP_NAME="§lOminis'§l §d§lEnchantments§l§d.zip"
DEST_ZIP="$DEST_DIR/$ZIP_NAME"

# ── Verificações iniciais ────────────────────────────────────
check_dependencies() {
    if ! command -v inotifywait &>/dev/null; then
        echo ""
        echo "  ╔══════════════════════════════════════════════════════╗"
        echo "  ║  ATENÇÃO: inotify-tools não encontrado!              ║"
        echo "  ║  Instale com:                                        ║"
        echo "  ║    sudo apt install inotify-tools                    ║"
        echo "  ╚══════════════════════════════════════════════════════╝"
        echo ""
        exit 1
    fi
}

check_paths() {
    if [ ! -d "$WATCH_DIR" ]; then
        echo "  ✗ Pasta de origem não encontrada:"
        echo "    $WATCH_DIR"
        exit 1
    fi
    if [ ! -d "$DEST_DIR" ]; then
        echo "  ✗ Pasta de destino não encontrada:"
        echo "    $DEST_DIR"
        exit 1
    fi
}

# ── Função principal de sincronização ───────────────────────
sync_pack() {
    local TIMESTAMP
    TIMESTAMP=$(date '+%H:%M:%S')

    echo ""
    echo "  [$TIMESTAMP] Alteração detectada! Sincronizando..."

    # Passo 1: Remove o zip antigo, se existir
    if [ -f "$DEST_ZIP" ]; then
        rm -f "$DEST_ZIP"
        echo "  ✓ Arquivo antigo removido: $ZIP_NAME"
    else
        echo "  ℹ Nenhum zip anterior encontrado (primeira execução)"
    fi

    # Passo 2: Compacta a pasta de origem em um novo .zip
    PARENT_DIR=$(dirname "$WATCH_DIR")
    FOLDER_NAME=$(basename "$WATCH_DIR")

    cd "$WATCH_DIR" || { echo "  ✗ Erro ao acessar pasta de origem"; return 1; }

    zip -rq "$DEST_ZIP" ./*

    if [ $? -eq 0 ]; then
        local SIZE
        SIZE=$(du -sh "$DEST_ZIP" 2>/dev/null | cut -f1)
        echo "  ✓ Novo zip criado com sucesso: $ZIP_NAME ($SIZE)"
        echo "  → Destino: $DEST_DIR"
    else
        echo "  ✗ Erro ao criar o arquivo zip!"
        return 1
    fi

    echo "  ─────────────────────────────────────────────────────"
}

# ── Debounce: evita múltiplas execuções em sequência ────────
LAST_RUN=0
DEBOUNCE_SECS=2

should_run() {
    local NOW
    NOW=$(date +%s)
    local DIFF=$(( NOW - LAST_RUN ))
    if [ "$DIFF" -ge "$DEBOUNCE_SECS" ]; then
        LAST_RUN=$NOW
        return 0
    fi
    return 1
}

# ── Inicialização ────────────────────────────────────────────
main() {
    check_dependencies
    check_paths

    echo ""
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║      Ominis's Enchantments — Auto-Sync Ativo         ║"
    echo "  ╠══════════════════════════════════════════════════════╣"
    echo "  ║  Monitorando: Ominis's Enchantments/                 ║"
    echo "  ║  Destino: test vulkan/resourcepacks/                 ║"
    echo "  ║  Pressione Ctrl+C para encerrar                      ║"
    echo "  ╚══════════════════════════════════════════════════════╝"

    # Sincroniza imediatamente ao iniciar
    sync_pack

    # ── Loop de monitoramento ────────────────────────────────
    inotifywait -m -r \
        -e modify -e create -e delete -e move \
        --format '%T %e %w%f' \
        --timefmt '%H:%M:%S' \
        "$WATCH_DIR" 2>/dev/null | \
    while read -r LINE; do
        if should_run; then
            sync_pack
        fi
    done
}

trap 'echo ""; echo "  ✓ Monitoramento encerrado."; echo ""; exit 0' SIGINT SIGTERM

main
