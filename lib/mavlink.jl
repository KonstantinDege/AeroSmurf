module MavLink

using AeroSmurf.MavLinkBackground
using Distributed
using Observables 
io = Observable("")

function start(ip)
	@async MavLinkBackground.start(io,ip)
end

function get_status()
	io[]
end

function update_obs(obs)
	@async while true
		obs[] = io[]
	end
end
function update_obs(obs, filter_func::Function)
	@async while true
		status = get_status()
		if filter_func(status)
			obs[] = status
		end
	end
end


end
