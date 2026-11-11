"""範本教案的 40 個場景:每篇一張封面(400×225)與三張流程圖(320×240)。

封面的主體放在中間 225×225 的範圍內——列表卡片會把封面裁成正方形。
"""
from __future__ import annotations

from . import parts as P
from .parts import at

CW, CH = 400, 225  # 封面
SW, SH = 320, 240  # 流程圖


def head(r, face="smile", hair=P.HAIR):
    return P.circle(0, -r * 0.08, r * 1.06, hair) + P.circle(0, r * 0.06, r * 0.94, P.SKIN) + P._face(face, r * 0.1, r / 0.17)


def q(x, y, size=34, color=P.TERRACOTTA):
    return P.text(x, y, "?", size, color)


def floor(w, h, fill, top=0.8):
    return P.rect(0, h * top, w, h * (1 - top), fill)


# ============ 101 摸摸看,是玉米! ============
BG_CORN = "#F7EBDA"


def corn_cover():
    return "".join([
        floor(CW, CH, "#EFDDC6", 0.74),
        at(P.mystery_box(104), 140, 150),
        at(P.corn(104, P.CORN), 232, 118, rot=-12),
        at(P.corn(92, "#F4EBD0"), 276, 124, rot=8),
        at(P.corn(80, "#9A78A8"), 316, 134, rot=22),
    ])


def corn_1():
    return "".join([
        floor(SW, SH, "#EFDDC6"),
        at(P.mystery_box(130), 200, 150),
        at(P.kid(104, P.SAGE, pose="reach_r", face="wow"), 78, 226),
        q(262, 70, 30), q(292, 96, 22),
    ])


def corn_2():
    prints = "".join(
        P.circle(-52 + c * 15, -30 + r * 15, 4.6, P.CORN_DEEP if (r + c) % 2 else P.CORN)
        for r in range(5) for c in range(6)
    )
    return "".join([
        floor(SW, SH, "#EFDDC6"),
        at(P.paper(150, 112), 150, 128),
        at(prints, 158, 128),
        at(P.corn(74, P.CORN, husk=False), 70, 128, rot=90),
        at(P.kid(96, P.TERRACOTTA, pose="reach_l", hair=P.HAIR_2), 262, 228),
    ])


def corn_3():
    out = [floor(SW, SH, "#EFDDC6"), P.line(20, 46, 300, 46, P.INK_SOFT, 2)]
    colors = [P.CORN_DEEP, "#9A78A8", P.TERRACOTTA]
    for i, x in enumerate((70, 160, 250)):
        out.append(at(P.clip(P.SAGE), x, 48))
        out.append(at(P.paper(72, 86), x, 100))
        out.append(at(P.paint_dots(colors[i], 6, 24), x, 100))
    out.append(at(P.kid(82, P.SAGE, pose="wave"), 105, 232))
    out.append(at(P.kid(82, P.ROSE, pose="up", hair=P.HAIR_2, hair_style="long"), 215, 232))
    return "".join(out)


# ============ 102 大海裡有誰? ============
BG_SEA = "#E4EEF3"


def sea_cover():
    return "".join([
        at(P.sun(20), 320, 46),
        P.wave(CW, 104, 9, P.SEA, CH),
        at(P.shark_fin(40), 205, 118),
        P.wave(CW, 128, 9, P.SEA_DEEP, CH, phase=1),
        P.rect(0, 178, CW, 50, P.SEA_DARK),
        at(P.fish(58, P.APRICOT), 160, 168),
        at(P.fish(44, P.BLUSH, facing=-1), 262, 192),
        at(P.seaweed(46), 116, 228),
        at(P.seaweed(36, "#7BA066"), 296, 228),
    ])


def sea_1():
    return "".join([
        P.wave(SW, 112, 8, P.SEA, SH),
        P.wave(SW, 138, 8, P.SEA_DEEP, SH, phase=1),
        P.rect(0, 172, SW, 70, P.APRICOT_LIGHT),
        at(P.sound_waves(16), 190, 116, rot=180),
        at(P.kid(108, P.SAGE, pose="down", face="closed"), 96, 230),
        q(250, 70, 32, P.SEA_DARK),
    ])


