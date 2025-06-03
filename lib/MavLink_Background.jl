module MavLinkBackground

using PyCall
using Distributed

function start_connection(ip = "localhost:14445")
	mavlink = pyimport_conda("pymavlink.mavutil", "pymavlink")
	connection = mavlink.mavlink_connection(ip)
	@info "Connected"
	connection.wait_heartbeat()
	@info "Established"
	return connection
end

FILE = "test.log"
function get_status(con, io)
	@info "started listening"
	on(con) do c println(c) end
	while true
		m = con.recv_match(
			type = "STATUSTEXT", blocking = true)
		con[] = m.text
		# open(FILE, "a") do f
		# 	write(f, m.text)
		# end
		sleep(1 / 60)
	end
end


function start(io, ip = "localhost:14445")
	con = start_connection(ip)
	get_status(con, io)
end

end