#!/usr/bin/env python3
"""Move a bar widget between the regular layout and the plugin dropdown."""

from __future__ import annotations

import json
import os
import shutil
import sys
import tempfile
from pathlib import Path


def entry_id(entry: object) -> str:
    if isinstance(entry, dict):
        return str(entry.get("id", ""))
    return str(entry or "")


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: plugin-folder-layout.py WIDGET_ID TARGET_SECTION INDEX", file=sys.stderr)
        return 2

    widget_id, target, raw_index = sys.argv[1:]
    if target not in {"folder", "left", "center", "right", "remove"}:
        print(f"invalid target section: {target}", file=sys.stderr)
        return 2
    try:
        index = max(0, int(raw_index))
    except ValueError:
        print(f"invalid index: {raw_index}", file=sys.stderr)
        return 2

    config_path = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "omarchy/shell.json"
    if not config_path.is_file():
        print(f"shell configuration not found: {config_path}", file=sys.stderr)
        return 1

    try:
        config = json.loads(config_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        print(f"could not read shell configuration: {exc}", file=sys.stderr)
        return 1

    bar = config.setdefault("bar", {})
    layout = bar.setdefault("layout", {})
    folder = bar.setdefault("pluginFolder", {}).setdefault("widgets", [])
    if not isinstance(folder, list):
        print("bar.pluginFolder.widgets must be an array", file=sys.stderr)
        return 1

    moving = None
    for section in ("left", "center", "right"):
        entries = layout.setdefault(section, [])
        if not isinstance(entries, list):
            print(f"bar.layout.{section} must be an array", file=sys.stderr)
            return 1
        for pos, entry in enumerate(entries):
            if entry_id(entry) == widget_id:
                moving = entries.pop(pos)
                break
        if moving is not None:
            break

    if moving is None:
        for pos, entry in enumerate(folder):
            if entry_id(entry) == widget_id:
                moving = folder.pop(pos)
                break

    if moving is None:
        print(f"widget is no longer in the bar or plugin folder: {widget_id}", file=sys.stderr)
        return 1

    if target == "folder":
        folder.insert(min(index, len(folder)), moving)
        plugins = config.setdefault("plugins", [])
        if not isinstance(plugins, list):
            print("plugins must be an array", file=sys.stderr)
            return 1
        if not any(isinstance(plugin, dict) and entry_id(plugin) == widget_id for plugin in plugins):
            plugins.append({"id": widget_id})
    elif target in {"left", "center", "right"}:
        entries = layout.setdefault(target, [])
        entries.insert(min(index, len(entries)), moving)

    backup_path = config_path.with_name(config_path.name + ".plugin-folder.bak")
    shutil.copy2(config_path, backup_path)
    fd, temp_name = tempfile.mkstemp(prefix=".shell.json.", dir=config_path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(config, stream, ensure_ascii=False, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(temp_name, config_path.stat().st_mode & 0o777)
        os.replace(temp_name, config_path)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
