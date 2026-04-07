#!/bin/bash
# Espera a que el plugin arranque en 127.0.0.1:27124
# y hace forward TCP puro a 0.0.0.0:27125

(
    while ! nc -z 127.0.0.1 27124 2>/dev/null; do
        sleep 3
    done

    /lsiopy/bin/python3 - << 'PYEOF'
import socket, threading

def forward(src, dst):
    try:
        while True:
            data = src.recv(4096)
            if not data:
                break
            dst.sendall(data)
    except:
        pass
    finally:
        try: src.close()
        except: pass
        try: dst.close()
        except: pass

def handle(client):
    try:
        server = socket.create_connection(('127.0.0.1', 27124))
        threading.Thread(target=forward, args=(client, server), daemon=True).start()
        forward(server, client)
    except Exception as e:
        try: client.close()
        except: pass

srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(('0.0.0.0', 27125))
srv.listen(50)
while True:
    c, _ = srv.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
PYEOF
) &
