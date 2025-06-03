using Distributed
using Observables
addprocs(1)
test = RemoteChannel()






@everywhere include("lib/mavlink.jl")


io = RemoteChannel()

task = @spawnat :any MavLinkBackground.start(io)


running = true
@async while running
    println(take!(io))
end


take!(io)