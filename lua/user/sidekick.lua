return {
	-- add any options here
	cli = {
		win = {
			layout = "float",
		},
		mux = {
			backend = "zellij",
			enabled = false,
		},
		prompts = {
			["function"] = "{function}",
			buffers = "{buffers}",
			changes = "Can you review my changes?",
			class = "{class}",
			diagnostics = "Can you help me fix the diagnostics in {file}?\n{diagnostics}",
			diagnostics_all = "Can you help me fix these diagnostics?\n{diagnostics_all}",
			document = "Add documentation to {function|line}",
			explain = "Explain {this}",
			file = "{file}",
			fix = "Can you fix {this}?",
			line = "{line}",
			optimize = "How can {this} be optimized?",
			position = "{position}",
			quickfix = "{quickfix}",
			review = "Can you review {file} for any issues or improvements?",
			selection = "{selection}",
			tests = "Can you write tests for {this}?",
			this = "{this}",
		},
	},
}
