module AeroSmurf

using Genie

const FILE_PATH = joinpath("public", "uploads")
mkpath(FILE_PATH)

const up = Genie.up
export up

function main()
  Genie.genie(; context = @__MODULE__)
end

end
