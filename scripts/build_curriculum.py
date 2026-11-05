# -*- coding: utf-8 -*-
"""從《幼兒園教保活動課程大綱》官方 PDF 產生課綱指標資料檔。

用法:
    python scripts/build_curriculum.py <課綱PDF路徑>

官方 PDF 下載:
    https://www.ece.moe.edu.tw/ch/preschool/.galleries/preschool-files/NEW1.pdf
    (全國教保資訊網「幼兒園教保活動課程大綱」,106 年 8 月 1 日生效版)

產出(於專案根目錄):
    lib/data/curriculum_data.dart   App 內建課綱資料(勿手改,重跑本腳本更新)
    supabase/curriculum.sql         雲端課綱參考資料表 + 資料
    docs/curriculum-review.md       給現職老師逐條核對用的清單

需求:pip install pypdf
"""
import json
import re
import sys
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parent.parent

DOMAIN_CHARS = "身認語社情美"
AGES = ["幼", "小", "中", "大"]
AGE_CODE = {"幼": "toddler", "小": "k1", "中": "k2", "大": "k3"}
AGE_LABEL = {"幼": "幼幼班", "小": "小班", "中": "中班", "大": "大班"}
DOMAIN_CODE = {
    "身": "physical", "認": "cognitive", "語": "language",
    "社": "social", "情": "emotional", "美": "aesthetic",
}
DOMAIN_LABEL = {
    "身": "身體動作與健康", "認": "認知", "語": "語文",
    "社": "社會", "情": "情緒", "美": "美感",
}

HEADER_RE = re.compile(r"課程目標\s*2-3歲學習指標")
GOAL_RE = re.compile(rf"^([{DOMAIN_CHARS}])\s*-?\s*(\d+)-(\d+)\s*$")
# 原文偶有漏連字號的代碼(如「情-中3-1-2」),前兩個連字號容錯
IND_RE = re.compile(rf"([{DOMAIN_CHARS}])\s*-?\s*(幼|小|中|大)\s*-?\s*(\d+)-(\d+)-(\d+)")
SKIP_RE = re.compile(
    r"^(\d+|身體動作與健康|認知|語文|社會|情緒|美感|課程目標.*學習指標.*|\d*幼兒園教保活動課程大綱)\s*$"
)
# 表格下方的註解區(情緒領域標題為「課程目標、學習指標說明」,需在 SKIP_RE 之前判斷)
FOOTNOTE_RE = re.compile(r"學習指標說明")


def normalize(line: str) -> str:
    # PDF 的箭頭符號會抽成 C0 控制字元,先移除再做其他判斷
    return re.sub(r"[\x00-\x1f\x7f]", "", line).strip()


def clean(text: str) -> str:
    text = re.sub(r"[\x00-\x1f\x7f]", "", text)
    text = re.sub(r"★\d*", "", text)
    text = re.sub(r"[→↑←↓]", "", text)
    text = re.sub(r"\s+", "", text)
    return text


