local conf = {
	["name"] = "Template - 01",
	["arrival"] = {
		["arrival_01"] = {
			["AC"] = "TOCHANGE",
			["AD"] = "TOCHANGE",
			["brake"] = 0.6,
			["switch"] = {
				"switch_A",
				"switch_B",
			},
			["default_railway"] = "platform_02",
			["railway"] = {
				"platform_01",
				"platform_02",
				"highway_03",
			},
		},
	},
	["platform"] = {
		["platform_01"] = {
			["AC"] = {
				["end"] = "TOCHANGE",
				["deadend"] = "TOCHANGE",
			},
			["AD"] = {
				["end"] = "TOCHANGE",
			},
			["available"] = true,
			-- ["depart_time"] = 360,
			["depart_time"] = 60,
			["throttle"] = 0.50,
		},
		["platform_02"] = {
			["AC"] = {
				["end"] = "TOCHANGE",
				["deadend"] = "TOCHANGE",
			},
			["AD"] = {
				["end"] = "TOCHANGE",
			},
			["available"] = true,
			-- ["depart_time"] = 360,
			["depart_time"] = 60,
			["throttle"] = 0.50,
		},
	},
	["highway"] = {
		["highway_03"] = {
			["AC"] = "TOCHANGE",
			["AD"] = "TOCHANGE",
			["available"] = true,
		},
	},
	["switch"] = {
		["switch_A"] = {
			["railway"] = {
				["platform_01"] = 1,
				["platform_02"] = 0,
				["highway_03"] = 0,
			},
			["periph"] = "TOCHANGE",
			["side"] = 1,
		},
		["switch_B"] = {
			["railway"] = {
				["platform_01"] = 0,
				["platform_02"] = 0,
				["highway_03"] = 1,
			},
			["periph"] = "TOCHANGE",
			["side"] = 1,
		},
	},
}

return conf
