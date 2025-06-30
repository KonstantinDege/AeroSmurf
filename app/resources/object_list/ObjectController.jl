module ObjectController


# Build something great
using GenieFramework
const FILE_PATH = joinpath("public", "data", "dump")
const FILE = joinpath(FILE_PATH, "__data_filtered__.json")
mkpath(FILE_PATH)
using Stipple
using StippleUI
using AeroSmurf.CreateTable: create_rec_table


function create_pt()
	df = create_rec_table(FILE)
	PivotTable(df, PivotTableOptions())
end

pt = create_pt()

@app begin
	@in Button_process = false


	@onbutton Button_process begin
		DataTable(create_rec_table(FILE))
	end
	@out Table_data = DataTable(create_rec_table(FILE))
	@in TablePagination_tpagination = DataTablePagination(rows_per_page = 50)
end



function ui()
	[
		btn("Reload", @click(:Button_process)),
		table(:Table_data, flat = true, bordered = true, pagination = :TablePagination_tpagination, title = "Objects")]
end


function main()
	model = @init
	page(model, ui()) |> html
end



end