def sea_2():
    return "".join([
        floor(SW, SH, "#D5E3E9"),
        at(P.book_open(190), 138, 132),
        at(P.fish(46, P.APRICOT), 182, 126),
        at(P.wave(70, 0, 5, P.SEA, 26), 58, 128),
        at(P.teacher(118, P.TERRACOTTA, pose="reach_l"), 268, 236),
        at(P.speech_bubble(54, 38), 258, 52), q(258, 62, 24, P.SEA_DARK),
    ])


def sea_3():
    return "".join([
        floor(SW, SH, "#D5E3E9"),
        P.rect(52, 40, 216, 132, P.SEA, rx=6),
        at(P.wave(216, 0, 6, P.SEA_DEEP, 40), 52, 132),
        at(P.fish(40, P.APRICOT), 110, 92),
        at(P.fish(32, P.BLUSH, facing=-1), 196, 76),
        at(P.fish(28, P.WHITE), 206, 122),
        at(P.seaweed(34), 90, 172),
        at(P.kid(84, P.SAGE, pose="reach_r"), 36, 234),
        at(P.kid(84, P.GOLD, pose="reach_l", hair=P.HAIR_2), 286, 234),
    ])


# ============ 103 是誰咬了大餅? ============
BG_CAKE = "#F5ECDD"


def cake_cover():
    return "".join([
        floor(CW, CH, "#ECDFCB", 0.78),
        at(P.cake(72, BG_CAKE, "round"), 172, 116),
        at(P.pig(38, "wow"), 282, 150),
        q(288, 92, 36),
    ])


def cake_1():
    return "".join([
        floor(SW, SH, "#ECDFCB"),
        at(P.cake(62, BG_CAKE, "round"), 208, 128),
        at(P.pig(46, "wow"), 92, 150),
        q(96, 84, 34), q(132, 62, 22),
    ])


def cake_2():
    out = [floor(SW, SH, "#ECDFCB", 0.86)]
    for x, bite in ((66, "tri"), (160, "two"), (254, "zig")):
        out.append(at(P.cake(36, BG_CAKE, bite), x, 82))
        out.append(P.line(x, 128, x, 146, P.INK_SOFT, 2))
    out.append(at(P.bird(22), 62, 178))
    out.append(at(P.rabbit(22), 160, 186))
    out.append(at(P.croc(76), 256, 184))
    return "".join(out)


def cake_3():
    out = [floor(SW, SH, "#ECDFCB")]
    animals = [P.bird(11), P.rabbit(10), P.croc(34), P.pig(12, "smile")]
    for i, x in enumerate((58, 126, 194, 262)):
        y = 82 if i != 1 else 88
        out.append(at(P.card_small(52, 64, P.WHITE, at(animals[i], 0, 4 if i != 1 else 8)), x, 82))
        if i < 3:
            out.append(P.path(f"M{x + 30} 82 h8 l-4 -4 m4 4 l-4 4", stroke=P.INK_SOFT, sw=2))
        _ = y
    out.append(at(P.kid(84, P.SAGE, pose="wave"), 100, 234))
    out.append(at(P.kid(84, P.TERRACOTTA, pose="down", hair=P.HAIR_2, face="wow"), 215, 234))
    return "".join(out)


# ============ 104 我的心情天氣 ============
BG_MOOD = "#EAF0F1"
CLOUD_DARK = "#9AA5AA"


def weather_trio(gap, s=1.0):
    return "".join([
        at(P.sun(26), -gap, 0, s),
        at(P.cloud(84) + at(P.rain(54), 0, 26), 0, -6, s),
        at(P.cloud(84, CLOUD_DARK) + at(P.bolt(34), 0, 34), gap, -6, s),
    ])


