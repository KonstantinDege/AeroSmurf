module AdminViews
using Stipple, Stipple
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
			[
				uploader(multiple = true,
					accept = ".json",
					autoupload = true,
					hideuploadbtn = true,
					label = "Upload datasets",
					nothumbnails = true
				)],
		),
		select(
			:mission_file, options = :data_name_list,
			label = "Mission File",
			clearable = true),
		btn(
			"Send Mission", @click(:SendMission),
			icon = "mail",
			var"icon-right" = "send",
			color = "orange", size = 4),
	]
end

function ui()
	[
		ui_con(),
		separator(color = "primary"),
		ui_mission(),
	]
end
end

