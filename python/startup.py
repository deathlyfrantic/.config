import atexit
import os
import readline
import sys

histfile = os.path.join(os.getenv('XDG_DATA_HOME'), 'python', 'history')

try:
    readline.read_history_file(histfile)
    # default history len is -1 (infinite), which may grow unruly
    readline.set_history_length(1000)
except:
    pass

atexit.register(readline.write_history_file, histfile)

def register_readline_completion():
    # rlcompleter must be loaded for Python-specific completion
    try: import readline, rlcompleter
    except ImportError: return
    # Enable tab-completion
    readline_doc = getattr(readline, '__doc__', '')
    if readline_doc is not None and 'libedit' in readline_doc:
        readline.parse_and_bind('bind ^I rl_complete')
    else:
        readline.parse_and_bind('tab: complete')

sys.__interactivehook__ = register_readline_completion
