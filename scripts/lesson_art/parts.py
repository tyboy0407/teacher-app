"""範本教案插圖的圖形零件:扁平向量、配色跟 App 一致(鼠尾草綠 + 杏色 + 少量柔和的輔助色)。

每個函式回傳一段 SVG 字串。座標慣例:人物以「腳底中心」為原點,其餘物件以中心為原點;
用 at() 擺到畫面上。只用基本圖形與路徑(flutter_svg 都支援),不用濾鏡、漸層、CSS。
"""
from __future__ import annotations

import math

# ---- 配色 ----
PAPER = "#F7F5F0"
WHITE = "#FFFFFF"
INK = "#262A28"
INK_SOFT = "#626864"
LINE = "#DCD6CA"
SAGE = "#557263"
SAGE_DEEP = "#3F5649"
SAGE_LIGHT = "#E6EDE8"
SAGE_MID = "#A9C0B2"
APRICOT = "#E8C9A8"
APRICOT_LIGHT = "#F6EADB"
TERRACOTTA = "#B8703F"
SKIN = "#F3D6BC"
HAIR = "#5B4636"
HAIR_2 = "#3B332E"
CORN = "#F0C95A"
CORN_DEEP = "#D9A93A"
LEAF = "#8FB07A"
SEA = "#BFD9E3"
SEA_DEEP = "#7FAFC2"
SEA_DARK = "#4F86A0"
BLUSH = "#F0C7C2"
ROSE = "#D98A86"
RED = "#C8553D"
GOLD = "#E3B458"
NIGHT = "#33434C"
SKY = "#E4EEF3"
LILAC = "#D9D2EA"
GREY = "#C9CEC9"

FONT = "Huninn"


def at(content: str, x: float, y: float, s: float = 1, rot: float = 0) -> str:
    t = f"translate({x:.1f} {y:.1f})"
    if rot:
        t += f" rotate({rot:.1f})"
    if s != 1:
        t += f" scale({s:.3f})"
    return f'<g transform="{t}">{content}</g>'


def svg(w: int, h: int, body: str, bg: str) -> str:
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">'
        f'<rect width="{w}" height="{h}" fill="{bg}"/>{body}</svg>\n'
    )


def circle(cx, cy, r, fill, stroke=None, sw=0):
    extra = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="{fill}"{extra}/>'


def ellipse(cx, cy, rx, ry, fill):
    return f'<ellipse cx="{cx:.1f}" cy="{cy:.1f}" rx="{rx:.1f}" ry="{ry:.1f}" fill="{fill}"/>'


def rect(x, y, w, h, fill, rx=0, stroke=None, sw=0):
    extra = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
    return f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx:.1f}" fill="{fill}"{extra}/>'


def line(x1, y1, x2, y2, stroke, sw, cap="round"):
    return (
        f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" '
        f'stroke="{stroke}" stroke-width="{sw:.1f}" stroke-linecap="{cap}"/>'
    )


def path(d, fill="none", stroke=None, sw=0, cap="round", join="round"):
    extra = (
        f' stroke="{stroke}" stroke-width="{sw:.1f}" stroke-linecap="{cap}" stroke-linejoin="{join}"'
        if stroke
        else ""
    )
    return f'<path d="{d}" fill="{fill}"{extra}/>'


def text(x, y, content, size, fill=INK, anchor="middle"):
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" font-family="{FONT}" font-size="{size:.1f}" '
        f'fill="{fill}" text-anchor="{anchor}">{content}</text>'
    )


def ground(w, h, fill, top=0.78):
    return rect(0, h * top, w, h * (1 - top), fill)


def blob(cx, cy, rx, ry, fill):
    return ellipse(cx, cy, rx, ry, fill)


# ---- 人物 ----

