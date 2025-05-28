include("lib/raspi_connection.jl")
using .RaspiConnection
using Base.Threads

FILE_PATH = joinpath("public", "dump", "data")
mkpath(FILE_PATH)

function clear_path(path = FILE_PATH)
	for (root, dirs, files) in walkdir(path)
		for file in files
			rm(joinpath(root, file))
		end
	end
end


function get_data()
	data = RaspiConnection.get_obj_data()
	if data isa Vector
		data = RaspiConnection.get_all_images(data)
	else

	end

end

send = RaspiConnection.upload_mission

function save_all()
    RaspiConnection.save_filterd()
    get_data()
end

println("""
    Functions: 
        send(file)
        get_data
        save_filterd
""")
    
# RaspiConnection.save_filterd()
