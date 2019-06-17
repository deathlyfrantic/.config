import atexit
import os
import readline
import rlcompleter
import sys

histfile = os.path.join(os.getenv("XDG_DATA_HOME"), "python-history")

try:
    readline.read_history_file(histfile)
    # default history len is -1 (infinite), which may grow unruly
    readline.set_history_length(1000)
except:
    pass

atexit.register(readline.write_history_file, histfile)

# Enable tab-completion
if "libedit" in readline.__doc__:
    readline.parse_and_bind("bind ^I rl_complete")
else:
    readline.parse_and_bind("tab: complete")
