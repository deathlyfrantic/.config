IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:LOAD_MODULES] = ["irb/completion"]
IRB.conf[:HISTORY_FILE] = File::expand_path("#{ENV['XDG_DATA_HOME']}/irb-history")
IRB.conf[:SAVE_HISTORY] = 10000