def mood_cover():
    return "".join([
        floor(CW, CH, "#DDE6E8", 0.8),
        at(weather_trio(92), 200, 102),
    ])


def mood_1():
    return "".join([
        floor(SW, SH, "#DDE6E8"),
        P.rect(138, 34, 164, 104, P.WHITE, rx=8, stroke=P.LINE, sw=1.5),
        at(weather_trio(50, 0.52), 220, 86),
        at(P.teacher(126, P.TERRACOTTA, pose="reach_r", face="sad"), 78, 236),
    ])


def mood_2():
    return "".join([
        floor(SW, SH, "#DDE6E8"),
        at(P.mirror(104), 108, 118),
        at(head(34, "smile"), 108, 116),
        at(P.kid(112, P.SAGE, pose="hold", face="smile", hair=P.HAIR), 232, 232),
        at(P.sun(11), 284, 60),
    ])


def mood_3():
    out = [floor(SW, SH, "#DDE6E8"), P.rect(34, 30, 226, 150, P.WHITE, rx=8, stroke=P.LINE, sw=1.5)]
    out.append(P.line(110, 40, 110, 170, P.LINE, 1.5))
    out.append(P.line(185, 40, 185, 170, P.LINE, 1.5))
    out.append(at(P.sun(12), 72, 58))
    out.append(at(P.cloud(40) + at(P.rain(26, n=3), 0, 13, 0.7), 147, 55))
    out.append(at(P.cloud(40, CLOUD_DARK) + at(P.bolt(17), 0, 17), 222, 55))
    clips = {72: [P.SAGE, P.TERRACOTTA, P.GOLD, P.ROSE], 147: [P.SEA_DARK, P.SAGE], 222: [P.TERRACOTTA]}
    for x, colors in clips.items():
        for i, color in enumerate(colors):
            out.append(P.rect(x - 24, 84 + i * 21, 48, 15, color, rx=4))
    out.append(at(P.kid(82, P.GOLD, pose="reach_l", hair=P.HAIR_2), 290, 234))
    return "".join(out)


# ============ 105 謝謝你,抱一個 ============
BG_THANKS = "#F8EFE8"


def thanks_cover():
    return "".join([
        floor(CW, CH, "#F0E2D6", 0.8),
        at(P.teacher(128, P.SAGE, pose="reach_l"), 254, 208),
        at(P.kid(88, P.TERRACOTTA, pose="reach_r"), 150, 208),
        at(P.greeting_card(46, 34), 198, 150),
        at(P.heart(20), 200, 86),
        at(P.heart(12, P.BLUSH), 228, 62),
    ])


def thanks_1():
    out = [floor(SW, SH, "#F0E2D6", 0.84)]
    for x, hat, shirt in ((72, "chef", P.WHITE), (160, "cap", P.SEA_DEEP), (248, None, P.SAGE)):
        out.append(at(P.photo_frame(74, at(P.bust(15, shirt, hat), 0, -12)), x, 112))
    out.append(q(160, 214, 30))
    return "".join(out)


def thanks_2():
    return "".join([
        at(P.kid(112, P.TERRACOTTA, pose="hold"), 160, 182),
        P.rect(30, 150, 260, 90, P.APRICOT, rx=8),
        at(P.greeting_card(84, 60), 160, 186),
        at(P.crayon(46, P.SAGE), 70, 196, rot=-20),
        at(P.crayon(46, P.ROSE), 252, 200, rot=24),
        at(P.crayon(40, P.GOLD), 236, 176, rot=-8),
    ])


def thanks_3():
    return "".join([
        floor(SW, SH, "#F0E2D6"),
        at(P.teacher(132, P.WHITE, pose="reach_l"), 226, 232),
        P.rect(210, 78, 32, 22, P.WHITE, rx=8, stroke=P.LINE, sw=1.2),
        at(P.kid(90, P.SAGE, pose="reach_r"), 104, 232),
        at(P.greeting_card(42, 32), 158, 170),
        at(P.heart(18), 160, 96),
        at(P.heart(11, P.BLUSH), 132, 72),
        at(P.heart(11, P.BLUSH), 190, 66),
    ])


