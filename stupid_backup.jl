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



send = RaspiConnection.upload_mission


println("""
    Functions: 
        send(file)
        get_data
        save_filterd
""")
    
# RaspiConnection.save_filterd()
