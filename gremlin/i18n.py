# -*- coding: utf-8; -*-

# SPDX-License-Identifier: GPL-3.0-only

from __future__ import annotations

from pathlib import Path
from xml.etree import ElementTree

from PySide6 import QtCore


class TsTranslator(QtCore.QTranslator):

    """Loads a subset of Qt Linguist TS files directly at runtime."""

    def __init__(self, parent: QtCore.QObject | None = None) -> None:
        super().__init__(parent)
        self._messages: dict[tuple[str, str, str], str] = {}

    def load_ts(self, fpath: str | Path) -> bool:
        tree = ElementTree.parse(str(fpath))
        root = tree.getroot()

        self._messages.clear()
        for context_node in root.findall("context"):
            context_name = context_node.findtext("name", "")
            for message in context_node.findall("message"):
                source = message.findtext("source", "")
                if not source:
                    continue

                translation_node = message.find("translation")
                if translation_node is None:
                    continue

                translation = translation_node.text or ""
                if not translation:
                    continue

                comment = message.findtext("comment", "") or ""
                self._messages[(context_name, source, comment)] = translation

        return bool(self._messages)

    def translate(
        self,
        context: str,
        source_text: str,
        disambiguation: str | None = None,
        n: int = -1
    ) -> str:
        del n
        comment = disambiguation or ""
        return self._messages.get(
            (context, source_text, comment),
            self._messages.get((context, source_text, ""), source_text)
        )


def install_translator(app: QtCore.QCoreApplication, base_path: str | Path) -> str | None:
    """Loads and installs a translator matching the current locale."""
    locale_name = QtCore.QLocale.system().name()
    candidates = [
        Path(base_path) / "translations" / f"joystick_gremlin_{locale_name}.ts",
        Path(base_path) / "translations" / f"joystick_gremlin_{locale_name.split('_')[0]}.ts",
        Path(base_path) / "translations" / "joystick_gremlin_zh_CN.ts",
    ]

    for candidate in candidates:
        if not candidate.is_file():
            continue

        translator = TsTranslator(app)
        if translator.load_ts(candidate):
            app.installTranslator(translator)
            setattr(app, "_gremlin_translator", translator)
            return candidate.stem

    return None