def parse(pdf_path: Path):
    reader = PdfReader(str(pdf_path))
    pages = [(i + 1, (p.extract_text() or "").splitlines()) for i, p in enumerate(reader.pages)]
    table_pages = [(no, ls) for no, ls in pages if any(HEADER_RE.search(l) for l in ls)]
    print(f"pages: {len(pages)}, table pages: {[no for no, _ in table_pages]}")

    goals = {}
    indicators = {}
    order = []
    state = {"targets": None, "buf": []}

    def flush():
        targets, buf = state["targets"], state["buf"]
        state["targets"], state["buf"] = None, []
        if targets is None:
            return
        kind, target = targets
        text = clean("".join(buf))
        if kind == "goal":
            if not goals[target]["title"]:
                goals[target]["title"] = text
        else:
            for code in target:
                if text and not indicators[code]["text"]:
                    indicators[code]["text"] = text

    for page_no, page_lines in table_pages:
        try:
            start = next(i for i, l in enumerate(page_lines) if HEADER_RE.search(l))
        except StopIteration:
            continue
        flush()  # 跨頁不延續文字
        for raw in page_lines[start + 1:]:
            line = normalize(raw)
            if not line:
                continue
            if FOOTNOTE_RE.search(line):
                flush()
                break
            if SKIP_RE.match(line):
                continue
            ind_matches = list(IND_RE.finditer(line))
            if ind_matches:
                flush()
                codes = []
                for m in ind_matches:
                    d, age, a, b, c = m.groups()
                    code = f"{d}-{age}-{a}-{b}-{c}"
                    if code not in indicators:
                        indicators[code] = {
                            "code": code, "goal": f"{d}-{a}-{b}", "age": age,
                            "text": "", "page": page_no,
                        }
                        order.append(code)
                    codes.append(code)
                state["targets"] = ("ind", codes)
                rest = line[ind_matches[-1].end():].strip()
                if rest:
                    state["buf"].append(rest)
                continue
            gm = GOAL_RE.match(line)
            if gm:
                flush()
                d, a, b = gm.groups()
                code = f"{d}-{a}-{b}"
                if code not in goals:
                    goals[code] = {"code": code, "domain": d, "title": ""}
                state["targets"] = ("goal", code)
                continue
            state["buf"].append(line)
    flush()

    # 箭頭(延續前一年齡):同目標同流水號,往前找最近有文字的年齡
    for code in order:
        ind = indicators[code]
        if ind["text"]:
            ind["continued"] = False
            continue
        d, age, a, b, c = code.split("-")
        for prev in range(AGES.index(age) - 1, -1, -1):
            prev_ind = indicators.get(f"{d}-{AGES[prev]}-{a}-{b}-{c}")
            if prev_ind and prev_ind["text"]:
                ind["text"] = prev_ind["text"]
                break
        ind["continued"] = True

    empty = [c for c in order if not indicators[c]["text"]]
    no_title = [g for g, v in goals.items() if not v["title"]]
    if empty or no_title:
        raise SystemExit(f"解析不完整!空白指標: {empty} 無標題目標: {no_title}")
    print(f"goals: {len(goals)}, indicators: {len(indicators)}")
    return goals, indicators, order


def dart_str(s: str) -> str:
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def sort_key(code: str):
    parts = code.split("-")
    domain_i = DOMAIN_CHARS.index(parts[0])
    if len(parts) == 3:  # goal
        return (domain_i, int(parts[1]), int(parts[2]))
    return (domain_i, int(parts[2]), int(parts[3]), int(parts[4]), AGES.index(parts[1]))


def emit_dart(goals, indicators, order):
    lines = [
        "// 由 scripts/build_curriculum.py 解析官方課綱 PDF 產生,勿手動修改。",
        "// 來源:《幼兒園教保活動課程大綱》(教育部,106 年 8 月 1 日生效)",
        "// https://www.ece.moe.edu.tw/ch/preschool/.galleries/preschool-files/NEW1.pdf",
        "// 核對狀態:待現職老師依 docs/curriculum-review.md 逐條核對。",
        "import '../models/curriculum.dart';",
        "",
        "const List<CurriculumGoal> curriculumGoals = [",
    ]
    for g in sorted(goals.values(), key=lambda x: sort_key(x["code"])):
        lines.append(
            f"  CurriculumGoal(code: {dart_str(g['code'])}, "
            f"domainShortCode: {dart_str(g['domain'])}, title: {dart_str(g['title'])}),"
        )
    lines += ["];", "", "const List<CurriculumIndicator> curriculumIndicators = ["]
    for code in sorted(order, key=sort_key):
        i = indicators[code]
        lines.append(
            f"  CurriculumIndicator(code: {dart_str(i['code'])}, "
            f"goalCode: {dart_str(i['goal'])}, ageCode: {dart_str(AGE_CODE[i['age']])}, "
            f"text: {dart_str(i['text'])}, continued: {'true' if i['continued'] else 'false'}),"
        )
    lines += ["];", ""]
    (ROOT / "lib" / "data" / "curriculum_data.dart").write_text("\n".join(lines), encoding="utf-8")
    print("written lib/data/curriculum_data.dart")


