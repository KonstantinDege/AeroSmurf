module MissionProposser
# Build something great
using GenieFramework
using DataFrames: DataFrames

using AeroSmurf: AeroSmurf, FILE_PATH

@app begin
	@onchange fileuploads begin
		@info "fileuploads changed: $(fileuploads)"
		if !isempty(fileuploads)
			name = fileuploads["name"]
			tmp  = fileuploads["path"]
			try
				# ensure the directory exists
				isdir(FILE_PATH) || mkpath(FILE_PATH)
				# move (overwrite) into place
				mv(tmp, joinpath(FILE_PATH, name); force = true)
			catch err
				@error "Error saving upload to disk: $err"
				notify(model, "Error saving file $name")
			end
			fileuploads = Dict{String, String}()
		end
	end
end




function ui_header()
	quasar(
		:header,
		toolbar(
			[
				toolbartitle("Propose Mission Files"),
			], class = "bg-primary text-white",
		),
	)
end

function ui_main()
	row(
		[
			card([
				uploader(multiple = true,
					accept = ".json",
					autoupload = true,
					hideuploadbtn = true,
					label = "Upload datasets",
					nothumbnails = true,
				)]
			),
		],
		class = "", style = "color: black",
	)
end



function ui()
	StippleUI.layout(view = "hHh Lpr lff",
		[
			ui_header(),
			page_container(
				ui_main())])
end


function main()
	model = @init
	page(model, ui()) |> html
end

end