def person(
    h=90.0,
    shirt=SAGE,
    hair=HAIR,
    pose="down",
    face="smile",
    pants="#5E6B66",
    hair_style="short",
):
    """腳底中心在 (0,0),頭頂在 (0,-h)。pose: down / up / out / reach_r / reach_l / wave / hold。"""
    r = 0.17 * h
    head_cy = -h + r + 0.02 * h
    body_top = head_cy + r * 0.86
    body_bottom = -0.30 * h
    body_w = 0.36 * h
    out = []
    # 腿與鞋
    for lx in (-0.14 * h, 0.03 * h):
        out.append(rect(lx, body_bottom - 2, 0.11 * h, 0.27 * h, pants, rx=0.04 * h))
        out.append(ellipse(lx + 0.065 * h, -0.02 * h, 0.085 * h, 0.035 * h, INK))
    # 手臂(先畫,身體蓋住肩膀)
    shoulder_y = body_top + 0.07 * h
    hands = {
        "down": ((-0.25 * h, -0.42 * h), (0.25 * h, -0.42 * h)),
        "up": ((-0.30 * h, -0.98 * h), (0.30 * h, -0.98 * h)),
        "out": ((-0.42 * h, -0.60 * h), (0.42 * h, -0.60 * h)),
        "reach_r": ((-0.25 * h, -0.42 * h), (0.46 * h, -0.62 * h)),
        "reach_l": ((-0.46 * h, -0.62 * h), (0.25 * h, -0.42 * h)),
        "wave": ((-0.25 * h, -0.42 * h), (0.34 * h, -0.95 * h)),
        "hold": ((-0.12 * h, -0.50 * h), (0.12 * h, -0.50 * h)),
    }[pose]
    for side, (hx, hy) in zip((-1, 1), hands):
        sx = side * 0.14 * h
        out.append(line(sx, shoulder_y, hx, hy, shirt, 0.09 * h))
        out.append(circle(hx, hy, 0.05 * h, SKIN))
    # 身體
    out.append(rect(-body_w / 2, body_top, body_w, body_bottom - body_top, shirt, rx=0.12 * h))
    if pose == "hold":
        # 雙手在胸前:手要畫在身體前面才看得到
        for hx, hy in hands:
            out.append(circle(hx * 0.7, hy, 0.055 * h, SKIN))
    # 頭髮與臉
    if hair_style == "long":
        out.append(rect(-r * 1.05, head_cy - r * 0.3, r * 2.1, r * 1.9, hair, rx=r * 0.6))
    if hair_style == "bun":
        out.append(circle(0, head_cy - r * 1.15, r * 0.42, hair))
    out.append(circle(0, head_cy - 0.03 * h, r * 1.06, hair))
    out.append(circle(0, head_cy + 0.02 * h, r * 0.94, SKIN))
    out.append(_face(face, head_cy + 0.03 * h, h))
    return "".join(out)


def _face(kind: str, cy: float, h: float) -> str:
    ex = 0.062 * h
    er = 0.016 * h
    sw = 0.016 * h
    out = []
    if kind == "none":
        return ""
    if kind == "closed":
        for side in (-1, 1):
            x = side * ex
            out.append(path(f"M{x - er * 1.6:.1f} {cy:.1f} Q{x:.1f} {cy + er * 1.6:.1f} {x + er * 1.6:.1f} {cy:.1f}", stroke=INK, sw=sw))
    else:
        for side in (-1, 1):
            out.append(circle(side * ex, cy, er, INK))
    my = cy + 0.07 * h
    mw = 0.05 * h
    if kind in ("smile", "closed"):
        out.append(path(f"M{-mw:.1f} {my:.1f} Q0 {my + mw * 0.9:.1f} {mw:.1f} {my:.1f}", stroke=INK, sw=sw))
    elif kind == "sad":
        out.append(path(f"M{-mw:.1f} {my + mw * 0.5:.1f} Q0 {my - mw * 0.5:.1f} {mw:.1f} {my + mw * 0.5:.1f}", stroke=INK, sw=sw))
    elif kind == "angry":
        out.append(line(-mw, my + 2, mw, my + 2, INK, sw))
        for side in (-1, 1):
            out.append(line(side * (ex + er * 2), cy - er * 3.2, side * (ex - er * 1.5), cy - er * 1.8, INK, sw))
    elif kind == "wow":
        out.append(circle(0, my + 1, mw * 0.55, INK))
    # 腮紅
    for side in (-1, 1):
        out.append(circle(side * 0.105 * h, cy + 0.045 * h, 0.022 * h, BLUSH))
    return "".join(out)


def kid(h=78, shirt=SAGE, hair=HAIR, pose="down", face="smile", hair_style="short"):
    return person(h, shirt, hair, pose, face, hair_style=hair_style)


def teacher(h=112, shirt=TERRACOTTA, pose="down", face="smile"):
    return person(h, shirt, HAIR_2, pose, face, pants="#4D5955", hair_style="bun")


def lying_kid(w=80, shirt=SAGE, hair=HAIR):
    """躺平的小孩,中心在 (0,0)。"""
    r = w * 0.16
    out = [
        rect(-w * 0.28, -r * 0.7, w * 0.52, r * 1.4, shirt, rx=r * 0.6),
        rect(w * 0.20, -r * 0.45, w * 0.30, r * 0.9, "#5E6B66", rx=r * 0.4),
        circle(-w * 0.38, -1, r * 1.05, hair),
        circle(-w * 0.36, 0, r * 0.92, SKIN),
        path(f"M{-w * 0.42:.1f} {-r * 0.15:.1f} q{r * 0.2:.1f} {r * 0.25:.1f} {r * 0.4:.1f} 0", stroke=INK, sw=1.4),
        path(f"M{-w * 0.34:.1f} {-r * 0.15:.1f} q{r * 0.2:.1f} {r * 0.25:.1f} {r * 0.4:.1f} 0", stroke=INK, sw=1.4),
    ]
    return "".join(out)


# ---- 食農 ----

