#!/bin/bash

# Check if keymap-drawer is installed
if ! command -v keymap &> /dev/null
then
    echo "keymap-drawer could not be found. Installing..."
    pip install keymap-drawer
fi

echo "Parsing keymap..."
keymap parse -z config/charybdis.keymap > config/charybdis.yaml

echo "Injecting trackball information..."
python3 -c '
import yaml
with open("config/charybdis.yaml", "r") as f:
    data = yaml.safe_load(f)
# Add trackball/scroll "virtual" combos to layers
if "combos" not in data:
    data["combos"] = []
data["combos"].extend([
    {"p": [5, 6], "k": "TRACKBALL", "l": ["0"]},
    {"p": [5, 6], "k": "SCROLL", "l": ["1"]},
    {"p": [5, 6], "k": "SCROLL", "l": ["5"]}
])
with open("config/charybdis.yaml", "w") as f:
    yaml.dump(data, f)
'

echo "Fixing layout for drawing..."
# Create a temporary info.json that keymap-drawer understands
python3 -c '
import json
with open("config/charybdis.json", "r") as f:
    data = json.load(f)
data["layouts"] = {"LAYOUT": data["layouts"]["default_transform"]}
with open("config/charybdis_info.json", "w") as f:
    json.dump(data, f)
'

echo "Drawing keymap to keymap.svg..."
keymap draw -j config/charybdis_info.json config/charybdis.yaml > keymap.svg

# Clean up
rm config/charybdis_info.json

echo "Done!"
