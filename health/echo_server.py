#!/usr/bin/env python3
import argparse,socketserver
p=argparse.ArgumentParser();p.add_argument('--bind',default='0.0.0.0');p.add_argument('--port',type=int,required=True);p.add_argument('--token-file',required=True);a=p.parse_args();token=open(a.token_file).read().strip().encode()
class H(socketserver.BaseRequestHandler):
 def handle(self):
  self.request.settimeout(8);line=b''
  while not line.endswith(b'\n') and len(line)<4096:
   x=self.request.recv(1)
   if not x:return
   line+=x
  q=line.strip().split()
  if len(q)<2 or q[1]!=token:return
  if q[0]==b'PING':self.request.sendall(b'PONG '+token+b'\n');return
  if q[0]==b'ECHO' and len(q)==3:
   n=int(q[2])
   while n:
    c=self.request.recv(min(65536,n))
    if not c:return
    self.request.sendall(c);n-=len(c)
class S(socketserver.ThreadingTCPServer):allow_reuse_address=True;daemon_threads=True
with S((a.bind,a.port),H) as s:s.serve_forever()
