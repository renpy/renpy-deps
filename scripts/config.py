import json
import os.path

# The computer used for windows builds.
windows_host = "lucy12"

# The username used for mac builds.
mac_user = "tom"

# The hostname used for mac builds.
mac_host = "mary12"

# Ditto, for pi builds.
pi_user = "pi"
pi_host = "lisichka.local"

config_fn = os.path.join(os.path.dirname(__file__), "config.json")
if os.path.exists(config_fn):
    with open(config_fn) as f:
        config = json.load(f)

        windows_host = config.get("windows_host", windows_host)

        mac_user = config.get("mac_user", mac_user)
        mac_host = config.get("mac_host", mac_host)

        pi_user = config.get("pi_user", pi_user)
        pi_host = config.get("pi_host", pi_host)