def corn(length=70, color=CORN, husk=True):
    """直立的玉米,中心在 (0,0)。"""
    w = length * 0.34
    out = []
    if husk:
        out.append(path(f"M0 {length * 0.5:.1f} C{-w * 1.5:.1f} {length * 0.2:.1f} {-w * 1.2:.1f} {-length * 0.25:.1f} {-w * 0.3:.1f} {-length * 0.1:.1f} Z", fill=LEAF))
        out.append(path(f"M0 {length * 0.5:.1f} C{w * 1.5:.1f} {length * 0.2:.1f} {w * 1.2:.1f} {-length * 0.25:.1f} {w * 0.3:.1f} {-length * 0.1:.1f} Z", fill="#7BA066"))
    out.append(rect(-w / 2, -length / 2, w, length * 0.92, color, rx=w / 2))
    deep = CORN_DEEP if color == CORN else "#00000022"
    rows = 6
    for i in range(rows):
        y = -length / 2 + length * 0.12 + i * length * 0.115
        for j in (-1, 0, 1):
            out.append(circle(j * w * 0.27, y, w * 0.10, deep))
    return "".join(out)


def mystery_box(w=90):
    h = w * 0.72
    return "".join([
        rect(-w / 2, -h / 2, w, h, APRICOT, rx=6),
        rect(-w / 2, -h / 2, w, h * 0.2, TERRACOTTA, rx=6),
        ellipse(0, h * 0.12, w * 0.2, h * 0.2, INK),
        text(0, -h * 0.5 - 8, "?", w * 0.34, TERRACOTTA),
    ])


def paper(w=70, h=90, fill=WHITE):
    return rect(-w / 2, -h / 2, w, h, fill, rx=4, stroke=LINE, sw=1.5)


def paint_dots(color=CORN_DEEP, n=5, spread=22):
    out = []
    for i in range(n):
        a = i * 2.4
        out.append(circle(math.cos(a) * spread * (0.4 + 0.12 * i), math.sin(a) * spread * (0.4 + 0.12 * i), 4.2, color))
    return "".join(out)


# ---- 海洋 ----

def wave(w, y, amp, fill, h=400, phase=0.0):
    step = 40
    d = f"M0 {y:.1f}"
    x = 0
    i = 0
    while x < w:
        up = -amp if (i + int(phase)) % 2 == 0 else amp
        d += f" Q{x + step / 2:.1f} {y + up:.1f} {x + step:.1f} {y:.1f}"
        x += step
        i += 1
    d += f" V{h} H0 Z"
    return path(d, fill=fill)


def fish(s=40, color=APRICOT, facing=1):
    f = facing
    return "".join([
        ellipse(0, 0, s * 0.5, s * 0.3, color),
        path(f"M{-f * s * 0.42:.1f} 0 L{-f * s * 0.8:.1f} {-s * 0.28:.1f} L{-f * s * 0.8:.1f} {s * 0.28:.1f} Z", fill=color),
        circle(f * s * 0.26, -s * 0.06, s * 0.05, INK),
        path(f"M{f * s * 0.02:.1f} {-s * 0.14:.1f} q{-f * s * 0.1:.1f} {s * 0.14:.1f} 0 {s * 0.28:.1f}", stroke="#00000030", sw=1.5),
    ])


def shark_fin(s=40):
    return path(f"M{-s * 0.5:.1f} 0 Q{-s * 0.1:.1f} {-s * 0.9:.1f} {s * 0.35:.1f} {-s:.1f} Q{s * 0.2:.1f} {-s * 0.4:.1f} {s * 0.5:.1f} 0 Z", fill=SEA_DARK)


def seaweed(h=50, color=LEAF):
    return path(f"M0 0 C{-h * 0.3:.1f} {-h * 0.3:.1f} {h * 0.3:.1f} {-h * 0.6:.1f} 0 {-h:.1f}", stroke=color, sw=7)


def book_open(w=120):
    h = w * 0.55
    return "".join([
        path(f"M0 {-h * 0.4:.1f} Q{-w * 0.25:.1f} {-h * 0.6:.1f} {-w * 0.5:.1f} {-h * 0.45:.1f} V{h * 0.45:.1f} Q{-w * 0.25:.1f} {h * 0.3:.1f} 0 {h * 0.5:.1f} Z", fill=WHITE, stroke=LINE, sw=1.5),
        path(f"M0 {-h * 0.4:.1f} Q{w * 0.25:.1f} {-h * 0.6:.1f} {w * 0.5:.1f} {-h * 0.45:.1f} V{h * 0.45:.1f} Q{w * 0.25:.1f} {h * 0.3:.1f} 0 {h * 0.5:.1f} Z", fill=WHITE, stroke=LINE, sw=1.5),
        line(0, -h * 0.4, 0, h * 0.5, LINE, 2),
    ])


def sound_waves(r=18, color=SEA_DARK, n=3):
    out = []
    for i in range(n):
        rr = r + i * 12
        out.append(path(f"M{rr * 0.7:.1f} {-rr * 0.7:.1f} A{rr:.1f} {rr:.1f} 0 0 1 {rr * 0.7:.1f} {rr * 0.7:.1f}", stroke=color, sw=3))
    return "".join(out)


# ---- 大餅與動物 ----

