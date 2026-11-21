#!/usr/bin/env python3
import os
import socket
import struct
import sys

root = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
sink = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sink.bind(('192.168.2.1', 69))

while True:
    request, client = sink.recvfrom(1024)
    if struct.unpack('!H', request[:2])[0] != 1:
        continue
    name = request[2:].split(b'\0')[0].decode(errors='replace').lstrip('/')
    path = os.path.join(root, name)
    print(client[0], 'RRQ', name, 'ok' if os.path.isfile(path) else 'missing', flush=True)
    if not os.path.isfile(path):
        sink.sendto(struct.pack('!HH', 5, 1) + b'not found\0', client)
        continue
    data = open(path, 'rb').read()
    reply = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    reply.settimeout(3)
    for block in range(1, (len(data) + 511) // 512 + 1):
        chunk = data[(block - 1) * 512:block * 512]
        packet = struct.pack('!HH', 3, block) + chunk
        for _ in range(5):
            reply.sendto(packet, client)
            try:
                ack = reply.recvfrom(1024)[0]
            except socket.timeout:
                continue
            if struct.unpack('!HH', ack[:4]) == (4, block):
                break
        if len(chunk) < 512:
            break
    reply.close()
