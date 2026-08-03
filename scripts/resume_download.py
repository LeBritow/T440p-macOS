import argparse
import os
import sys
from urllib.parse import urlparse
from urllib.request import Request, urlopen

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import macrecovery

BID = 'Mac-226CB3C6A851A671'
MLB = '00000000000000000'
OUTDIR = 'com.apple.recovery.boot'
DMG = os.path.join(OUTDIR, 'BaseSystem.dmg')
CNK = os.path.join(OUTDIR, 'BaseSystem.chunklist')

ns = argparse.Namespace(verbose=False)
session = macrecovery.get_session(ns)
info = macrecovery.get_image_info(session, bid=BID, mlb=MLB, os_type='default')

url = info[macrecovery.INFO_IMAGE_LINK]
sess = info[macrecovery.INFO_IMAGE_SESS]

existing = os.path.getsize(DMG) if os.path.exists(DMG) else 0
print('Asset:', info[macrecovery.INFO_PRODUCT])
print('URL:', url)
print('Resuming from byte:', existing)

purl = urlparse(url)
headers = {
    'Host': purl.hostname,
    'Connection': 'close',
    'User-Agent': 'InternetRecovery/1.0',
    'Cookie': 'AssetToken=' + sess,
}
if existing > 0:
    headers['Range'] = 'bytes=%d-' % existing

req = Request(url=url, headers=headers)
resp = urlopen(req)

if resp.status == 206:
    mode = 'ab'
    print('Server accepted byte range, appending...')
elif resp.status == 200:
    mode = 'wb'
    print('Server ignored range request, restarting from 0...')
else:
    print('Unexpected HTTP status:', resp.status)
    sys.exit(1)

size = existing if mode == 'ab' else 0
with open(DMG, mode) as fh:
    while True:
        chunk = resp.read(2 ** 20)
        if not chunk:
            break
        fh.write(chunk)
        size += len(chunk)
        print('\r%0.1f MB downloaded...' % (size / (2 ** 20)), end='')
        sys.stdout.flush()
print('\nDownload complete! Total size:', size)

print('Verifying image with chunklist...')
macrecovery.verify_image(DMG, CNK)
print('Image verification complete!')
