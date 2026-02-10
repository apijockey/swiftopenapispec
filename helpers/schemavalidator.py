#!/usr/bin/env python3
from __future__ import annotations
import argparse
import sys
from typing import Any, Dict, List, Tuple, Iterable, Optional
from jsonschema import Draft7Validator
from jsonschema.exceptions import ValidationError

def _validate_schema_definitions(spec: Dict[str, Any]) -> List[Tuple[str, str]]:
    """
    Prüft Schema-Definitionen auf häufige OpenAPI 3.0-Fehler.
    Gibt eine Liste von Fehlern zurück: [(Pfad, Fehlermeldung), ...]
    """
    errors: List[Tuple[str, str]] = []

    # 1. Erlaubte type/format-Kombinationen (OpenAPI 3.0)
    VALID_FORMATS = {
        "string": {"date", "date-time", "password", "byte", "binary", "email", "uuid", "uri", "hostname", "ipv4", "ipv6"},
        "number": {"float", "double"},
        "integer": {"int32", "int64"},
    }

    # 2. Regeln für Constraints (min/max, minLength/maxLength, etc.)
    NUMBER_TYPES = {"number", "integer"}
    STRING_TYPES = {"string"}

    def _check_schema(schema: Dict[str, Any], path: str) -> None:
        if not isinstance(schema, dict):
            return

        # --- Regel 1: type/format-Kombination ---
        schema_type = schema.get("type")
        schema_format = schema.get("format")
        if schema_type in VALID_FORMATS and schema_format not in VALID_FORMATS.get(schema_type, set()):
            errors.append((path, f"'format: {schema_format}' ist nicht erlaubt für 'type: {schema_type}'"))

        # --- Regel 2: minLength/maxLength nur für strings ---
        if schema_type in STRING_TYPES:
            if "minLength" in schema and not isinstance(schema["minLength"], int):
                errors.append((path, "'minLength' muss ein Integer sein"))
            if "maxLength" in schema and not isinstance(schema["maxLength"], int):
                errors.append((path, "'maxLength' muss ein Integer sein"))
            if "minLength" in schema and "maxLength" in schema:
                if schema["minLength"] > schema["maxLength"]:
                    errors.append((path, "'minLength' darf nicht größer als 'maxLength' sein"))
        else:
            if "minLength" in schema or "maxLength" in schema:
                errors.append((path, "'minLength'/'maxLength' sind nur für 'type: string' erlaubt"))

        # --- Regel 3: minimum/maximum/exclusiveMinimum/exclusiveMaximum nur für numbers/integers ---
        if schema_type in NUMBER_TYPES:
            for prop in ["minimum", "maximum"]:
                if prop in schema and not isinstance(schema[prop], (int, float)):
                    errors.append((path, f"'{prop}' muss eine Zahl sein"))
            if "minimum" in schema and "maximum" in schema:
                if schema["minimum"] > schema["maximum"]:
                    errors.append((path, "'minimum' darf nicht größer als 'maximum' sein"))
        else:
            for prop in ["minimum", "maximum", "exclusiveMinimum", "exclusiveMaximum"]:
                if prop in schema:
                    errors.append((path, f"'{prop}' ist nur für 'type: number/integer' erlaubt"))

        # --- Regel 4: pattern nur für strings ---
        if schema_type not in STRING_TYPES and "pattern" in schema:
            errors.append((path, "'pattern' ist nur für 'type: string' erlaubt"))

        # --- Regel 5: multipleOf nur für numbers/integers ---
        if schema_type not in NUMBER_TYPES and "multipleOf" in schema:
            errors.append((path, "'multipleOf' ist nur für 'type: number/integer' erlaubt"))

        # --- Regel 6: minItems/maxItems nur für arrays ---
        if schema.get("type") == "array":
            for prop in ["minItems", "maxItems"]:
                if prop in schema and not isinstance(schema[prop], int):
                    errors.append((path, f"'{prop}' muss ein Integer sein"))
            if "minItems" in schema and "maxItems" in schema:
                if schema["minItems"] > schema["maxItems"]:
                    errors.append((path, "'minItems' darf nicht größer als 'maxItems' sein"))
        else:
            for prop in ["minItems", "maxItems", "uniqueItems"]:
                if prop in schema:
                    errors.append((path, f"'{prop}' ist nur für 'type: array' erlaubt"))

        # --- Regel 7: minProperties/maxProperties nur für objects ---
        if schema.get("type") == "object":
            for prop in ["minProperties", "maxProperties"]:
                if prop in schema and not isinstance(schema[prop], int):
                    errors.append((path, f"'{prop}' muss ein Integer sein"))
            if "minProperties" in schema and "maxProperties" in schema:
                if schema["minProperties"] > schema["maxProperties"]:
                    errors.append((path, "'minProperties' darf nicht größer als 'maxProperties' sein"))
        else:
            for prop in ["minProperties", "maxProperties"]:
                if prop in schema:
                    errors.append((path, f"'{prop}' ist nur für 'type: object' erlaubt"))

        # --- Regel 8: required nur für objects ---
        if schema.get("type") != "object" and "required" in schema:
            errors.append((path, "'required' ist nur für 'type: object' erlaubt"))

        # --- Regel 9: nullable (OpenAPI 3.0) ---
        if "nullable" in schema and not isinstance(schema["nullable"], bool):
            errors.append((path, "'nullable' muss ein Boolean sein"))

        # --- Regel 10: readOnly/writeOnly nur für properties ---
        for prop in ["readOnly", "writeOnly"]:
            if prop in schema and not isinstance(schema[prop], bool):
                errors.append((path, f"'{prop}' muss ein Boolean sein"))

        # --- Regel 11: allOf/anyOf/oneOf müssen Arrays sein ---
        for prop in ["allOf", "anyOf", "oneOf"]:
            if prop in schema and not isinstance(schema[prop], list):
                errors.append((path, f"'{prop}' muss ein Array sein"))

        # --- Regel 12: discriminator nur mit allOf/anyOf/oneOf ---
        if "discriminator" in schema and not any(p in schema for p in ["allOf", "anyOf", "oneOf"]):
            errors.append((path, "'discriminator' ist nur mit 'allOf'/'anyOf'/'oneOf' erlaubt"))

        # --- Rekursiv in Unter-Schemata ---
        for prop_name, sub_schema in schema.get("properties", {}).items():
            _check_schema(sub_schema, f"{path}.properties.{prop_name}")
        if "items" in schema:
            _check_schema(schema["items"], f"{path}.items")
        for i, sub_schema in enumerate(_as_list(schema.get("allOf", []))):
            _check_schema(sub_schema, f"{path}.allOf[{i}]")
        for i, sub_schema in enumerate(_as_list(schema.get("anyOf", []))):
            _check_schema(sub_schema, f"{path}.anyOf[{i}]")
        for i, sub_schema in enumerate(_as_list(schema.get("oneOf", []))):
            _check_schema(sub_schema, f"{path}.oneOf[{i}]")

    # Prüfe alle Schemata in components/schemas
    if "components" in spec and "schemas" in spec["components"]:
        for name, schema in spec["components"]["schemas"].items():
            _check_schema(schema, f"#/components/schemas/{name}")

    return errors


