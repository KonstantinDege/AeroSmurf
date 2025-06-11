module AdminController

using GenieAuthentication

using GenieFramework

using JSONSchema: validate
using AeroSmurf: AeroSmurf, FILE_PATH, MISSION_SCHEMA
using AeroSmurf.RaspiConnection: rec_serialize
using JSON

using AeroSmurf.RaspiConnection
using AeroSmurf.MavLink

using AeroSmurf.RaspiConnection


const LOGPATH = "public/data/dump/mav_log.log"
RASPI_IP = ""
RASPI_Running = Observable(false)
QGCIP = ""
QGC_Running = Observable(false)

STATUS = Observable("")

@app begin
	@in PiIp = "ltraspi02.local:4269"
	@in MavIp = "localhost:14445"
	@in PiConnect = RASPI_Running[]
	@in MavConnect = QGC_Running[]
	@onbutton MavConnect begin
		@info "Connecting to MAVLink at $(MavIp)"
		if !QGC_Running[]
			global QGCIP = MavIp
			MavLink.start(QGCIP)
			MavLink.update_obs(STATUS)
			global QGC_Running[] = true
		else
			@info "already running"
		end
	end
	@onbutton PiConnect begin
		@info "Connecting to Pi at $(PiIp)"
		global RASPI_IP = PiIp
		RASPI_Running[] = !RASPI_Running[]
		Pi_status = RASPI_Running[]
		if RASPI_Running[] @async start_async() end
		@info RASPI_Running
	end
	@out Pi_status = false
	@out mav_status = false
	@out drone_status = STATUS[]

	@in mission_file = [""]
	@in SendMission = false

	@in fileuploads = Dict{String, String}()
	@out data_name_list = sort([f for f ∈ readdir(FILE_PATH) if endswith(f, ".json")])
	@out mission_content = ""
	@onchange fileuploads begin
		@info "fileuploads changed: $(fileuploads)"
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
		data_name_list = sort([f for f ∈ readdir(FILE_PATH) if endswith(f, ".json")])
	end
	@onchange mission_file begin
		@info "Selected mission file: $(mission_file)"
		if !isempty(mission_file)
			file_path = joinpath(FILE_PATH, mission_file[1])
			if isfile(file_path)
				data = JSON.parsefile(file_path)
				rec_serialize(data["commands"])
				delete!(data, raw"$schema")
				val = validate(MISSION_SCHEMA, data)
				if isnothing(val)
					@info "Mission file validated successfully."					
					mission_content = JSON.json(data)
				else
					mission_content = "FAILED VALIDATION: $(val.path)"
					@error "Validation error: $(val)"
				end
			else
				mission_content = "File not found."
			end
		else
			mission_content = ""
		end
		data_name_list = sort([f for f ∈ readdir(FILE_PATH) if endswith(f, ".json")])
	end
	@onbutton SendMission begin
		@info "SendMission to Pi at $(PiIp)"
		if RASPI_Running[]
			if !isempty(mission_file)
				file_path = joinpath(FILE_PATH, mission_file[1])
				ret = RaspiConnection.upload_mission(file_path, RASPI_IP)
				if !isnothing(ret)
					@error "Error uploading mission: $ret"
					notify(model, "Error uploading mission: $ret")
				end
			end
		else
			@info "not connected"
		end
	end
end

function start_async()
	@async while RASPI_Running[]
		RaspiConnection.save_all(RASPI_IP)
		sleep(5)
	end
	@async while RASPI_Running[]
		if isfile(LOGPATH)
			open(LOGPATH, "r") do file
				lines = readlines(file)
				model.drone_status[] = lines[end]
			end
			sleep(1/10)
		end
	end

end




using AeroSmurf.AdminViews


function index()
	authenticated!()
	global model = @init
	page(model, AdminViews.ui) |> html
end

end
