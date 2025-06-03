module AdminViews
using Stipple, StippleUI
using GenieFramework

using AeroSmurf.AdminComponents: connect_item

function ui_con()
	[
		connect_item("Raspi", :PiIp, :PiConnect, :Pi_status),
		separator(color = "primary"),
		connect_item("Mav", :MavIp, :MavConnect, :MavStatus),
	]
end

function ui_mission()
	[
		card(
			[cardsection([
					uploader(
						fieldname     = :fileuploads,
						multiple      = true,
						accept        = ".json",
						autoupload    = true,
						hideuploadbtn = true,
						label         = "Upload datasets",
						nothumbnails  = true,
						style         = "max-width:95%;margin:0 auto",
					)]), cardsection([span("{{mission_content}}")]),
				cardsection(
					[select(
						:mission_file, options = :data_name_list,
						label = "Mission File",
						clearable = true),
					btn(
						"Send Mission", @click(:SendMission),
						icon = "mail",
						var"icon-right" = "send",
						color = "orange", size = 4)]
				),
			],
			style = "max-width:95%;margin:0 auto",
		),
	]
end

function ui()
	return [
		p("{{drone_status}}"),
		ui_con(),
		separator(color = "primary"),
		ui_mission(),
	]
end
end

