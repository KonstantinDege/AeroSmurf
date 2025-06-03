module ImageController


# Build something great
using GenieFramework
const FILE_PATH = joinpath("public", "dump", "data")
mkpath(FILE_PATH)
using Stipple

@app begin
	@in data_combiner = []

	@out upfiles = [i for i ∈ readdir(FILE_PATH) if endswith(i, ".jpg") || endswith(i, ".png")]

	@in Button_process = false
	@in Button_count = 0
	@out image_path = ""

	@onbutton Button_process begin
		upfiles = [i for i ∈ readdir(FILE_PATH) if endswith(i, ".jpg") || endswith(i, ".png")]
	end
	@onchange data_combiner begin
        @info data_combiner
		if !isempty(data_combiner)
			image_path = relpath(joinpath(FILE_PATH, data_combiner[1]), "public")
		else
            image_path = ""
		end
	end
end



function ui()
	[
		btn("Reload", @click(:Button_process)),
		card([select(
			:data_combiner, options = :upfiles, label = "Social Networks",
			clearable = true, style = "padding: 10px;"),]),
		imageview(
			src = :image_path,
			style = "width: 90vw")]
end


function main()
	model = @init
	page(model, ui()) |> html
end






end
