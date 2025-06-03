module OverviewController
using Stipple
using Stipple.ReactiveTools
using StippleUI
import Genie.Server.openbrowser

using StippleMakie

Stipple.enable_model_storage(false)

using AeroSmurf.OverviewMap: render

@app MakieDemo begin
	@out fig1 = MakieFigure()


	@onchange isready begin
		init_makiefigures(__model__)
		# the viewport changes when the figure is ready to be written to
		onready(fig1) do
			render(fig1.fig)
		end
	end
end


UI::ParsedHTMLString = column(
	style = "height: 80vh; width: 98vw",
	[
		h4("MakiePlot 1")
		cell(class = "full-width full-height", makie_figure(:fig1))
	],
)

ui() = UI

function init()
	WGLMakie.Page()
	global model = @init MakieDemo
	html!(ui, layout = Stipple.ReactiveTools.DEFAULT_LAYOUT(head_content = [makie_dom(model)]), model = model, context = @__MODULE__)
end

end