def cake(r=50, bg=PAPER, bite="round"):
    out = [circle(0, 0, r, "#E9B872"), circle(0, 0, r * 0.86, "#F3CF94")]
    for a in range(0, 360, 45):
        out.append(circle(math.cos(math.radians(a)) * r * 0.5, math.sin(math.radians(a)) * r * 0.5, r * 0.045, "#D39C55"))
    bx, by = r * 0.72, -r * 0.62
    if bite == "round":
        out.append(circle(bx, by, r * 0.42, bg))
    elif bite == "tri":
        out.append(path(f"M{r * 1.1:.1f} {-r * 1.0:.1f} L{r * 0.25:.1f} {-r * 0.45:.1f} L{r * 1.1:.1f} {-r * 0.1:.1f} Z", fill=bg))
    elif bite == "two":
        out.append(rect(bx - r * 0.36, by - r * 0.5, r * 0.28, r * 0.7, bg, rx=r * 0.1))
        out.append(rect(bx - r * 0.02, by - r * 0.5, r * 0.28, r * 0.7, bg, rx=r * 0.1))
    elif bite == "zig":
        d = f"M{r * 1.2:.1f} {-r * 1.1:.1f}"
        for i in range(5):
            x = r * 0.95 - i * r * 0.16
            y = -r * 0.95 + i * r * 0.2
            d += f" L{x - r * 0.2:.1f} {y:.1f} L{x:.1f} {y + r * 0.14:.1f}"
        d += f" L{r * 1.2:.1f} {r * 0.1:.1f} Z"
        out.append(path(d, fill=bg))
    elif bite == "big":
        out.append(circle(r * 0.85, -r * 0.3, r * 0.7, bg))
    return "".join(out)


def pig(r=34, face="wow"):
    out = [
        path(f"M{-r * 0.85:.1f} {-r * 0.55:.1f} L{-r * 0.55:.1f} {-r * 1.15:.1f} L{-r * 0.2:.1f} {-r * 0.8:.1f} Z", fill=ROSE),
        path(f"M{r * 0.85:.1f} {-r * 0.55:.1f} L{r * 0.55:.1f} {-r * 1.15:.1f} L{r * 0.2:.1f} {-r * 0.8:.1f} Z", fill=ROSE),
        circle(0, 0, r, BLUSH),
        ellipse(0, r * 0.25, r * 0.42, r * 0.3, ROSE),
        circle(-r * 0.14, r * 0.25, r * 0.07, INK),
        circle(r * 0.14, r * 0.25, r * 0.07, INK),
        circle(-r * 0.38, -r * 0.22, r * 0.08, INK),
        circle(r * 0.38, -r * 0.22, r * 0.08, INK),
    ]
    if face == "wow":
        out.append(circle(0, r * 0.68, r * 0.1, INK))
    else:
        out.append(path(f"M{-r * 0.18:.1f} {r * 0.66:.1f} Q0 {r * 0.82:.1f} {r * 0.18:.1f} {r * 0.66:.1f}", stroke=INK, sw=2))
    return "".join(out)


def rabbit(r=24):
    return "".join([
        ellipse(-r * 0.4, -r * 1.3, r * 0.24, r * 0.7, WHITE),
        ellipse(r * 0.4, -r * 1.3, r * 0.24, r * 0.7, WHITE),
        ellipse(-r * 0.4, -r * 1.3, r * 0.1, r * 0.45, BLUSH),
        ellipse(r * 0.4, -r * 1.3, r * 0.1, r * 0.45, BLUSH),
        circle(0, 0, r, WHITE, stroke=LINE, sw=1.5),
        circle(-r * 0.36, -r * 0.12, r * 0.09, INK),
        circle(r * 0.36, -r * 0.12, r * 0.09, INK),
        rect(-r * 0.16, r * 0.3, r * 0.14, r * 0.26, WHITE, stroke=LINE, sw=1),
        rect(r * 0.02, r * 0.3, r * 0.14, r * 0.26, WHITE, stroke=LINE, sw=1),
        circle(0, r * 0.18, r * 0.09, ROSE),
    ])


def bird(r=22):
    return "".join([
        circle(0, 0, r, SEA_DEEP),
        path(f"M{r * 0.8:.1f} {-r * 0.1:.1f} L{r * 1.5:.1f} {r * 0.12:.1f} L{r * 0.8:.1f} {r * 0.34:.1f} Z", fill=GOLD),
        circle(r * 0.3, -r * 0.25, r * 0.1, INK),
        path(f"M{-r * 0.9:.1f} {r * 0.1:.1f} q{-r * 0.5:.1f} {-r * 0.3:.1f} {-r * 0.7:.1f} {r * 0.2:.1f}", stroke=SEA_DARK, sw=5),
    ])


def croc(w=70):
    h = w * 0.36
    out = [rect(-w / 2, -h / 2, w, h, LEAF, rx=h * 0.45)]
    d = ""
    for i in range(5):
        x = -w * 0.05 + i * w * 0.1
        d += f"M{x:.1f} {h * 0.18:.1f} l{w * 0.05:.1f} {h * 0.3:.1f} l{w * 0.05:.1f} {-h * 0.3:.1f} Z "
    out.append(path(d, fill=WHITE))
    out.append(circle(-w * 0.2, -h * 0.42, h * 0.24, LEAF))
    out.append(circle(-w * 0.2, -h * 0.44, h * 0.1, INK))
    return "".join(out)


