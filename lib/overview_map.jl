module OverviewMap
using CoordinateTransformations, Rotations
using MeshIO, FileIO, GeometryBasics, LinearAlgebra
using CoordRefSystems, CoordGridTransforms
using Unitful
include("raspi_connection.jl")
using .RaspiConnection: PATH, read_json_lines
using GLMakie

const m1 = 1u"m"

function project_onto_z(pos, rot_dir)
	z = pos[3]
	Δz = -rot_dir[3]
	return Point3f(pos + rot_dir * z / Δz)
end

function gen_mesh(fov_ver, fov_hor, x_detail = 3, y_detail = 3)
	# needs to also generate all vertices, from angles; is not scalable vertices need to match detail
	x_range = LinRange(1, 0, x_detail)
	y_range = LinRange(0, 1, y_detail)

	_normals = Point3f.([[0, 0, 1] for _ in x_range, _ in y_range][:])
	faces = TriangleFace[]
	for x in 1:(length(x_range)-1)
		for y in 1:(length(y_range)-1)
			push!(faces,
				TriangleFace(length(x_range) * (y - 1) + x,
					length(x_range) * (y - 1) + x + 1,
					length(x_range) * y + x))
			push!(faces,
				TriangleFace(length(x_range) * (y - 1) + x + 1,
					length(x_range) * y + x,
					length(x_range) * y + 1 + x))
		end
	end
	uv_buff = Buffer(Vec2f[[x, y] for x in x_range, y in y_range][:])
	ver = LinearMap(RotXYZ(deg2rad.([0, 0, 90])...)).(
		[[x, y, -1] for x in LinRange(-sin(fov_hor), sin(fov_hor), x_detail),
		y in LinRange(-sin(fov_ver), sin(fov_ver), y_detail)][:])
	ver2 = LinearMap(RotXYZ(deg2rad.([0, 0, 90])...)).(
		[[x, y, -1] for x in LinRange(-sin(fov_hor), sin(fov_hor), 3),
		y in LinRange(-sin(fov_ver), sin(fov_ver), 3)][:])

	(transform, drone_pos, offset = 0) -> begin
		vertices = Point3f.([project_onto_z(drone_pos, v) + Point3f(0, 0, offset) for v in transform.(ver)])
		vertices2 = Point3f.([project_onto_z(drone_pos, v) for v in transform.(ver2)])

		return GeometryBasics.Mesh(
			vertices, faces; uv = uv_buff, normal = _normals,
		), vertices2
	end
end

gen_rotate(dir) = LinearMap(RotZYX(deg2rad.(dir)...)) |> inv
gen_rotate_rad(dir) = LinearMap(RotZYX(dir...)) |> inv

fov_hor = deg2rad(66) / 2
fov_ver = deg2rad(41) / 2
const mesh_gen = gen_mesh(fov_ver, fov_hor, 5, 5)



function get_data_from_json()
	file = "$PATH/__data__.json"
    if !isfile(file) return [] end
	open(file, "r") do f
		return read_json_lines(f)
	end
end

function render(fig)
	count = 1
    allready_rendered = []
	scene = LScene(fig[1, 1])
	poses = Observable(Point3f[])
	origin = get_xy(48.7670587, 11.334912)
	lines!(scene, poses)

    @async begin
        while true
            json = get_data_from_json()
            add_to_scene(scene, json, allready_rendered, count, poses, origin)
            sleep(5)
        end
    end
end

function add_to_scene(scene, json, allready_rendered, count, poses, origin)
	for image in json
		if image["time"] in allready_rendered
			continue
		end
		path = joinpath(PATH, image["raw_path"])
		if !isfile(path)
			continue
		end
		png = load(path)
		attitude = image["image_pos"][6:-1:4]
		if image["height"] < -4
			continue
		end
        @info image["time"]
        llh_raw = get_xy(image["image_pos"][1:2]...) - origin - Point3f(11140.25, 0, 0.0)
		pos = llh_raw + Point3f(0, 0, -image["height"])

		m, original_vecs = mesh_gen(gen_rotate(attitude), pos, 1e-4 * count)

		p = mesh!(scene, m, color = Sampler(png), transparency = true)
		# linesegments!(scene, [(v, pos) for v in original_vecs], color = :gray)
		# scatter!(scene, pos)
		count += 1
		push!(poses[], pos)
		push!(allready_rendered, image["time"])
	end
	notify(poses)
end

function get_xy(lat, lon)
	pos = convert(Mercator, LatLon(lat, lon))
	return Point3f(pos.x / m1, pos.y / m1, 0.0)
end

end
