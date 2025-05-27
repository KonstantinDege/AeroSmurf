module AdminViews
using Stipple, StippleUI
using GenieFramework



function ui_con()
	[
		row([
			column(
				textfield(
					"Raspi IP",
					:PiIp,
					bottomslots = "",
					counter = "",
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
				), size = 6),
			column(btn(
				"Connect Pi", @click(:PiConnect),
				icon = "mail",
				var"icon-right" = "send",
				color = "blue", size = 4))]),
		separator(color = "primary"),
		row([
			column(
				textfield(
					"Mavlink IP",
					:MavIp,
					bottomslots = "",
					counter = "",
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
				), size = 6),
			column(btn(
				"Connect Pi", @click(:MavConnect),
				icon = "mail",
				var"icon-right" = "send",
				color = "orange", size = 4))])]
end

function ui_mission()
	[
		card([
				uploader(multiple = true,
					accept = ".json",
					autoupload = true,
					hideuploadbtn = true,
					label = "Upload datasets",
					nothumbnails = true,
				)], class = "q-ma-md",
		),
		select(
			:mission_file, options = :data_name_list,
			label = "Mission File",
			clearable = true),
		btn(
			"Connect Pi", @click(:MavConnect),
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

