"""產生範本教案的插圖(SVG)。

用法(專案根目錄):
    python scripts/build_lesson_art.py            # 產生 assets/lessons/*.svg
    python scripts/build_lesson_art.py --gallery DIR   # 另外輸出一頁 gallery.html 方便檢視

每篇教案:一張封面 {id}-cover.svg(400×225)與三張流程圖 {id}-1/2/3.svg(320×240)。
圖形零件在 scripts/lesson_art/parts.py,場景在 scripts/lesson_art/scenes.py。
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))

from lesson_art import parts as P  # noqa: E402
from lesson_art.scenes import BG_OVERRIDE, CH, CW, SCENES, SH, SW  # noqa: E402


def main() -> None:
    out_dir = ROOT / "assets" / "lessons"
    out_dir.mkdir(parents=True, exist_ok=True)
    names = []
    for lesson_id, (bg, cover, steps) in SCENES.items():
        name = f"{lesson_id}-cover.svg"
        (out_dir / name).write_text(P.svg(CW, CH, cover(), bg), encoding="utf-8", newline="\n")
        names.append(name)
        for index, step in enumerate(steps, start=1):
            name = f"{lesson_id}-{index}.svg"
            step_bg = BG_OVERRIDE.get((lesson_id, index), bg)
            (out_dir / name).write_text(P.svg(SW, SH, step(), step_bg), encoding="utf-8", newline="\n")
            names.append(name)
    print(f"OK: {len(names)} svg -> {out_dir}")

    if "--gallery" in sys.argv:
        gallery_dir = Path(sys.argv[sys.argv.index("--gallery") + 1])
        gallery_dir.mkdir(parents=True, exist_ok=True)
        rows = []
        for lesson_id in SCENES:
            cells = "".join(
                f'<figure><img src="{lesson_id}-{suffix}.svg"><figcaption>{lesson_id}-{suffix}</figcaption></figure>'
                for suffix in ("cover", "1", "2", "3")
            )
            rows.append(f'<div class="row">{cells}</div>')
        for name in names:
            (gallery_dir / name).write_text((out_dir / name).read_text(encoding="utf-8"), encoding="utf-8")
        html = (
            "<!doctype html><meta charset='utf-8'><title>lesson art</title>"
            "<style>body{font-family:sans-serif;background:#eee;margin:12px}"
            ".row{display:flex;gap:10px;margin-bottom:10px}"
            "figure{margin:0}img{height:118px;border-radius:8px;display:block}"
            "figcaption{font-size:11px;color:#555}</style>" + "".join(rows)
        )
        (gallery_dir / "gallery.html").write_text(html, encoding="utf-8")
        print(f"gallery -> {gallery_dir / 'gallery.html'}")


if __name__ == "__main__":
    main()
