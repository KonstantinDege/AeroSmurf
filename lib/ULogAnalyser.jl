# lib/MyLib.jl
module ULogAnalyser

using PyCall

ULog = pyimport_conda("pyulog", "pyulog").ULog


m(x) = "$(x.timestamp): $(x.message)"
pythagoras(x...) = sqrt(sum(x .^ 2))

function get_dis(c)
    posvec = hcat(c["x"], c["y"], c["z"])
    relvec = zeros(size(posvec)[1]-1, size(posvec)[2])
    for i in 1:(size(posvec)[1]-1)
        relvec[i,:] = posvec[i+1,:] - posvec[i,:]
    end
    sum([pythagoras(relvec[i,:]...) for i in 1:size(relvec)[1]])
end

function ulog_analysis(file)
  msg = []
  time = []
  er = []
  heights = []
  dist = []
  way = []
  current = []
  l = ULog(file)
  append!(msg, m.(l.logged_messages))

  #time
  k = findfirst((x) -> x.name == "vehicle_status", l.data_list)
  tot = l.data_list[k].data["takeoff_time"]
  tt = l.data_list[k].data["timestamp"]

  try
    push!(time, Float64(Int(tt[findlast(!iszero, tot)])
              -
              Int(tt[findfirst(!iszero, tot)])) / 10^6)
  catch
    push!(er, l)
  end

  #height
  k = findfirst((x) -> x.name == "estimator_local_position", l.data_list)
  push!(heights, maximum(l.data_list[k].data["dist_bottom"]))

  d = pythagoras.(l.data_list[k].data["x"], l.data_list[k].data["y"], l.data_list[k].data["z"])
      push!(dist, maximum(d))
      push!(way, get_dis(l.data_list[k].data))

  k = findfirst((x) -> x.name == "battery_status", l.data_list)
  push!(current, maximum(l.data_list[k].data["current_a"]))

  
  Dict(
    "sumtime" => sum(time),
    "maxtime" => maximum(time),
    "maxheight" => maximum(heights),
    "maxdist" => maximum(dist),
    "dist" => maximum(way),
    "maxcurrent" => maximum(current),
    # msg => msg
  )
end

end
