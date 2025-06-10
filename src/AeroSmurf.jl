module AeroSmurf

using Genie

using Sockets
const FILE_PATH = joinpath("public", "uploads")
mkpath(FILE_PATH)

using JSONSchema
using JSON: JSON
const MISSION_SCHEMA = Schema(JSON.parsefile(raw"schemas/mission_schema.json"))

const up = Genie.up
export up

function main()
	Genie.genie(; context = @__MODULE__)
end
function StartLocalServer(port = 8000)
	up(port, "0.0.0.0")
	ip = getipaddr()
	addr = "http://$ip:$port/images"
	# exportqrcode(addr, "public/img/website.png"; eclevel = High())
	println("Server running at $addr")
end
export StartLocalServer

end
