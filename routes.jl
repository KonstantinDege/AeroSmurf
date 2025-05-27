using Genie.Router

route("/") do
  serve_static_file("welcome.html")
end

using AeroSmurf.AdminController

route("/admin", AdminController.index, named = :get_home)