def speech_bubble(w=70, h=44, fill=WHITE, tail=-1):
    return "".join([
        rect(-w / 2, -h / 2, w, h, fill, rx=h * 0.4, stroke=LINE, sw=1.5),
        path(f"M{tail * w * 0.15:.1f} {h * 0.48:.1f} l{tail * 10:.1f} 14 l{-tail * 16:.1f} -14 Z", fill=fill),
    ])


def card_small(w=44, h=56, fill=WHITE, inner=""):
    return rect(-w / 2, -h / 2, w, h, fill, rx=5, stroke=LINE, sw=1.5) + inner


# ---- 天氣與情緒 ----

def sun(r=26, color=GOLD):
    out = [circle(0, 0, r, color)]
    for a in range(0, 360, 45):
        x1 = math.cos(math.radians(a)) * r * 1.35
        y1 = math.sin(math.radians(a)) * r * 1.35
        x2 = math.cos(math.radians(a)) * r * 1.75
        y2 = math.sin(math.radians(a)) * r * 1.75
        out.append(line(x1, y1, x2, y2, color, r * 0.2))
    out.append(circle(-r * 0.32, -r * 0.1, r * 0.08, INK))
    out.append(circle(r * 0.32, -r * 0.1, r * 0.08, INK))
    out.append(path(f"M{-r * 0.3:.1f} {r * 0.25:.1f} Q0 {r * 0.6:.1f} {r * 0.3:.1f} {r * 0.25:.1f}", stroke=INK, sw=2))
    return "".join(out)


def cloud(w=80, fill=WHITE):
    h = w * 0.42
    return "".join([
        circle(-w * 0.25, 0, h * 0.5, fill),
        circle(0, -h * 0.28, h * 0.66, fill),
        circle(w * 0.27, 0, h * 0.52, fill),
        rect(-w * 0.42, 0, w * 0.86, h * 0.5, fill, rx=h * 0.25),
    ])


def rain(w=60, color=SEA_DARK, n=4):
    out = []
    for i in range(n):
        x = -w / 2 + (i + 0.5) * w / n
        out.append(line(x, 0, x - 5, 14, color, 3.5))
    return "".join(out)


def bolt(s=30, color=GOLD):
    return path(f"M{s * 0.15:.1f} {-s * 0.6:.1f} L{-s * 0.3:.1f} {s * 0.05:.1f} H{s * 0.02:.1f} L{-s * 0.15:.1f} {s * 0.6:.1f} L{s * 0.35:.1f} {-s * 0.1:.1f} H{s * 0.05:.1f} Z", fill=color)


def heart(s=24, color=ROSE):
    return path(
        f"M0 {s * 0.42:.1f} C{-s * 0.9:.1f} {-s * 0.15:.1f} {-s * 0.45:.1f} {-s * 0.75:.1f} 0 {-s * 0.3:.1f} "
        f"C{s * 0.45:.1f} {-s * 0.75:.1f} {s * 0.9:.1f} {-s * 0.15:.1f} 0 {s * 0.42:.1f} Z",
        fill=color,
    )


def mirror(w=70):
    h = w * 1.25
    return "".join([
        rect(-w / 2, -h / 2, w, h, TERRACOTTA, rx=w * 0.3),
        rect(-w / 2 + 6, -h / 2 + 6, w - 12, h - 12, SKY, rx=w * 0.24),
    ])


def clip(color=SAGE):
    return rect(-5, -9, 10, 18, color, rx=3)


# ---- 感恩 ----

def photo_frame(w=60, inner="", fill=WHITE):
    h = w * 1.15
    return rect(-w / 2, -h / 2, w, h, fill, rx=5, stroke=LINE, sw=1.5) + rect(-w / 2 + 6, -h / 2 + 6, w - 12, h - 20, SAGE_LIGHT, rx=3) + inner


def bust(r=13, shirt=SAGE, hat=None):
    out = [
        path(f"M{-r * 1.5:.1f} {r * 2.3:.1f} Q{-r * 1.5:.1f} {r * 0.9:.1f} 0 {r * 0.9:.1f} Q{r * 1.5:.1f} {r * 0.9:.1f} {r * 1.5:.1f} {r * 2.3:.1f} Z", fill=shirt),
        circle(0, 0, r, SKIN),
        circle(-r * 0.35, 0, r * 0.1, INK),
        circle(r * 0.35, 0, r * 0.1, INK),
        path(f"M{-r * 0.3:.1f} {r * 0.4:.1f} Q0 {r * 0.7:.1f} {r * 0.3:.1f} {r * 0.4:.1f}", stroke=INK, sw=1.4),
    ]
    if hat == "chef":
        out.append(rect(-r * 0.8, -r * 1.9, r * 1.6, r * 1.0, WHITE, rx=r * 0.4, stroke=LINE, sw=1))
    elif hat == "cap":
        out.append(path(f"M{-r:.1f} {-r * 0.5:.1f} Q0 {-r * 1.7:.1f} {r:.1f} {-r * 0.5:.1f} L{r * 1.5:.1f} {-r * 0.4:.1f} L{-r:.1f} {-r * 0.4:.1f} Z", fill=SEA_DARK))
    else:
        out.append(path(f"M{-r:.1f} {-r * 0.2:.1f} Q0 {-r * 1.6:.1f} {r:.1f} {-r * 0.2:.1f} Z", fill=HAIR))
    return "".join(out)


