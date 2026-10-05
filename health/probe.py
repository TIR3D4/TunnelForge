#!/usr/bin/env python3
import argparse,socket,time,os,sys
p=argparse.ArgumentParser();p.add_argument('host');p.add_argument('port',type=int);p.add_argument('--token-file',required=True);p.add_argument('--bytes',type=int,default=0);p.add_argument('--timeout',type=float,default=5);a=p.parse_args();token=open(a.token_file).read().strip();t=time.perf_counter()
try:
 s=socket.create_connection((a.host,a.port),a.timeout);s.settimeout(a.timeout)
 if not a.bytes:s.sendall(f'PING {token}\n'.encode());out=s.recv(256);ok=out.strip()==f'PONG {token}'.encode();amount=len(out)
 else:
  payload=os.urandom(a.bytes);s.sendall(f'ECHO {token} {len(payload)}\n'.encode());s.sendall(payload);out=b''
  while len(out)<len(payload):
   c=s.recv(min(65536,len(payload)-len(out)))
   if not c:break
   out+=c
  ok=out==payload;amount=len(payload)*2
 e=time.perf_counter()-t;s.close();print(f'ok={str(ok).lower()} elapsed_ms={e*1000:.2f} bytes={amount} mbps={(amount*8/e/1e6 if e else 0):.2f}');sys.exit(0 if ok else 1)
except Exception as x:print(f'ok=false error={x}',file=sys.stderr);sys.exit(1)
