"""Local mock of the glamifyy.shop endpoints the app uses, for UI checks and screenshots.

Usage: python3 tool/mock/server.py [port]  (serves build/web at / and the API on the same origin)
"""
import json, re, sys, os
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

ROOT = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(ROOT, '..', '..', 'build', 'web')
P = [
  (415, 'Beurre Capillaire Nourrissant au Chébé &#038; Karité', 4500, [16, 45], 'Beurre capillaire naturel enrichi en Chébé et karité pour nourrir et protéger les longueurs.'),
  (407, 'Soin Fortifiant au Sidr, Noyaux de Datte &amp; Réglisse', 4500, [16, 45], 'Soin densifiant aux plantes pour des cheveux plus forts.'),
  (413, 'Gel Hydratant Intense au Lin &#038; Cresson', 2500, [16, 45], 'Gel au lin et cresson qui hydrate et définit les boucles.'),
  (403, 'Gommage Purifiant du Cuir Chevelu', 3000, [16, 17], 'Gommage doux qui purifie le cuir chevelu.'),
  (417, 'Touche de Soie &#038; Parfum Capillaire', 3000, [16], 'Soin sans rinçage qui parfume et adoucit les cheveux.'),
  (405, 'Mshat Khaliji Traditionnel', 5000, [16], 'Mélange traditionnel pour des cheveux souples et brillants.'),
  (419, 'Pack Complet Glamifyy – Routine Capillaire Naturelle', 36900, [43, 16], 'Toute la routine capillaire naturelle Glamifyy.'),
  (362, 'Huile Corps Illuminatrice Glow', 4500, [37, 16], 'Huile sèche qui illumine la peau.'),
  (354, 'Gommage Fermeté &#038; Douceur Extrême', 3500, [37, 40, 16], 'Gommage corps pour une peau douce et ferme.'),
  (363, 'Crème Hydratante &#038; Sublimatrice Mains et Pieds', 2500, [42, 41, 16], 'Crème riche pour mains et pieds.'),
]
CATS = [(45, 'Cheveux'), (37, 'Corps'), (43, 'Pack Beauté'), (40, 'Gommages'), (42, 'Hydratation'), (41, 'Mains &amp; Pieds'), (17, 'Beauté'), (16, 'Soins')]

def product(host, p):
    pid, name, price, cats, sd = p
    return {
        'id': pid, 'name': name, 'type': 'simple', 'is_in_stock': True, 'is_purchasable': True,
        'permalink': f'https://glamifyy.shop/?p={pid}',
        'short_description': f'<p>{sd}</p>',
        'description': f'<p>{sd}</p><p><strong>Bienfaits :</strong></p><ul><li>100 % naturel</li><li>Fabriqué au Maroc</li></ul>',
        'prices': {'price': str(price), 'regular_price': str(price), 'currency_minor_unit': 2},
        'images': [{'src': f'http://{host}/img/mp-{pid}-1.jpg'}],
        'categories': [{'id': c} for c in cats],
    }

class H(SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=WEB, **k)

    def _json(self, obj, code=200):
        body = json.dumps(obj).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        host = self.headers.get('Host')
        path = self.path.split('?')[0]
        q = self.path.split('?')[1] if '?' in self.path else ''
        if path.startswith('/img/'):
            f = os.path.join(ROOT, 'img', os.path.basename(path))
            data = open(f, 'rb').read()
            self.send_response(200); self.send_header('Content-Type', 'image/jpeg'); self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data); return
        if path == '/wp-json/wc/store/v1/products/categories':
            return self._json([{'id': i, 'name': n, 'count': sum(1 for p in P if i in p[3])} for i, n in CATS])
        m = re.fullmatch(r'/wp-json/wc/store/v1/products/(\d+)', path)
        if m:
            p = next((p for p in P if p[0] == int(m.group(1))), None)
            return self._json(product(host, p)) if p else self._json({'code': 'not_found'}, 404)
        if path == '/wp-json/wc/store/v1/products':
            cat = re.search(r'category=(\d+)', q)
            items = [p for p in P if not cat or int(cat.group(1)) in p[3]]
            return self._json([product(host, p) for p in items])
        if path == '/wp-json/mcwcp/v1/track':
            return self._json({'id': 612, 'status': 'mcwc-confirmed', 'status_label': 'Confirmée', 'total': '7500', 'minor_unit': 2, 'date': '2026-11-16T19:40:00', 'items': [{'name': 'Beurre au Chébé &#038; Karité', 'qty': 1}]})
        return super().do_GET()

    def do_POST(self):
        length = int(self.headers.get('Content-Length', 0)); self.rfile.read(length)
        if self.path.startswith('/wp-admin/admin-ajax.php'):
            return self._json({'success': True, 'data': {'redirect': 'https://glamifyy.shop/commande/order-received/612/?key=wc_order_demo'}})
        self._json({}, 404)

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    ThreadingHTTPServer(('127.0.0.1', port), H).serve_forever()