def greeting_card(w=64, h=48):
    return rect(-w / 2, -h / 2, w, h, WHITE, rx=5, stroke=LINE, sw=1.5) + heart(18, ROSE)


def crayon(length=44, color=TERRACOTTA):
    return rect(-length / 2, -5, length * 0.8, 10, color, rx=2) + path(f"M{length * 0.3:.1f} -5 L{length * 0.5:.1f} 0 L{length * 0.3:.1f} 5 Z", fill=color)


# ---- 過年 ----

def couplet(s=60, char="春", flip=False):
    inner = text(0, s * 0.19, char, s * 0.56, INK)
    if flip:
        inner = f'<g transform="rotate(180)">{inner}</g>'
    return "".join([
        f'<g transform="rotate(45)">{rect(-s / 2, -s / 2, s, s, RED, rx=3)}{rect(-s / 2 + 4, -s / 2 + 4, s - 8, s - 8, "none", rx=2, stroke=GOLD, sw=1.6)}</g>',
        inner,
    ])


def brush(length=70):
    return "".join([
        rect(-3, -length / 2, 6, length * 0.7, "#8A6A4A", rx=3),
        path(f"M-6 {length * 0.2:.1f} H6 L0 {length * 0.5:.1f} Z", fill=INK),
    ])


def door(w=90, h=130):
    return "".join([
        rect(-w / 2, -h, w, h, "#B98B62", rx=4),
        rect(-w / 2 + 8, -h + 8, w - 16, h - 8, "#C99C74", rx=3),
        circle(w * 0.28, -h * 0.45, 4, GOLD),
    ])


def nian(s=70):
    out = []
    for a in range(0, 360, 30):
        out.append(circle(math.cos(math.radians(a)) * s * 0.5, math.sin(math.radians(a)) * s * 0.5, s * 0.2, "#E08A4F"))
    out += [
        path(f"M{-s * 0.3:.1f} {-s * 0.42:.1f} L{-s * 0.42:.1f} {-s * 0.85:.1f} L{-s * 0.1:.1f} {-s * 0.5:.1f} Z", fill=GOLD),
        path(f"M{s * 0.3:.1f} {-s * 0.42:.1f} L{s * 0.42:.1f} {-s * 0.85:.1f} L{s * 0.1:.1f} {-s * 0.5:.1f} Z", fill=GOLD),
        circle(0, 0, s * 0.5, RED),
        circle(-s * 0.2, -s * 0.1, s * 0.13, WHITE),
        circle(s * 0.2, -s * 0.1, s * 0.13, WHITE),
        circle(-s * 0.18, -s * 0.08, s * 0.06, INK),
        circle(s * 0.22, -s * 0.08, s * 0.06, INK),
        ellipse(0, s * 0.1, s * 0.08, s * 0.05, INK),
        path(f"M{-s * 0.26:.1f} {s * 0.2:.1f} Q0 {s * 0.42:.1f} {s * 0.26:.1f} {s * 0.2:.1f} Z", fill=INK),
        path(f"M{-s * 0.2:.1f} {s * 0.2:.1f} l{s * 0.05:.1f} {s * 0.11:.1f} l{s * 0.05:.1f} {-s * 0.11:.1f} Z", fill=WHITE),
        path(f"M{s * 0.1:.1f} {s * 0.2:.1f} l{s * 0.05:.1f} {s * 0.11:.1f} l{s * 0.05:.1f} {-s * 0.11:.1f} Z", fill=WHITE),
    ]
    return "".join(out)


def firecrackers(n=4, s=14):
    out = [line(0, -s * 0.8, 0, n * s * 1.25, GOLD, 2)]
    for i in range(n):
        y = i * s * 1.25
        side = -1 if i % 2 == 0 else 1
        out.append(f'<g transform="translate({side * s * 0.55:.1f} {y:.1f}) rotate({side * 24})">{rect(-s * 0.3, -s * 0.5, s * 0.6, s, RED, rx=2)}{rect(-s * 0.3, -s * 0.5, s * 0.6, s * 0.18, GOLD)}</g>')
    return "".join(out)


def drum(w=56):
    h = w * 0.62
    return "".join([
        rect(-w / 2, -h / 2, w, h, RED, rx=6),
        ellipse(0, -h / 2, w / 2, h * 0.2, APRICOT_LIGHT),
        line(-w * 0.3, -h * 0.2, -w * 0.3, h * 0.4, GOLD, 2.5),
        line(0, -h * 0.2, 0, h * 0.45, GOLD, 2.5),
        line(w * 0.3, -h * 0.2, w * 0.3, h * 0.4, GOLD, 2.5),
    ])


