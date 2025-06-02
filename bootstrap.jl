(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

ENV["GENIE_ENV"]="prod"
using AeroSmurf
const UserApp = AeroSmurf
AeroSmurf.main()
