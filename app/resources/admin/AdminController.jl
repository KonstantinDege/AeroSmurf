module AdminController

using GenieAuthentication, Genie.Renderer, Genie.Exceptions, Genie.Renderer.Html

using GenieFramework
using Stipple, Stipple

using AeroSmurf: AeroSmurf, FILE_PATH
using AeroSmurf.RaspiConnection: rec_serialize
using JSON

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


	@in mission_file = [""]
	@in SendMission = false

	@in fileuploads = Dict{String, String}()
	@out data_name_list = readdir(FILE_PATH)
	@out mission_content = ""
	@onchange fileuploads begin
		if !isempty(fileuploads)
			name = fileuploads["name"]
			tmp  = fileuploads["path"]
			try
				# ensure the directory exists
				isdir(FILE_PATH) || mkpath(FILE_PATH)
				# move (overwrite) into place
				mv(tmp, joinpath(FILE_PATH, name); force = true)
			catch err
				@error "Error saving upload to disk: $err"
				notify(model, "Error saving file $name")
			end
			fileuploads = Dict{String, String}()
		end
		# refresh listing
		data_name_list = sort(readdir(FILE_PATH))
	end
	@onchange mission_file begin
		@info "Selected mission file: $(mission_file)"
		if !isempty(mission_file)
			file_path = joinpath(FILE_PATH, mission_file[1])
			if isfile(file_path)
				data = JSON.parsefile(file_path)
				rec_serialize(data["commands"])
				delete!(data, raw"$schema")
				mission_content = JSON.json(data)
			else
				mission_content = "File not found."
			end
		else
			mission_content = ""
		end
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
