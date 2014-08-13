import json
import os.path

# The computer used for windows builds.
windows_host = "lucy12"

# The username used for mac builds.
mac_user = "tom"

# The hostname used for mac builds.
mac_host = "mary12"

config_fn = os.path.join(os.path.dirname(__file__), "config.json")
if os.path.exists(config_fn):
    with open(config_fn) as f:
        config = json.load(f)

        windows_host = config.get("windows_host", windows_host)
        mac_user = config.get("mac_user", mac_user)
        mac_host = config.get("mac_host", mac_host)