# ============ 106 春聯小畫家 ============
BG_SPRING = "#F7EDE3"


def spring_cover():
    return "".join([
        floor(CW, CH, "#EFE0D0", 0.82),
        at(P.couplet(92, "春"), 156, 112),
        at(P.couplet(72, "福"), 262, 124, rot=0),
        at(P.firecrackers(3, 12), 322, 44),
    ])


def spring_1():
    return "".join([
        floor(SW, SH, "#EFE0D0"),
        P.rect(26, 30, 214, 132, P.WHITE, rx=8, stroke=P.LINE, sw=1.5),
        at(P.couplet(62, "春"), 86, 96),
        at(P.couplet(62, "福", flip=True), 180, 96),
        at(P.teacher(118, P.SAGE, pose="reach_l"), 280, 236),
    ])


def spring_2():
    paper_red = (
        f'<g transform="rotate(45)">{P.rect(-48, -48, 96, 96, P.RED, rx=3)}</g>'
        + P.path("M-16 -8 H16 M0 -22 V20 M-14 6 H14", stroke=P.INK, sw=6)
    )
    return "".join([
        at(P.kid(112, P.SAGE, pose="reach_r"), 100, 190),
        P.rect(20, 160, 280, 80, P.APRICOT, rx=8),
        at(paper_red, 208, 168),
        at(P.brush(64), 162, 122, rot=32),
        P.rect(262, 180, 30, 22, P.INK, rx=4),
    ])


def spring_3():
    return "".join([
        floor(SW, SH, "#EFE0D0"),
        at(P.door(104, 156), 160, 218),
        P.rect(88, 66, 16, 120, P.RED, rx=2),
        P.rect(216, 66, 16, 120, P.RED, rx=2),
        at(P.couplet(56, "福"), 160, 126),
        at(P.kid(78, P.GOLD, pose="up", hair=P.HAIR_2), 52, 234),
        at(P.kid(78, P.SAGE, pose="wave"), 268, 234),
    ])


# ============ 107 年獸來了! ============
BG_NIAN = "#F5E8DE"


def nian_cover():
    return "".join([
        floor(CW, CH, "#ECDCCD", 0.84),
        at(P.nian(116), 200, 116),
        at(P.firecrackers(4, 13), 104, 38),
        at(P.firecrackers(4, 13), 300, 38),
    ])


def nian_1():
    stars = "".join(P.circle(x, y, 1.8, "#F4E3B0") for x, y in ((40, 40), (90, 70), (150, 30), (200, 62), (296, 96), (64, 110)))
    heads = "".join(at(head(17, "wow", h), x, 226) for x, h in ((70, P.HAIR), (126, P.HAIR_2), (182, P.HAIR), (238, P.HAIR_2)))
    return "".join([
        stars,
        at(P.moon(20), 262, 52),
        at(P.mountain(300, 118), 160, 204),
        at(P.nian(52), 196, 112),
        P.rect(0, 200, SW, 40, "#263238"),
        heads,
    ])


def nian_2():
    return "".join([
        floor(SW, SH, "#ECDCCD"),
        at(P.drum(74), 64, 176),
        P.line(36, 116, 54, 146, "#8A6A4A", 4), P.line(96, 112, 78, 146, "#8A6A4A", 4),
        at(P.kid(92, P.TERRACOTTA, pose="out", face="wow"), 176, 230),
        at(P.kid(92, P.SAGE, pose="up", face="wow", hair=P.HAIR_2), 262, 230),
        at(P.note_shapes(P.TERRACOTTA), 122, 70),
    ])


