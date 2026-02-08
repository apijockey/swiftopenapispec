# validate_request_body.py
import json
import sys
from openapi_schema_validator import OAS30WriteValidator, OAS31Validator
from openapi_schema_validator.readers import read_from_filename
# Wenn du: nur ein JSON prüfen willst
# kein HTTP-Kontext hast
# z. B. Config- oder Payload-Validierung brauchst
# spec_file = sys.argv[1]
# schema_pointer = sys.argv[2]   # z.B. "#/components/schemas/Order"
#json_file = sys.argv[3]

spec = read_from_filename(spec_file)

with open(json_file) as f:
    instance = json.load(f)

if spec["openapi"].startswith("3.0"):
    validator = OAS30WriteValidator(spec)
else:
    validator = OAS31Validator(spec)

validator.validate(instance, schema_pointer)
print("✅ valid")
