import csv, json, sys, argparse, logging
from pathlib import Path

ALLOWED_BENEFIT_TYPE = {"cash","food","health","tax_credit","housing","utility","childcare","other"}
ALLOWED_INPUT_TYPE   = {"number","boolean","select","date","currency","multiselect"}
ALLOWED_CONTACT_TYPE = {"email","sms","whatsapp","url","none"}
ALLOWED_SESSION_STATUS = {"in_progress","submitted","evaluated","archived"}

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger("etl")

def _enum(val, allowed, field, idx):
    v = val.strip().lower()
    if v and v not in allowed:
        log.warning("Row %s: invalid %s '%s'", idx, field, val)
    return v or None

def transform(row, idx):
    obj = {
        "slug": row.get("program_slug", "").strip() or f"row_{idx}",
        "name": row.get("name", "").strip(),
        "benefit_type": _enum(row.get("benefit_type", ""), ALLOWED_BENEFIT_TYPE, "benefit_type", idx),
        "country": row.get("country", "").strip().upper(),
        "contact_type": _enum(row.get("contact_type", ""), ALLOWED_CONTACT_TYPE, "contact_type", idx),
        "session_status": _enum(row.get("session_status", ""), ALLOWED_SESSION_STATUS, "session_status", idx),
        "input_type": _enum(row.get("input_type", ""), ALLOWED_INPUT_TYPE, "input_type", idx),
        "description": row.get("description", "").strip(),
    }
    logic_raw = row.get("eligibility_logic", "").strip()
    if logic_raw:
        try:
            obj["eligibility_logic"] = json.loads(logic_raw)
        except json.JSONDecodeError as e:
            log.error("Row %s: invalid eligibility_logic JSON: %s", idx, e)
            obj["eligibility_logic"] = None
    else:
        obj["eligibility_logic"] = None
    return obj

def main():
    ap = argparse.ArgumentParser(description="CSV→JSON converter for benefit programs")
    ap.add_argument("csv_path")
    ap.add_argument("-o", "--output")
    args = ap.parse_args()

    with open(args.csv_path, newline='', encoding='utf-8') as fh:
        sample = fh.read(4096)
        fh.seek(0)
        try:
            dialect = csv.Sniffer().sniff(sample)
        except csv.Error:
            dialect = csv.excel
        data = [transform(r, i) for i, r in enumerate(csv.DictReader(fh, dialect=dialect), 1)]

    out = json.dumps(data, ensure_ascii=False, indent=2)
    if args.output:
        Path(args.output).write_text(out, encoding='utf-8')
        print(f"Wrote {len(data)} records to {args.output}")
    else:
        sys.stdout.write(out)

if __name__ == "__main__":
    main()
