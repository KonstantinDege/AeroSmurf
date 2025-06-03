using WGLMakie
fig = Figure()
using Revise

includet("lib/overview_map.jl")
using .OverviewMap: render



render(fig)