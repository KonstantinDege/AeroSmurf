using PyCall


LOGPATH = "public/data/dump/mav_log.log"
mavlink = pyimport_conda("pymavlink.mavutil", "pymavlink")
connection = mavlink.mavlink_connection("localhost:14445")
connection.wait_heartbeat()

function get_status(con)
	m = con.recv_match(
		type = "STATUSTEXT", blocking = true)

	if !occursin("kill", lowercase(m.text))
		open(LOGPATH, "a") do f
			println(f, m.text)
		end
	end
end

println("Starting Status Updates")
while true
	get_status(connection)
end
