module AdminController

using GenieAuthentication, Genie.Renderer, Genie.Exceptions, Genie.Renderer.Html

using GenieFramework
using Stipple, Stipple

using AeroSmurf: AeroSmurf, FILE_PATH


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

	# @out upfiles = readdir(FILE_PATH)
	# @out data_name_list = []
	# @in mission_file = []
	# @in upload_mission = false

	# @onbutton upload_mission begin
	# 	@info "Uploading mission file: $(mission_file["name"])"
	# end
	# @onchange fileuploads begin
	# 	@info "File uploads changed: $(fileuploads)"
	# end

	@in mission_file = ""
	@in SendMission = false

	@out data_name_list = readdir(FILE_PATH)
	@out upfiles = readdir(FILE_PATH)
	@onchange fileuploads begin
		@info "File was uploaded: " fileuploads
		if !isempty(fileuploads)
			@info "File was uploaded: " fileuploads
			filename = fileuploads["name"]

			try
				isdir(FILE_PATH) || mkpath(FILE_PATH)
				mv(fileuploads["path"], joinpath(FILE_PATH, filename), force = true)
			catch e
				@error "Error processing file: $e"
				notify(__model__, "Error processing file: $(fileuploads["name"])")
			end

			fileuploads = Dict{AbstractString, AbstractString}()
		end
		upfiles = readdir(FILE_PATH)
	end
	@onbutton SendMission begin
		@info "SendMission to Pi at $(PiIp)"
	end
end

using AeroSmurf.AdminViews


function index()
	model = @init
	page(model, AdminViews.ui) |> html
end

end
