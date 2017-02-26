return {
	dirt = {
		texture = "dirt",
	},
	goal = {
		texture = "goal",
		oncontact = function( self, x, y )
			map.advanceLevel()
		end,
	},
	grass = {
		texture = "grass",
	},
	cutoffleft = {
		texture = "cutoffleft",
	},
	cutoffright = {
		texture = "cutoffright",
	},
	cutofftop = {
		texture = "cutofftop",
	},
	cutoffbottom = {
		texture = "cutoffbottom",
	},
	grasscornerleft = {
		texture = "gcl",
	},
	grasscornerright = {
		texture = "gcr",
	},
	grasscornerinnerleft = {
		texture = "gcil",
	},
	grasscornerinnerright = {
		texture = "gcir",
	}
}