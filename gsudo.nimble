# Package

version       = "1.0.0"
author        = "Mac Taylor"
description   = "A gksudo replacement for wayland"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["gsudo"]


# Dependencies
requires "nim >= 2.2.4"
requires "https://github.com/BigMacTaylor/nim2gtk.git"

# Foreign Dependencies
foreignDeps = @["libgtk-3-0"]

task release, "Build release":
    exec "nim c -d:release -d:strip --opt:size -o:bin/gsudo src/gsudo.nim"
