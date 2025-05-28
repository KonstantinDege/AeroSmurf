using PyCall

mavlink = pyimport_conda("pymavlink.mavutil", "pymavlink")
connection = mavlink.mavlink_connection("localhost:14445")
connection.wait_heartbeat()

function get_status(con)
	m = con.recv_match(
		type = "STATUSTEXT", blocking = true)
	println("Status: ", m.text)
end

println("Starting Status Updates")
while true
	get_status(connection)
end
