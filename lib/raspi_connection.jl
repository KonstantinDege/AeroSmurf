module RaspiConnection


using HTTP
using JSON

const url_base = "ltraspi02.local:4269"
const PATH = "public/data/dump"
mkpath(PATH)

# Upload a mission file
function upload_mission(file_path::String, url::String = url_base)
	url_full = "http://$url/mission"
	if !isfile(file_path)
		error("File $file_path does not exist.")
	end
	j = JSON.parsefile(file_path)
	rec_serialize(j["commands"])
	new = tempname()
	open(new, "w") do f
		JSON.print(f, j)
		# print(j)
	end
	open(new) do json
		headers = []
		body = HTTP.Form([
			"file" => json,
		])
		HTTP.post(url_full, headers, body)
	end
end

# Request found objects (JSON)
function request_objects(url::String = url_base)
	url_full = "http://$url/found_objects"

	resp = HTTP.get(url_full)
	if resp.status == 200
		return resp.body  # This is the raw image bytes
	else
		error("Failed to get objects: $(resp.status)")
	end
end

function request_filtered_objects(url::String = url_base)
	url_full = "http://$url/found_objects_filtered"
	resp = HTTP.get(url_full)
	if resp.status == 200
		return resp.body  # This is the raw image bytes
	else
		error("Failed to get objects: $(resp.status)")
	end
end

# Request an image by filename
function request_image(filename::String, url::String = url_base)
	url_full = "http://$url/images/"

	url = url_full * filename
	resp = HTTP.get(url)
	if resp.status == 200
		return resp.body  # This is the raw image bytes
	else
		error("Failed to get image: $(resp.status)")
	end
end


function read_json_lines(file_path)
	results = []
	for line in eachline(file_path)
		push!(results, JSON.Parser.parse(line))
	end
	return results
end
function save_filterd(url = url_base)
	file = "$PATH/__data_filtered__.json"
	response = RaspiConnection.request_filtered_objects(url)
	open(file, "w") do f
		write(f, response)
	end
end
function get_obj_data(url = url_base)
	file = "$PATH/__data__.json"
	response = request_objects(url)
	open(file, "w") do f
		write(f, response)
	end

	open(file, "r") do f
		return read_json_lines(f)
	end
end


function get_img_and_write(img, url = url_base)
	file_path = "$PATH/$img"
	open(file_path, "w") do f
		write(f, request_image(img, url))
	end
	return
end

function get_all_images(data, url = url_base)
	for item in data
		if haskey(item, "raw_path")
			img = item["raw_path"]
			if img ∈ readdir(PATH)
				# println("Image $img already exists, skipping download.")
			else
				println("Downloading image: $img")
				get_img_and_write(img, url)
			end
		end
	end
end


function rec_serialize(obj::Dict)
	if haskey(obj, "src")
		src = obj["src"]
		delete!(obj, "src")  # Remove src from the object
		if isfile(src)
			open(src, "r") do f
				subobj = JSON3.read(read(f, String))
				# println("Loaded sub-object from $src: ", subobj["action"])
				obj["action"] = subobj["action"]
				obj["commands"] = subobj["commands"]
				# Recursively serialize the loaded commands
				rec_serialize(subobj.commands)
			end
		else
			println("File $src not found")
		end
	end
end
function rec_serialize(obj::Vector)
	for item in obj
		rec_serialize(item)
	end
end
function rec_serialize(_)

end

function get_data(url = url_base)
	data = get_obj_data(url)
	if data isa Vector
		data = get_all_images(data, url)
	else

	end
end

function save_all(url = url_base)
	try
		mkpath(PATH)		
		save_filterd(url)
		get_data(url)
	catch
	end
end

end
