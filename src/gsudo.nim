# ========================================================================================
#
#                                   Gsudo
#                          version 1.0.1 by Mac_Taylor
#
# ========================================================================================

import nim2gtk/[gtk, gdk, glib, gobject]
import std/os
import osproc

const cssData =
  """
entry {
    border-radius: 8px;
    padding: 6px;
}
button {
    border-radius: 8px;
    min-width: 16px;
    min-height: 16px;
    padding: 10px;
}
buttonbox {
    padding: 6px;
}

"""

proc passwordPromt(title: string): string =
  gtk.init()

  let dialog = newDialog()
  dialog.defaultSize = (300, 220)
  dialog.resizable = false
  dialog.setPosition(WindowPosition.center)

  let cssProvider = getDefaultCssProvider()
  discard cssProvider.loadFromData(cssData)
  addProviderForScreen(
    getDefaultScreen(), cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION
  )

  let contentArea = getContentArea(dialog)
  let actionArea = getActionArea(dialog)

  let headerBar = newHeaderBar()
  headerBar.title = title

  cast[ButtonBox](actionArea).setLayout(ButtonBoxStyle.expand)
  actionArea.setSpacing(6)
  #actionArea.set_size_request(-1, 50)
  #actionArea.setBorderWidth(6)

  let grid = newGrid()
  grid.setRowSpacing(10)
  grid.setColumnSpacing(20)
  grid.marginStart = 50
  grid.marginEnd = 50
  grid.marginTop = 35
  grid.marginBottom = 35
  grid.halign = Align.center

  let icon = newImageFromIconName("dialog-password", IconSize.dialog.ord)
  grid.attach(icon, 0, 0, 1, 1)

  let text = newLabel("Enter your password")
  text.halign = Align.start
  grid.attach(text, 1, 0, 1, 1)

  let label = newLabel("Password:")
  label.halign = Align.end
  grid.attach(label, 0, 1, 1, 1)

  let entry = newEntry()
  entry.visibility = false
  entry.activatesDefault = true
  grid.attach(entry, 1, 1, 1, 1)

  discard dialog.addButton("Cancel", ResponseType.cancel.ord)
  discard dialog.addButton("Authenticate", ResponseType.accept.ord)
  dialog.defaultResponse = ResponseType.accept.ord

  contentArea.add(grid)
  dialog.setTitlebar(headerBar)
  dialog.showAll()

  let response = dialog.run()

  if ResponseType(response) != ResponseType.accept:
    quit(0)

  let password = entry.getText()

  dialog.destroy()

  return password

proc main() =
  if paramCount() > 2:
    echo "Error: Too many paramters"
    quit(0)
  elif paramCount() == 0:
    return

  let arg =
    if paramCount() == 1:
      paramStr(1)
    else:
      paramStr(1) & " " & paramStr(2)
  var cmd: string
  var status: int
  var password: string
  var title = "Authentication Required"

  discard execCmd("sudo -k")

  while true:
    password = title.passwordPromt()

    if password == "":
      title = "Password empty, try again"
      continue

    # Check if password is valid
    cmd = "echo " & password & " | sudo -S -v"
    status = execCmd(cmd)

    if status != 0:
      title = "Wrong password, try again"
      continue
    else:
      break

  let env =
    """env WAYLAND_DISPLAY="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" XDG_RUNTIME_DIR=/user/run/0 """
  cmd = "echo " & password & " | sudo -S " & env & arg & " &"
  status = execCmd(cmd)
  if status == 0:
    echo "success"
  else:
    echo "Error: Command exited with status code: " & $status

main()
