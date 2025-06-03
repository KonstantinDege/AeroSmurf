module AdminComponents
using Stipple, StippleUI
using GenieFramework


function connect_item(name, text, connect, status)
	row([
		column(
			textfield(
				"$name IP",
				text,
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
		column(
			btn(
				"Connect $name", var"v-on:click" = "$connect = true",
				icon = "mail",
				var"icon-right" = "send",
				color = "blue", size = 4),
		),
		column(
			p("{{$status}}")
		)])
end


end
