module ObjectController


# Build something great
using GenieFramework
const FILE_PATH = joinpath("public", "data", "dump")
mkpath(FILE_PATH)
using Stipple
using StippleUI
using AeroSmurf.CreateTable: create_rec_table

function create_pt()
	df = create_rec_table("public/data/dump/__data_filtered__.json")
	PivotTable(df, PivotTableOptions())
end

pt = create_pt()

@app begin
	@in Button_process = false


	@onbutton Button_process begin
		DataTable(create_rec_table("public/data/dump/__data_filtered__.json"))
	end
	@out Table_data = DataTable(create_rec_table("public/data/dump/__data_filtered__.json"))
end



function ui()
	[
		btn("Reload", @click(:Button_process)),
		table(:Table_data, flat = true, bordered = true, title = "Treats")]
end


function main()
	model = @init
	page(model, ui()) |> html
end



end
