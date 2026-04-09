# Chinese Localization

This branch adds a Simplified Chinese localization layer for Joystick Gremlin.

## Files

- `translations/joystick_gremlin_zh_CN.ts`
  Contains the Simplified Chinese translations.
- `gremlin/i18n.py`
  Loads Qt TS files at runtime. This avoids requiring `lrelease`/`.qm` files.
- `joystick_gremlin.py`
  Installs the translator during application startup.
- `joystick_gremlin.spec`
  Includes the `translations/` directory in packaged builds.
- `gremlin/ui/action_model.py`
  Translates action names shown in the "Add Action" menu.
- `gremlin/ui/option.py`
  Translates dynamic option page content such as section names, group names,
  option titles, descriptions, and selection values.

## Update Strategy

For future upstream updates, most localization maintenance should happen in:

- `translations/joystick_gremlin_zh_CN.ts`

If upstream adds new UI text and the existing translation hooks still cover the
new code paths, updating this TS file is enough.

If upstream changes how text is generated, review these files as well:

- `gremlin/i18n.py`
- `gremlin/ui/action_model.py`
- `gremlin/ui/option.py`

The runtime translator is intentionally designed to fall back to the original
English source text when no translation is found. Missing translations should
never render as blank text.

## Running From Source

```powershell
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -U pip
pip install PySide6 PyInstaller pywin32 jsonschema miniaudio
python joystick_gremlin.py
```

## Packaging

```powershell
.\.venv\Scripts\pyinstaller.exe -y --clean joystick_gremlin.spec
```

The packaged executable is generated in:

- `dist/joystick_gremlin/joystick_gremlin.exe`

## vJoy Requirement

Joystick Gremlin still depends on vJoy for normal operation. Install and
configure vJoy before testing the localized build.

## Notes

- This localization covers static QML text and dynamic text sourced from Python
  models.
- Older configuration files may miss `description` fields. Compatibility logic
  was added so the options pages continue to render instead of failing or
  showing blank content.
