#!/usr/bin/env python3
import argparse,concurrent.futures,socket,time,statistics,os
p=argparse.ArgumentParser();p.add_argument('--host',default='127.0.0.1');p.add_argument('--port',type=int,required=True);p.add_argument('--token-file',required=True);p.add_argument('--connections',type=int,default=1);p.add_argument('--bytes',type=int,default=262144);p.add_argument('--timeout',type=float,default=10);a=p.parse_args();token=open(a.token_file).read().strip();payload=os.urandom(a.bytes)
def one(_):
 t=time.perf_counter()
 try:
  s=socket.create_connection((a.host,a.port),a.timeout);s.settimeout(a.timeout);s.sendall(f'ECHO {token} {len(payload)}\n'.encode());s.sendall(payload);n=0
  while n<len(payload):
   c=s.recv(min(65536,len(payload)-n))
   if not c:break
   n+=len(c)
  s.close();return n==len(payload),time.perf_counter()-t
 except Exception:return False,time.perf_counter()-t
start=time.perf_counter();
with concurrent.futures.ThreadPoolExecutor(max_workers=min(a.connections,512)) as ex:r=list(ex.map(one,range(a.connections)))
e=time.perf_counter()-start;ok=[x[1] for x in r if x[0]];n=len(ok);b=n*a.bytes*2;print(f'connections={a.connections} success={n} failed={a.connections-n} elapsed_s={e:.3f}');
if ok:print(f'latency_ms_p50={statistics.median(ok)*1000:.2f} latency_ms_max={max(ok)*1000:.2f} throughput_mbps={b*8/e/1e6:.2f} establishment_rate_cps={n/e:.2f}')
raise SystemExit(0 if n==a.connections else 1)