def pot_lid(r=20):
    return ellipse(0, 0, r, r * 0.9, GREY) + circle(0, 0, r * 0.25, INK_SOFT)


def scarf(w=60, color=RED):
    return path(f"M{-w / 2:.1f} 0 Q{-w / 4:.1f} -16 0 0 T{w / 2:.1f} 0", stroke=color, sw=9)


def mountain(w=160, h=90, fill="#4B5F6A"):
    return path(f"M{-w / 2:.1f} 0 L{-w * 0.15:.1f} {-h:.1f} L{w * 0.1:.1f} {-h * 0.55:.1f} L{w * 0.25:.1f} {-h * 0.8:.1f} L{w / 2:.1f} 0 Z", fill=fill)


def moon(r=18):
    return circle(0, 0, r, "#F4E3B0") + circle(r * 0.4, -r * 0.2, r * 0.85, NIGHT)


def note_shapes(color=INK):
    return "".join([
        ellipse(-6, 10, 6, 4.5, color),
        line(-0.5, 10, -0.5, -12, color, 2.5),
        path("M-0.5 -12 Q8 -10 10 -2", stroke=color, sw=2.5),
    ])


# ---- 交通 ----

def car(w=70, color=SAGE):
    h = w * 0.34
    return "".join([
        path(f"M{-w * 0.3:.1f} {-h * 0.5:.1f} L{-w * 0.18:.1f} {-h * 1.25:.1f} H{w * 0.2:.1f} L{w * 0.34:.1f} {-h * 0.5:.1f} Z", fill=color),
        rect(-w / 2, -h * 0.55, w, h * 0.7, color, rx=h * 0.25),
        path(f"M{-w * 0.14:.1f} {-h * 1.1:.1f} H{w * 0.16:.1f} L{w * 0.24:.1f} {-h * 0.6:.1f} H{-w * 0.22:.1f} Z", fill=SKY),
        circle(-w * 0.28, h * 0.15, h * 0.3, INK),
        circle(w * 0.28, h * 0.15, h * 0.3, INK),
        circle(-w * 0.28, h * 0.15, h * 0.12, GREY),
        circle(w * 0.28, h * 0.15, h * 0.12, GREY),
    ])


def bus(w=110, color=GOLD):
    h = w * 0.42
    out = [rect(-w / 2, -h, w, h, color, rx=8)]
    for i in range(4):
        out.append(rect(-w / 2 + 8 + i * (w - 16) / 4, -h + 8, (w - 16) / 4 - 5, h * 0.36, SKY, rx=3))
    out += [
        circle(-w * 0.28, 0, h * 0.2, INK),
        circle(w * 0.28, 0, h * 0.2, INK),
        circle(-w * 0.28, 0, h * 0.08, GREY),
        circle(w * 0.28, 0, h * 0.08, GREY),
    ]
    return "".join(out)


def scooter(w=54, color=TERRACOTTA):
    h = w * 0.5
    return "".join([
        circle(-w * 0.34, 0, h * 0.26, INK),
        circle(w * 0.34, 0, h * 0.26, INK),
        path(f"M{-w * 0.36:.1f} {-h * 0.2:.1f} H{w * 0.1:.1f} L{w * 0.3:.1f} {-h * 0.9:.1f}", stroke=color, sw=8),
        rect(-w * 0.4, -h * 0.55, w * 0.42, h * 0.22, INK_SOFT, rx=4),
        line(w * 0.22, -h * 0.95, w * 0.42, -h * 0.95, INK, 3.5),
    ])


def bike(w=54, color=SEA_DARK):
    r = w * 0.2
    return "".join([
        circle(-w * 0.3, 0, r, "none", stroke=INK, sw=3),
        circle(w * 0.3, 0, r, "none", stroke=INK, sw=3),
        path(f"M{-w * 0.3:.1f} 0 L{-w * 0.08:.1f} {-r * 1.5:.1f} H{w * 0.16:.1f} L{w * 0.3:.1f} 0 M{-w * 0.08:.1f} {-r * 1.5:.1f} L{w * 0.04:.1f} 0 L{w * 0.16:.1f} {-r * 1.5:.1f}", stroke=color, sw=3.5),
        line(-w * 0.14, -r * 1.75, 0, -r * 1.75, INK, 3.5),
    ])


def road(w, y, h=40):
    out = [rect(0, y, w, h, "#8E9793")]
    x = 12
    while x < w:
        out.append(rect(x, y + h / 2 - 2, 22, 4, WHITE, rx=2))
        x += 44
    return "".join(out)


