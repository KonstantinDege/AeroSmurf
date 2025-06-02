module UlogsController
# Build something great
using GenieFramework
import DataFrames

using AeroSmurf.ULogAnalyser

const FILE_PATH = joinpath("public", "ulogs")
mkpath(FILE_PATH)


@app begin
	@in tab_selected = "main"


	@private data = []


	@in current_data = []
	@out data_name_list = []
	@in data_combiner = []
	@in new_name = ""

	@in Remove_data = true
	@in Group_data = true
	@in Rename_data = true

	@onbutton Remove_data begin

	end
	@onbutton Group_data begin

	end
	@onbutton Rename_data begin

	end

    @out upfiles = readdir(FILE_PATH)

	@out data_temp = DataTable(
		DataFrames.DataFrame()
		)

	@private data_raw = DataFrames.DataFrame()


    @onchange fileuploads begin
        @show fileuploads
        if ! isempty(fileuploads)
            @info "File was uploaded: " fileuploads["name"]
			push!(data_name_list, fileuploads["name"])
			@push data_name_list
			
			
			d = DataFrames.DataFrame(ULogAnalyser.ulog_analysis(fileuploads["path"]))
			d.name = [fileuploads["name"]]

			data_raw = vcat(data_raw, d, cols=:union)
			data_temp = DataTable(data_raw)

			fileuploads = Dict{AbstractString,AbstractString}()
        end
        upfiles = readdir(FILE_PATH)
    end

end




function ui_header()
	quasar(
		:header,
		toolbar(
			[
				toolbartitle("DroneAnalysisSoftware"),
				tabgroup(
					:tab_selected,
					inlinelabel = true,
					[
						tab(name = "main", icon = "photos", label = "Main"),
						tab(name = "3d", icon = "slow_motion_video", label = "3D Viewer"),
						tab(name = "pivottable", icon = "movie", label = "PivotTable"),
					],
					class = "absolute-center",
				),
				select(:current_data, options = :data_name_list, class = "main-select"),
			], class = "bg-primary text-white",
		),
	)
end

function ui_main()
	row(
		[
			card(
				[
					card([
						uploader(multiple = true,
								 accept = ".ulg",
								 autoupload = true,
								 hideuploadbtn = true,
								 label = "Upload datasets",
								 nothumbnails = true
								)

					   ], class = "q-ma-md",
					),
					card(
						[
							select(
								:data_combiner, options = :data_name_list, label = "Social Networks",
								multiple = true, clearable = true)
							card(
								[
								row([
									textfield(
										"New Name",
										:new_name,
										bottomslots = "",
										counter = "",
										maxlength = "12",
										dense = "",
										[
											template(
												var"v-slot:append" = "",
												[
													icon(
														"close",
														@iif("Text_text !== ''"),
														@click("Text_text = ''"),
														class = "cursor-pointer",
													),
												],
											),
										], class = "q-mu-sm",
									),
									btn("Remove", color = "primary", class = "q-ma-sm", @click(:Remove_data)),
									btn("Group", color = "secondary", class = "q-ma-sm", @click(:Group_data)),
									btn("Rename", color = "secondary", class = "q-ma-sm", @click(:Rename_data))])]
							)
						], class = "q-ma-md",
					),
				], class = "main_col",
			)
			card(
				StippleUI.scrollarea(
					style = "height: 80vh; width: 55vw;",
					[
						table(:data_temp, flat = true, bordered = true, title = "Treats")
						],
				),
			)
		],
		class = "", style = "color: black",
	)
end



function ui()
	StippleUI.layout(view = "hHh Lpr lff",
		[
			ui_header(),
			page_container(
				tabpanels(
					:tab_selected,
					animated = true,
					var"transition-prev" = "scale",
					var"transition-next" = "scale",
					[
						tabpanel(name = "main", ui_main()),
						tabpanel(name = "3d", [p("Videos content")]),
						tabpanel(name = "pivottable", [p("Movies content")]),
					],
				))])
end


function main()
	model = @init
	page(model, ui()) |> html
end

end
