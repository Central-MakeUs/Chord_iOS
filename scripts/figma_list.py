#!/usr/bin/env python3
import argparse
import json
import os
import sys
import urllib.request


def fetch_file(file_key: str, token: str) -> dict:
  url = f"https://api.figma.com/v1/files/{file_key}"
  req = urllib.request.Request(url, headers={"X-Figma-Token": token})
  with urllib.request.urlopen(req) as resp:
    return json.load(resp)


def print_top_level_frames(document: dict) -> None:
  doc = document.get("document", {})
  for canvas in doc.get("children", []):
    if canvas.get("type") != "CANVAS":
      continue
    print(f"Canvas: {canvas.get('name')} ({canvas.get('id')})")
    for node in canvas.get("children", []):
      if node.get("type") in ("FRAME", "COMPONENT", "COMPONENT_SET"):
        print(f"  {node.get('name')} [{node.get('type')}] {node.get('id')}")


def print_all_frames(document: dict, depth: int = 1) -> None:
  doc = document.get("document", {})
  for canvas in doc.get("children", []):
    if canvas.get("type") != "CANVAS":
      continue
    print(f"Canvas: {canvas.get('name')} ({canvas.get('id')})")
    for node in canvas.get("children", []):
      walk(node, depth)


def walk(node: dict, depth: int) -> None:
  node_type = node.get("type")
  name = node.get("name", "")
  node_id = node.get("id", "")
  if node_type in ("FRAME", "COMPONENT", "COMPONENT_SET"):
    print(f"{'  ' * depth}{name} [{node_type}] {node_id}")
  for child in node.get("children", []):
    walk(child, depth + 1)


def main() -> int:
  parser = argparse.ArgumentParser()
  parser.add_argument("--file-key", required=True)
  parser.add_argument("--deep", action="store_true", help="List nested frames/components")
  parser.add_argument("--write-json", default="", help="Write raw file JSON to this path")
  args = parser.parse_args()

  token = os.environ.get("FIGMA_TOKEN")
  if not token:
    print("FIGMA_TOKEN not set", file=sys.stderr)
    return 1

  data = fetch_file(args.file_key, token)
  if args.write_json:
    with open(args.write_json, "w", encoding="utf-8") as handle:
      json.dump(data, handle, ensure_ascii=False, indent=2)

  if args.deep:
    print_all_frames(data)
  else:
    print_top_level_frames(data)
  return 0


if __name__ == "__main__":
  raise SystemExit(main())
