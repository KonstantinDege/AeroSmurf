module RaspiConnection


using HTTP
using JSON

url_base = "ltraspi02.local:4269"
PATH = "public/dump/data"

# Upload a mission file
function upload_mission(file_path::String, url::String = "http://$url_base/mission")
	if !isfile(file_path)
		error("File $file_path does not exist.")
	end
	j = JSON.parsefile(file_path)
	rec_serialize(j["commands"])
	new = tempname()
	open(new, "w") do f
		JSON.print(f, j)
		print(j)
	end
	open(new) do json
		headers = []
		body = HTTP.Form([
			"file" => json,
		])
		HTTP.post(url, headers, body)
	end
end

# Request found objects (JSON)
function request_objects(url::String = "http://$url_base/found_objects")
	resp = HTTP.get(url)
	if resp.status == 200
		return resp.body  # This is the raw image bytes
	else
		error("Failed to get objects: $(resp.status)")
	end
end

function request_filtered_objects(url::String = "http://$url_base/found_objects_filtered")
	resp = HTTP.get(url)
	if resp.status == 200
		return resp.body  # This is the raw image bytes
	else
		error("Failed to get objects: $(resp.status)")
	end
end

# Request an image by filename
function request_image(filename::String, url_base::String = "http://$url_base/images/")
	url = url_base * filename
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
function save_filterd()
	file = "$PATH/__data_filtered__.json"
	response = RaspiConnection.request_filtered_objects()
	open(file, "w") do f
		write(f, response)
	end
end
function get_obj_data()
	file = "$PATH/__data__.json"
	response = request_objects()
	open(file, "w") do f
		write(f, response)
	end

	open(file, "r") do f
		return read_json_lines(f)
	end
end


function get_img_and_write(img)
	file_path = "$PATH/$img"
	open(file_path, "w") do f
		write(f, request_image(img))
	end
	return
end

function get_all_images(data)
	for item in data
		if haskey(item, "raw_path")
			img = item["raw_path"]
			if img ∈ readdir(PATH)
				println("Image $img already exists, skipping download.")
			else
				println("Downloading image: $img")
			end
			get_img_and_write(img)
		end
	end
end


function rec_serialize(obj::Dict)
	println("Dict serialization")
	if haskey(obj, "src")
		print("test")
		src = obj["src"]
		delete!(obj, "src")  # Remove src from the object
		if isfile(src)
			open(src, "r") do f
				subobj = JSON3.read(read(f, String))
				println("Loaded sub-object from $src: ", subobj["action"])
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
	println("Vector serialization")
	for item in obj
		rec_serialize(item)
	end
end
function rec_serialize(_)

end

end
