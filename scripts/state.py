#!/usr/bin/env python3
import json,os,sys,datetime
cmd=sys.argv[1]
if cmd=='set':
 p=sys.argv[2]; data={}
 if os.path.exists(p):
  try:data=json.load(open(p))
  except Exception:data={}
 for kv in sys.argv[3:]:
  k,v=kv.split('=',1); data[k]=v
 tmp=p+'.tmp'; os.makedirs(os.path.dirname(p),exist_ok=True); json.dump(data,open(tmp,'w'),indent=2,sort_keys=True); os.replace(tmp,p)
elif cmd=='get':
 print(json.load(open(sys.argv[2])).get(sys.argv[3],''))
elif cmd=='history':
 p=sys.argv[2]; d={'time':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 for kv in sys.argv[3:]: k,v=kv.split('=',1); d[k]=v
 os.makedirs(os.path.dirname(p),exist_ok=True)
 with open(p,'a') as f:f.write(json.dumps(d,sort_keys=True)+'\n')
