from openapi_core import OpenAPI
from openapi_core.contrib.requests import RequestsOpenAPIRequest
import requests
import json
import sys

if len(sys.argv) != 3:
    print("Usage: python3 validate-openapi.py <request.json>")
    sys.exit(1)

yaml = sys.argv[1]
openapi = OpenAPI.from_file_path(yaml)

with open(sys.argv[2], "r") as f:
    data = json.load(f)

# data muss z.B. enthalten: method, path, body (und optional headers)
base_url = "http://petstore.swagger.io/v1"
req = requests.Request(
    method=data["method"],
    url=base_url + data["path"],
    headers=data.get("headers"),
    params=data.get("query"),   # optional für query-parameter wie limit
    json=data.get("body"),
).prepare()

openapi_request = RequestsOpenAPIRequest(req)

try:
    openapi.validate_request(openapi_request)   # wirft Exception bei Fehler
    print("✅ Request ist valide")
except Exception as e:
    print("❌ Validierung fehlgeschlagen:")
    print(e)
