"""
Check that each LLMClient's system prompt names only tools that the LLMClient is offered.

Smarter offers an LLMClient the tools of the extensions in its spec.extensions, under the names
ext_<slug>_<tool>, with the slug's hyphens as underscores, e.g. ext_date_calculator_add. A system
prompt that names a tool of an extension that the manifest doesn't list sends the model looking for
a tool that isn't there. Nor may a prompt name a former built-in function that the extensions
replaced: get_current_weather, or date_calculator on its own.

pre-commit passes the LLMClient manifests to check as arguments. It exits with code 1 if any fails.
"""

import re
import sys

import yaml

FUNCTION_NAME_PREFIX = "ext_"
EXTENSION_TOOL = re.compile(rf"\b{FUNCTION_NAME_PREFIX}[a-z0-9_]+\b")
REMOVED_FUNCTIONS = (re.compile(r"\bget_current_weather\b"), re.compile(r"(?<!ext_)(?<!_)\bdate_calculator\b"))


def problems(path: str) -> list[str]:
    """Return what is wrong with the system prompt of the LLMClient manifest at path."""
    with open(path, encoding="utf-8") as f:
        manifest = yaml.safe_load(f) or {}
    spec = manifest.get("spec") or {}
    prompt = ((spec.get("config") or {}).get("prompt") or {}).get("defaultSystemRole") or ""
    extensions = spec.get("extensions") or []
    prefixes = [f"{FUNCTION_NAME_PREFIX}{slug.replace('-', '_')}_" for slug in extensions]
    retval = [
        f"{path}: the system prompt names {tool}, which is not a tool of the extensions it lists: {extensions}"
        for tool in EXTENSION_TOOL.findall(prompt)
        if not any(tool.startswith(prefix) for prefix in prefixes)
    ]
    retval += [
        f"{path}: the system prompt names {pattern.search(prompt).group(0)}, which extensions replaced"
        for pattern in REMOVED_FUNCTIONS
        if pattern.search(prompt)
    ]
    return retval


def main(paths: list[str]) -> int:
    found = [problem for path in paths for problem in problems(path)]
    for problem in found:
        print(problem)
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