def nian_3():
    return "".join([
        floor(SW, SH, "#ECDCCD"),
        at(P.nian(74), 258, 122, rot=10),
        P.line(196, 104, 176, 104, P.INK_SOFT, 3), P.line(200, 124, 172, 124, P.INK_SOFT, 3), P.line(196, 144, 176, 144, P.INK_SOFT, 3),
        at(P.kid(86, P.SAGE, pose="up"), 62, 232),
        at(P.scarf(72), 62, 136),
        at(P.kid(86, P.GOLD, pose="out", hair=P.HAIR_2), 142, 232),
        at(P.pot_lid(15), 106, 180), at(P.pot_lid(15), 178, 180),
    ])


# ============ 108 校門口的交通小調查 ============
BG_ROAD = "#E6EFF2"


def road_cover():
    return "".join([
        at(P.cloud(70), 120, 50), at(P.sun(16), 300, 44),
        P.road(CW, 150, 54),
        P.rect(0, 204, CW, 24, "#C9D6CE"),
        at(P.bus(120), 236, 168),
        at(P.car(78, P.SAGE), 126, 180),
        at(P.scooter(52), 338, 186),
    ])


def road_1():
    out = [floor(SW, SH, "#D6E2E6")]
    icons = [P.car(38, P.SAGE), P.bus(44), P.bike(38)]
    counts = [3, 1, 2]
    shirts = [P.SAGE, P.TERRACOTTA, P.GOLD, P.ROSE, P.SEA_DARK, P.SAGE_MID]
    k = 0
    for i, x in enumerate((66, 160, 254)):
        out.append(P.rect(x - 34, 26, 68, 46, P.WHITE, rx=6, stroke=P.LINE, sw=1.5))
        out.append(at(icons[i], x, 56 if i != 1 else 62))
        for j in range(counts[i]):
            out.append(at(P.kid(40, shirts[k % 6], hair=P.HAIR if k % 2 else P.HAIR_2), x, 128 + j * 52))
            k += 1
    return "".join(out)


def road_2():
    return "".join([
        P.road(SW, 186, 44),
        at(P.gate(112, 96), 250, 186),
        at(P.car(64, P.TERRACOTTA), 250, 214),
        at(P.kid(96, P.SAGE, pose="hold"), 66, 236),
        at(P.clipboard(96, (4, 7, 2)), 128, 96),
    ])


def road_3():
    return "".join([
        floor(SW, SH, "#D6E2E6"),
        at(P.dot_chart(214, 150, (3, 7, 2, 5, 1)), 132, 196),
        at(P.kid(84, P.GOLD, pose="reach_l", hair=P.HAIR_2), 284, 236),
    ])


# ============ 109 我長大了! ============
BG_GROW = "#F3EEE5"


def grow_cover():
    return "".join([
        floor(CW, CH, "#E9E1D4", 0.82),
        at(P.photo_frame(92, at(P.baby(46), 0, -6)), 140, 112),
        at(P.height_ruler(158), 296, 206),
        at(P.kid(124, P.SAGE, pose="wave"), 236, 208),
    ])


def grow_1():
    out = [floor(SW, SH, "#E9E1D4", 0.86)]
    for x in (70, 160, 250):
        out.append(at(P.photo_frame(72, at(P.baby(36), 0, -6)), x, 104))
    out.append(at(P.sock(30), 132, 200))
    out.append(at(P.sock(30, P.SAGE_MID), 178, 204, rot=12))
    out.append(q(238, 214, 30))
    return "".join(out)


def grow_2():
    return "".join([
        floor(SW, SH, "#E9E1D4"),
        at(P.height_ruler(186, 7), 84, 230),
        at(P.kid(114, P.SAGE, pose="down"), 132, 230),
        P.line(94, 116, 170, 116, P.TERRACOTTA, 3),
        at(P.teacher(132, P.TERRACOTTA, pose="reach_l"), 246, 234),
    ])


