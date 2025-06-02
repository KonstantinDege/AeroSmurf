using Genie.Router

route("/") do
  serve_static_file("welcome.html")
end

using AeroSmurf.AdminController

route("/admin", AdminController.index, named = :get_home)

using AeroSmurf.BaseController
route("/aerosmurf", BaseController.index)
using AeroSmurf.BaseController
route("/qr", BaseController.qr)

using AeroSmurf.ImageController
route("/images", ImageController.main)

using AeroSmurf.ObjectController
route("/objects", ObjectController.main)

using AeroSmurf.UlogsController
route("/ulog", UlogsController.main)
