# Poverty Benefit Program ETL

`convert_csv_to_schema_json.py` converts a flat CSV export of the *Master Programs* sheet
into structured JSON objects that comply with the frozen **Data-Schema**
(§7 value-enums & §8 eligibility rule template).

The goal is to feed these JSON objects into both:
1. the front-end benefit screener (to show program cards & run eligibility rules)
2. downstream analytics pipelines.

## Installation
```bash
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt  # only `python-dateutil` + `pytest` for tests
```

## Usage
```bash
python convert_csv_to_schema_json.py path/to/programs.csv -o programs.json
```
If `-o/--output` is omitted, prettified JSON is written to stdout.

The script performs light validation:
* warns about enum values outside the allowed sets
* attempts to parse `eligibility_logic` as JSON, logging parse errors

## Column Mapping
| CSV column | JSON key | Notes |
|------------|----------|-------|
| program_slug | slug | fallback `row_<N>` if empty |
| name | name | – |
| benefit_type | benefit_type | validated vs §7 enum |
| country | country | upper-cased ISO-3166-1 alpha-2 |
| contact_type | contact_type | validated |
| session_status | session_status | validated |
| input_type | input_type | validated |
| description | description | – |
| eligibility_logic | eligibility_logic | JSON string → object |

## Testing
Run the unit test suite with:
```bash
pytest -q
```
Tests live in `tests/` and cover:
* happy-path row → JSON object transformation
* enum validation warning capture
* graceful handling of malformed `eligibility_logic`

## Releasing
Nothing fancy yet – just tag & push. Once the API stabilises we will publish to
PyPI as `poverty-etl`.