def clipboard(w=90, tallies=(4, 7, 2)):
    h = w * 1.25
    out = [
        rect(-w / 2, -h / 2, w, h, "#B98B62", rx=6),
        rect(-w / 2 + 7, -h / 2 + 12, w - 14, h - 20, WHITE, rx=3),
        rect(-w * 0.18, -h / 2 - 5, w * 0.36, 14, INK_SOFT, rx=4),
    ]
    colors = [SAGE, TERRACOTTA, GOLD]
    for row, n in enumerate(tallies):
        y = -h / 2 + 34 + row * 26
        out.append(circle(-w / 2 + 20, y, 6, colors[row % 3]))
        for i in range(n):
            x = -w / 2 + 34 + i * 6.5
            out.append(line(x, y - 7, x, y + 7, INK, 2))
    return "".join(out)


def dot_chart(w=180, h=110, counts=(3, 6, 2, 4, 1)):
    out = [rect(-w / 2, -h, w, h, WHITE, rx=6, stroke=LINE, sw=1.5), line(-w / 2 + 10, -14, w / 2 - 10, -14, INK_SOFT, 2)]
    colors = [SAGE, TERRACOTTA, GOLD, SEA_DARK, ROSE]
    col_w = (w - 20) / len(counts)
    for i, n in enumerate(counts):
        cx = -w / 2 + 10 + col_w * (i + 0.5)
        for j in range(n):
            out.append(circle(cx, -24 - j * 13, 5.5, colors[i % 5]))
    return "".join(out)


def gate(w=120, h=90):
    return "".join([
        rect(-w / 2, -h, 14, h, "#A9B3AE", rx=3),
        rect(w / 2 - 14, -h, 14, h, "#A9B3AE", rx=3),
        rect(-w / 2 - 6, -h - 14, w + 12, 18, SAGE, rx=4),
    ])


# ---- 成長 ----

def baby(s=44):
    return "".join([
        ellipse(0, s * 0.25, s * 0.42, s * 0.5, APRICOT_LIGHT),
        path(f"M{-s * 0.4:.1f} {s * 0.2:.1f} Q0 {s * 0.55:.1f} {s * 0.4:.1f} {s * 0.2:.1f}", stroke=APRICOT, sw=4),
        circle(0, -s * 0.28, s * 0.3, SKIN),
        path(f"M{-s * 0.1:.1f} {-s * 0.55:.1f} q{s * 0.1:.1f} {-s * 0.12:.1f} {s * 0.2:.1f} 0", stroke=HAIR, sw=3),
        circle(-s * 0.1, -s * 0.3, s * 0.03, INK),
        circle(s * 0.1, -s * 0.3, s * 0.03, INK),
        path(f"M{-s * 0.07:.1f} {-s * 0.17:.1f} Q0 {-s * 0.1:.1f} {s * 0.07:.1f} {-s * 0.17:.1f}", stroke=INK, sw=1.4),
    ])


def sock(s=26, color=BLUSH):
    return path(f"M{-s * 0.3:.1f} {-s * 0.6:.1f} H{s * 0.15:.1f} V{s * 0.1:.1f} Q{s * 0.6:.1f} {s * 0.15:.1f} {s * 0.6:.1f} {s * 0.45:.1f} Q{s * 0.6:.1f} {s * 0.7:.1f} {s * 0.2:.1f} {s * 0.7:.1f} H{-s * 0.3:.1f} Z", fill=color) + rect(-s * 0.3, -s * 0.6, s * 0.45, s * 0.2, WHITE)


def height_ruler(h=150, marks=6):
    out = [rect(-9, -h, 18, h, WHITE, rx=3, stroke=LINE, sw=1.5)]
    for i in range(1, marks):
        y = -h * i / marks
        out.append(line(-9, y, 0 if i % 2 else 5, y, TERRACOTTA, 2))
    return "".join(out)


# ---- 冬天 ----

def snowflake(r=12, color=WHITE, sw=2.4):
    out = []
    for a in (0, 60, 120):
        x = math.cos(math.radians(a)) * r
        y = math.sin(math.radians(a)) * r
        out.append(line(-x, -y, x, y, color, sw))
        for sign in (-1, 1):
            bx, by = sign * x * 0.6, sign * y * 0.6
            for da in (-40, 40):
                ex = bx + math.cos(math.radians(a + da)) * sign * r * 0.3
                ey = by + math.sin(math.radians(a + da)) * sign * r * 0.3
                out.append(line(bx, by, ex, ey, color, sw * 0.8))
    return "".join(out)


def pause_icon(s=22, color=INK):
    return circle(0, 0, s, WHITE, stroke=color, sw=2.5) + rect(-s * 0.36, -s * 0.42, s * 0.24, s * 0.84, color, rx=2) + rect(s * 0.12, -s * 0.42, s * 0.24, s * 0.84, color, rx=2)


def puddle(w=90, color=SEA):
    return ellipse(0, 0, w / 2, w * 0.13, color)


def heartbeat(w=60, color=ROSE):
    return path(f"M{-w / 2:.1f} 0 H{-w * 0.2:.1f} L{-w * 0.1:.1f} -12 L0 12 L{w * 0.1:.1f} -6 L{w * 0.18:.1f} 0 H{w / 2:.1f}", stroke=color, sw=3)
