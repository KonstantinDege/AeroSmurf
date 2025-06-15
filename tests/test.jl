using JSON
using CoordRefSystems, CoordGridTransforms
using Unitful
using GLMakie

const m1 = 1u"m"

function get_xy(lat, lon)
	pos = convert(Mercator, LatLon(lat, lon))
	return Point3f(pos.x / m1, pos.y / m1, 0.0)
end


data = JSON.parsefile("tests/__data_filtered__.json")

pos1 = get_xy(data["blue"][1]["lat"], data["blue"][1]["lon"])

function create_point(d)
    get_xy(d["lat"], d["lon"]) - pos1
end

create_point.(data["blue"])