def emit_sql(goals, indicators, order):
    out = [
        "-- 課綱參考資料表:由 scripts/build_curriculum.py 產生,勿手改",
        "-- 來源:《幼兒園教保活動課程大綱》(教育部,106 年 8 月 1 日生效)",
        "",
        "create table if not exists public.curriculum_goals (",
        "  code text primary key,",
        "  domain text not null,",
        "  title text not null",
        ");",
        "",
        "create table if not exists public.curriculum_indicators (",
        "  code text primary key,",
        "  goal_code text not null references public.curriculum_goals (code) on delete cascade,",
        "  age_stage text not null,",
        "  text text not null,",
        "  continued boolean not null default false",
        ");",
        "",
        "alter table public.curriculum_goals enable row level security;",
        "alter table public.curriculum_indicators enable row level security;",
        "",
        'drop policy if exists "public read curriculum_goals" on public.curriculum_goals;',
        'create policy "public read curriculum_goals"',
        "on public.curriculum_goals for select to anon, authenticated using (true);",
        "",
        'drop policy if exists "public read curriculum_indicators" on public.curriculum_indicators;',
        'create policy "public read curriculum_indicators"',
        "on public.curriculum_indicators for select to anon, authenticated using (true);",
        "",
        "insert into public.curriculum_goals (code, domain, title) values",
    ]
    goal_rows = [
        f"({sql_str(g['code'])}, {sql_str(DOMAIN_CODE[g['domain']])}, {sql_str(g['title'])})"
        for g in sorted(goals.values(), key=lambda x: sort_key(x["code"]))
    ]
    out.append(",\n".join(goal_rows))
    out.append("on conflict (code) do update set domain = excluded.domain, title = excluded.title;")
    out.append("")
    out.append("insert into public.curriculum_indicators (code, goal_code, age_stage, text, continued) values")
    ind_rows = []
    for code in sorted(order, key=sort_key):
        i = indicators[code]
        ind_rows.append(
            f"({sql_str(i['code'])}, {sql_str(i['goal'])}, {sql_str(AGE_CODE[i['age']])}, "
            f"{sql_str(i['text'])}, {'true' if i['continued'] else 'false'})"
        )
    out.append(",\n".join(ind_rows))
    out.append("on conflict (code) do update set goal_code = excluded.goal_code, "
               "age_stage = excluded.age_stage, text = excluded.text, continued = excluded.continued;")
    out.append("")
    (ROOT / "supabase" / "curriculum.sql").write_text("\n".join(out), encoding="utf-8")
    print("written supabase/curriculum.sql")


def emit_review(goals, indicators, order):
    out = [
        "# 課綱學習指標核對清單",
        "",
        "本清單由程式解析官方《幼兒園教保活動課程大綱》PDF 產生,**請現職老師逐條與紙本/官方 PDF 核對**。",
        "「頁」欄為官方 PDF 的頁碼;「承上」表示課綱表格中以箭頭延續前一年齡的指標(文字沿用前一年齡)。",
        "發現錯誤請直接在本檔標記,回報後由程式端修正。",
        "",
    ]
    for d in DOMAIN_CHARS:
        domain_goals = [g for g in sorted(goals.values(), key=lambda x: sort_key(x["code"])) if g["domain"] == d]
        if not domain_goals:
            continue
        out.append(f"## {DOMAIN_LABEL[d]}領域")
        out.append("")
        for g in domain_goals:
            out.append(f"### {g['code']} {g['title']}")
            out.append("")
            out.append("| 指標 | 年齡 | 內容 | 承上 | 頁 |")
            out.append("|---|---|---|---|---|")
            for code in sorted(order, key=sort_key):
                i = indicators[code]
                if i["goal"] != g["code"]:
                    continue
                cont = "▸" if i["continued"] else ""
                out.append(
                    f"| {i['code']} | {AGE_LABEL[i['age']]} | {i['text']} | {cont} | {i['page']} |"
                )
            out.append("")
    (ROOT / "docs" / "curriculum-review.md").write_text("\n".join(out), encoding="utf-8")
    print("written docs/curriculum-review.md")


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    goals, indicators, order = parse(Path(sys.argv[1]))
    (ROOT / "docs").mkdir(exist_ok=True)
    emit_dart(goals, indicators, order)
    emit_sql(goals, indicators, order)
    emit_review(goals, indicators, order)
    # 除錯用完整 JSON
    (ROOT / "docs" / "curriculum.json").write_text(
        json.dumps({"goals": list(goals.values()), "indicators": [indicators[c] for c in order]},
                   ensure_ascii=False, indent=1),
        encoding="utf-8",
    )
    print("done")


if __name__ == "__main__":
    main()
