"""Build the Stats HUD asset atlas and AS2 data tables from this repository.

Inputs (all from this repo, taken from External Item Descriptions):
  resources/font/eid_default.fnt (+ pages)     EID bitmap font (BMFont v3 binary)
  resources/gfx/eid_inline_icons.anm2 (+ png)  stat icons ("Stats" animation, same art as the game's HUD stats)
  flash/data/eid_markup.lua                    EID.InlineIcons (icon frame, width and offsets)

Outputs (into <out_dir>):
  shud_atlas.png       packed glyphs + stat icons (embedded into the SWF as a bitmap)
  shud_data.as         AS2 tables: glyphs, icons
"""
import os
import re
import struct
import sys
import xml.etree.ElementTree as ET

from PIL import Image

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
FONT = os.path.join(REPO, "resources", "font", "eid_default.fnt")
GFX = os.path.join(REPO, "resources", "gfx")
EID_DATA = os.path.join(REPO, "flash", "data", "eid_markup.lua")

# The stats shown, top to bottom, and the icon variant used for each (Repentance's HUD icons).
STATS = ["Speed", "Tears", "Damage", "Range", "Shotspeed", "Luck", "DevilChance", "AngelChance"]
ICON_VARIANT = "REP"


def parse_fnt(path):
    d = open(path, "rb").read()
    assert d[:4] == b"BMF\x03", "expected binary BMFont v3"
    p, chars, common, pages = 4, {}, None, []
    while p < len(d):
        t, size = d[p], struct.unpack("<I", d[p + 1:p + 5])[0]
        b = d[p + 5:p + 5 + size]
        p += 5 + size
        if t == 2:
            common = struct.unpack("<HH", b[:4])  # lineHeight, base
        elif t == 3:
            pages = [x.decode() for x in b.split(b"\0") if x]
        elif t == 4:
            for i in range(0, size, 20):
                cid, x, y, w, h, xo, yo, xa, pg, _ = struct.unpack("<IHHHHhhhBB", b[i:i + 20])
                chars[cid] = (x, y, w, h, xo, yo, xa, pg)
    return chars, common, pages


def parse_anm2(path):
    """Return {animation: [frame dict, ...]} for the first layer, frames expanded by Delay."""
    root = ET.parse(path).getroot()
    out = {}
    for anim in root.iter("Animation"):
        layer = anim.find("LayerAnimations/LayerAnimation")
        frames = []
        for f in (layer.findall("Frame") if layer is not None else []):
            fr = {k: float(f.get(k)) for k in ("XPosition", "YPosition", "XPivot", "YPivot", "XCrop", "YCrop", "Width", "Height")}
            frames += [fr] * max(1, int(f.get("Delay", "1")))
        out[anim.get("Name")] = frames
    return out


def parse_inline_icons(src):
    """EID.InlineIcons entries using the default inline sprite: name -> (anim, frame, w, h, left, top)."""
    icons = {}
    for m in re.finditer(r'\["([^"]+)"\]\s*=\s*\{\s*"([^"]+)"\s*,\s*(-?\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(-?\d+))?\s*(?:,\s*(-?\d+))?\s*(,[^}]*)?\}', src):
        name, anim, frame, w, h, left, top, rest = m.groups()
        if rest and rest.strip(", "):
            continue  # uses another sprite object
        icons[name] = (anim, int(frame), int(w), int(h), int(left) if left else -1, int(top) if top else 0)
    return icons


class Packer:
    """Simple shelf packer with 1px padding."""

    def __init__(self, width):
        self.w, self.x, self.y, self.row = width, 0, 0, 0
        self.items = []

    def add(self, img):
        if self.x + img.width + 1 > self.w:
            self.x, self.y, self.row = 0, self.y + self.row + 1, 0
        pos = (self.x, self.y)
        self.items.append((img, pos))
        self.x += img.width + 1
        self.row = max(self.row, img.height)
        return pos

    def image(self):
        out = Image.new("RGBA", (self.w, self.y + self.row + 1), (0, 0, 0, 0))
        for img, pos in self.items:
            out.paste(img, pos)
        return out


def as2_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def build(out_dir):
    os.makedirs(out_dir, exist_ok=True)
    chars, (line_height, base), pages = parse_fnt(FONT)
    page_imgs = [Image.open(os.path.join(os.path.dirname(FONT), p)).convert("RGBA") for p in pages]
    icons = parse_inline_icons(open(EID_DATA, encoding="utf-8").read())
    inline_anm = parse_anm2(os.path.join(GFX, "eid_inline_icons.anm2"))
    inline_png = Image.open(os.path.join(GFX, "eid_inline_icons.png")).convert("RGBA")

    packer = Packer(256)
    glyph_lines, icon_lines = [], []
    for c in range(32, 127):
        g = chars.get(c)
        if g is None:
            print("warning: font has no glyph for", repr(chr(c)))
            continue
        x, y, w, h, xo, yo, xa, pg = g
        if w and h:
            ax, ay = packer.add(page_imgs[pg].crop((x, y, x + w, y + h)))
        else:
            ax = ay = 0
        glyph_lines.append(f"G[{c}]=[{ax},{ay},{w},{h},{xo},{yo},{xa}];")

    for stat in STATS:
        name = stat + ICON_VARIANT
        if name not in icons:
            sys.exit(f"inline icon {name} not found in {EID_DATA}")
        anim, frame, eid_w, h, left, top = icons[name]
        fr = inline_anm[anim][frame]
        crop = (int(fr["XCrop"]), int(fr["YCrop"]), int(fr["XCrop"] + fr["Width"]), int(fr["YCrop"] + fr["Height"]))
        ax, ay = packer.add(inline_png.crop(crop))
        dx, dy = int(fr["XPosition"] - fr["XPivot"]), int(fr["YPosition"] - fr["YPivot"])
        # [atlas x, atlas y, w, h, sprite offset x, sprite offset y, EID width, EID left, EID top]
        icon_lines.append(f'I[{as2_str(stat)}]=[{ax},{ay},{int(fr["Width"])},{int(fr["Height"])},{dx},{dy},{eid_w},{left},{top}];')

    atlas = packer.image()
    atlas.save(os.path.join(out_dir, "shud_atlas.png"))

    lines = [
        "// GENERATED by flash/tools/shud_assets.py from the EID font and icons. Do not edit.",
        f"_root.shudLineHeight = {line_height};",
        "var G = _root.shudGlyph = [];",
        *glyph_lines,
        "var I = _root.shudIcon = {};",
        *icon_lines,
        "_root.shudStatNames = [" + ",".join(as2_str(s) for s in STATS) + "];",
    ]
    open(os.path.join(out_dir, "shud_data.as"), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    print(f"atlas {atlas.size}, {len(glyph_lines)} glyphs, {len(icon_lines)} icons")


if __name__ == "__main__":
    build(sys.argv[1] if len(sys.argv) > 1 else os.path.join(REPO, "flash", "build"))
