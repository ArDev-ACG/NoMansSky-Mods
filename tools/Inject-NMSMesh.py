"""Mete una malla (npz de Weld-Bake-NMSMesh.py) en un par .GEOMETRY de pie.

    python tools/Inject-NMSMesh.py <baja.npz> <carpeta de pie> <src.npz con la v del glb>

Parte vertices por UV, escala a alto 2,85 con los pies en y 0 -el marco que
dejaba Export-NMSMesh.py- y pone VertexCount, IndexCount, MeshVertREnd,
BATCHCOUNT y VERTREND*. Luego Reorient-NMSGeometry.py sobre la carpeta.
"""
import sys, importlib.util, numpy as np, xml.etree.ElementTree as ET
from pathlib import Path
sys.path.insert(0, "tools"); import nmsgeom
spec = importlib.util.spec_from_file_location("ro", "tools/Reorient-NMSGeometry.py")
ro = importlib.util.module_from_spec(spec); spec.loader.exec_module(ro)
npz, R = sys.argv[1], Path(sys.argv[2])
d = np.load(npz); v, lt, lv, uv, vn = d["v"], d["lt"], d["lv"], d["uv"], d["vn"]
G = np.load(sys.argv[3])["v"]            # glb original, para la caja
key = np.c_[lv, np.round(uv * 2**16).astype(np.int64)]
uk, inv = np.unique(key, axis=0, return_inverse=True); inv = inv.ravel()
first = np.full(len(uk), -1); first[inv[::-1]] = np.arange(len(inv))[::-1]
vi = lv[first]; UV = uv[first]
tri = inv[lt]
N = len(uk); print("vertices partidos por UV", N, "tris", len(tri)); assert N < 65535
s = 2.85 / (G[:, 1].max() - G[:, 1].min())
P = v[vi] * s; P[:, 1] -= G[:, 1].min() * s
n = vn[vi].copy(); n[np.linalg.norm(n, axis=1) < 0.5] = (0, 0, 1)
pos = np.zeros((N, 8)); pos[:, :3] = P; pos[:, 3] = 1; pos[:, 4:6] = UV; pos[:, 7] = 1
V = np.zeros((N, 16), dtype=np.uint8)
V[:, 4:12] = np.array([1, 0, 0, 0], dtype="<f2").view(np.uint8)[None, :]
V[:, 12:16] = ro._sem11(n, np.zeros(N, dtype=np.uint32)).astype("<u4").view(np.uint8).reshape(-1, 4)
st = nmsgeom.leer_streams(R / "FIEND.GEOMETRY.DATA.MXML")
st.vertices = V.tobytes(); st.indices = tri.astype("<u2").tobytes(); st.posiciones = pos.astype("<f2").tobytes()
nmsgeom.escribir_streams(R / "FIEND.GEOMETRY.DATA.MXML", st)


def setv(root, name, val):
    for p in root.iter("Property"):
        if p.get("name") == name and p.get("value") is not None and len(p) == 0:
            p.set("value", str(val))


a = ET.parse(R / "FIEND.GEOMETRY.MXML"); r = a.getroot()
setv(r, "VertexCount", N); setv(r, "IndexCount", tri.size); setv(r, "MeshVertREnd", N - 1)
a.write(R / "FIEND.GEOMETRY.MXML", encoding="utf-8", xml_declaration=True)
a = ET.parse(R / "FIEND.SCENE.MXML")
for at in a.getroot().iter("Property"):
    if at.get("value") != "TkSceneNodeAttributeData":
        continue
    nm = at.find("Property[@name='Name']").get("value"); val = at.find("Property[@name='Value']")
    if nm == "BATCHCOUNT": val.set("value", str(tri.size))
    if nm in ("VERTRENDPHYSICS", "VERTRENDGRAPHIC"): val.set("value", str(N - 1))
a.write(R / "FIEND.SCENE.MXML", encoding="utf-8", xml_declaration=True)
print("caja", P.min(0).round(3), P.max(0).round(3))