def grow_3():
    return "".join([
        floor(SW, SH, "#E9E1D4", 0.88),
        at(P.paper(206, 158), 160, 116),
        at(P.photo_frame(52, at(P.baby(26), 0, -5)), 104, 90, rot=-6),
        at(P.kid(86, P.SAGE, pose="up"), 204, 156),
        P.line(84, 162, 150, 162, P.LINE, 3), P.line(84, 176, 132, 176, P.LINE, 3),
        at(P.crayon(44, P.TERRACOTTA), 60, 214, rot=-14),
        at(P.crayon(44, P.SAGE), 262, 216, rot=18),
    ])


# ============ 110 雪花定格舞 ============
BG_SNOW = "#DCE7EC"


def snow_field(w, h, pts):
    return "".join(at(P.snowflake(r), x * w, y * h) for x, y, r in pts)


def snow_cover():
    pts = [(0.3, 0.2, 13), (0.68, 0.16, 10), (0.78, 0.5, 14), (0.24, 0.55, 9), (0.5, 0.1, 8), (0.36, 0.8, 7), (0.66, 0.82, 8)]
    return "".join([
        floor(CW, CH, "#CBD9DF", 0.84),
        snow_field(CW, CH, pts),
        at(P.kid(128, P.SAGE, pose="out"), 200, 210),
        at(P.scarf(52, P.RED), 200, 138),
    ])


def snow_1():
    pts = [(0.16, 0.2, 12), (0.82, 0.24, 11), (0.74, 0.6, 9), (0.2, 0.62, 8), (0.5, 0.12, 8)]
    return "".join([
        floor(SW, SH, "#CBD9DF"),
        snow_field(SW, SH, pts),
        at(P.kid(124, P.TERRACOTTA, pose="hold", face="wow"), 160, 232),
        at(P.cloud(34, P.WHITE), 214, 120),
    ])


def snow_2():
    return "".join([
        floor(SW, SH, "#CBD9DF"),
        at(P.pause_icon(22), 160, 50),
        at(P.note_shapes(P.INK_SOFT), 104, 52), at(P.note_shapes(P.INK_SOFT), 222, 46),
        at(P.kid(100, P.SAGE, pose="up", face="wow"), 96, 232),
        at(P.kid(100, P.GOLD, pose="out", hair=P.HAIR_2), 226, 232),
        at(P.snowflake(9), 40, 110), at(P.snowflake(9), 286, 126),
    ])


def snow_3():
    return "".join([
        floor(SW, SH, "#CBD9DF", 0.62),
        at(P.puddle(120), 108, 196), at(P.puddle(120), 222, 216),
        at(P.lying_kid(100, P.SAGE), 112, 180),
        at(P.lying_kid(100, P.TERRACOTTA, P.HAIR_2), 226, 200),
        at(P.heartbeat(84), 170, 78), at(P.heart(16), 110, 76),
        at(P.snowflake(8), 262, 60), at(P.snowflake(7), 56, 112),
    ])


def night_bg(body: str) -> str:
    return body


SCENES = {
    "seed-101": (BG_CORN, corn_cover, [corn_1, corn_2, corn_3]),
    "seed-102": (BG_SEA, sea_cover, [sea_1, sea_2, sea_3]),
    "seed-103": (BG_CAKE, cake_cover, [cake_1, cake_2, cake_3]),
    "seed-104": (BG_MOOD, mood_cover, [mood_1, mood_2, mood_3]),
    "seed-105": (BG_THANKS, thanks_cover, [thanks_1, thanks_2, thanks_3]),
    "seed-106": (BG_SPRING, spring_cover, [spring_1, spring_2, spring_3]),
    "seed-107": (BG_NIAN, nian_cover, [nian_1, nian_2, nian_3]),
    "seed-108": (BG_ROAD, road_cover, [road_1, road_2, road_3]),
    "seed-109": (BG_GROW, grow_cover, [grow_1, grow_2, grow_3]),
    "seed-110": (BG_SNOW, snow_cover, [snow_1, snow_2, snow_3]),
}

# 個別場景要換底色的(年獸的故事夜景)
BG_OVERRIDE = {("seed-107", 1): P.NIGHT}
