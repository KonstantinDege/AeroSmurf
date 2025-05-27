module AdminController

using GenieAuthentication, Genie.Renderer, Genie.Exceptions, Genie.Renderer.Html

using GenieFramework
using Stipple, StippleUI

using AeroSmurf: AeroSmurf

@app begin
	@in PiIp = "ltraspi02.local:4269"
	@in MavIp = "localhost:14550"
	@in PiConnect = false
	@in MavConnect = false
	@onbutton MavConnect begin
		@info "Connecting to MAVLink at $(MavIp)"
	end
	@onbutton PiConnect begin
		@info "Connecting to Pi at $(PiIp)"
	end
	@out Pi_status = false
	@out mav_status = false

	@out upfiles = readdir(AeroSmurf.FILE_PATH)
	@out data_name_list = []
  @in mission_file = []
  @in upload_mission = false

  @onbutton upload_mission begin
    @info "Uploading mission file: $(mission_file["name"])"
  end
	@onchange fileuploads begin
    @info "File uploads changed: $(fileuploads)"
	end
end

include("views.jl")
using .AdminViews


function index()
	model = @init
	page(model, AdminViews.ui) |> html
end

end
