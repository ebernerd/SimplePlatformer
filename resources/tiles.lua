return {
	dirt = {
		texture = "dirt",
	},
	goal = {
		texture = "goal",
		oncontact = function( self, x, y )
			map.advanceLevel()
		end,
	}
}