def _as_list(x: Any) -> List[Any]:
    if x is None:
        return []
    return x if isinstance(x, list) else [x]


def _collect_examples_from_media(media_obj: Dict[str, Any]) -> List[Any]:
    """
    Collect examples from an OpenAPI Media Type Object:
      - example: <any>
      - examples: {name: {value: <any>} | <any>}
    """
    out: List[Any] = []

    if isinstance(media_obj, dict) and "example" in media_obj:
        out.append(media_obj["example"])

    exs = media_obj.get("examples") if isinstance(media_obj, dict) else None
    if isinstance(exs, dict):
        for _, ex in exs.items():
            if isinstance(ex, dict) and "value" in ex:
                out.append(ex["value"])
            else:
                out.append(ex)

    return out


def _collect_examples_from_schema(schema_obj: Any) -> List[Any]:
    """
    Collect examples from a Schema Object:
      - example: <any>
      - examples: [<any>, ...]   (mainly JSON Schema style; harmless for OAS 3.0)
    """
    out: List[Any] = []
    if isinstance(schema_obj, dict):
        if "example" in schema_obj:
            out.append(schema_obj["example"])
        if "examples" in schema_obj:
            out.extend(_as_list(schema_obj["examples"]))
    return out


def _iter_request_response_schemas(spec: Dict[str, Any]) -> Iterable[Tuple[str, Dict[str, Any], List[Any]]]:
    """
    Yields tuples (where, schema_dict, examples_list) for:
      - requestBody content schemas
      - response content schemas
    only when a schema exists and at least one example exists.
    """
    paths = spec.get("paths") or {}
    if not isinstance(paths, dict):
        return

    http_methods = {"get", "put", "post", "delete", "patch", "options", "head", "trace"}

    for path, path_item in paths.items():
        if not isinstance(path_item, dict):
            continue

        for method, op in path_item.items():
            if not isinstance(method, str) or method.lower() not in http_methods:
                continue
            if not isinstance(op, dict):
                continue

            # requestBody
            rb = op.get("requestBody")
            if isinstance(rb, dict):
                content = rb.get("content") or {}
                if isinstance(content, dict):
                    for ctype, media in content.items():
                        if not isinstance(media, dict):
                            continue
                        schema = media.get("schema")
                        if not isinstance(schema, dict):
                            continue

                        examples: List[Any] = []
                        examples += _collect_examples_from_media(media)
                        examples += _collect_examples_from_schema(schema)

                        if examples:
                            where = f"{method.upper()} {path} requestBody {ctype}"
                            yield (where, schema, examples)

            # responses
            responses = op.get("responses") or {}
            if isinstance(responses, dict):
                for code, resp in responses.items():
                    if not isinstance(resp, dict):
                        continue
                    content = resp.get("content") or {}
                    if not isinstance(content, dict):
                        continue
                    for ctype, media in content.items():
                        if not isinstance(media, dict):
                            continue
                        schema = media.get("schema")
                        if not isinstance(schema, dict):
                            continue

                        examples: List[Any] = []
                        examples += _collect_examples_from_media(media)
                        examples += _collect_examples_from_schema(schema)

                        if examples:
                            where = f"{method.upper()} {path} response {code} {ctype}"
                            yield (where, schema, examples)


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Validate an OpenAPI spec (3.0/3.1) and validate inline examples against their schemas."
    )
    parser.add_argument("spec_path", help="Path to OpenAPI spec file (YAML or JSON).")
    parser.add_argument(
        "--no-examples",
        action="store_true",
        help="Only validate the OpenAPI spec file; skip validating inline examples.",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print full exception details (very verbose).",
    )
    args = parser.parse_args(argv)

    # Imports here so the script still prints usage even if deps aren't installed.
    try:
        from openapi_spec_validator import validate_spec
        from openapi_spec_validator.readers import read_from_filename
    except Exception as e:
        print("❌ Missing dependency for spec validation. Install:")
        print("   python -m pip install openapi-spec-validator")
        print(f"   Details: {e}")
        return 3

    try:
        from openapi_schema_validator import validate as validate_instance
        from jsonschema.exceptions import ValidationError as JsonSchemaValidationError
    except Exception as e:
        print("❌ Missing dependency for schema/example validation. Install:")
        print("   python -m pip install openapi-schema-validator jsonschema")
        print(f"   Details: {e}")
        return 3

    # robust: exception name differs across openapi-spec-validator versions
    try:
        from openapi_spec_validator.exceptions import OpenAPIValidationError  # type: ignore
    except Exception:
        from openapi_spec_validator.exceptions import OpenAPISpecValidatorError as OpenAPIValidationError  # type: ignore

    failures = 0
    checks = 0

    # 1) Spec validation
    try:
        spec, _base_uri = read_from_filename(args.spec_path)
        validate_spec(spec)
        print("✅ Spec-Validierung OK (OpenAPI-Datei ist formal valide)")
    except OpenAPIValidationError as e:
        print("❌ Spec-Validierung FEHLER:")
        if args.verbose:
            print(e)
        else:
            msg = getattr(e, "message", None) or str(e).splitlines()[0]
            print(f"   → {msg}")
        return 1
    except Exception as e:
        print("❌ Fehler beim Laden/Validieren der Spec:")
        if args.verbose:
            print(e)
        else:
            msg = getattr(e, "message", None) or str(e).splitlines()[0]
            print(f"   → {msg}")
        return 3

    if args.no_examples:
        return 0
   # 1.5) Schema-Definitionen prüfen (type/format-Kombinationen)
    schema_errors = _validate_schema_definitions(spec)
    if schema_errors:
        print("❌ Schema-Definitionsfehler:")
        for path, msg in schema_errors:
            print(f"   → {msg} (Pfad: {path})")
        failures += len(schema_errors)


    # 2) Example validation (best-effort, inline examples only)
    for where, schema, examples in _iter_request_response_schemas(spec):
        for i, ex in enumerate(examples):
            checks += 1
            try:
                validate_instance(ex, schema)
            except JsonSchemaValidationError as e:
                failures += 1
                path = ".".join(str(p) for p in e.path) or "<root>"
                print(f"❌ Schema-Fehler: {where} (example #{i+1})")
                if args.verbose:
                    print(e)
                else:
                    msg = getattr(e, "message", None) or str(e).splitlines()[0]
                    print(f"   → {msg} @ {path}")
            except Exception as e:
                failures += 1
                print(f"❌ Unerwarteter Fehler: {where} (example #{i+1})")
                print(e if args.verbose else f"   → {e.__class__.__name__}: {e}")

    if checks == 0:
        print("ℹ️ Keine inline examples/examples gefunden – nur Spec-Validierung durchgeführt.")
        return 0

    if failures == 0:
        print(f"✅ Beispiel-Validierung OK ({checks} Beispiele geprüft)")
        return 0

    print(f"❌ Beispiel-Validierung: {failures}/{checks} fehlgeschlagen")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
