local sqlite = require('sqlite')
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local putils = require "telescope.previewers.utils"
local previewers = require "telescope.previewers"
local action_set = require "telescope.actions.set"

local function open_title(bufnr, type)
	actions.close(bufnr)
	local selection = action_state.get_selected_entry()
	local fpath = _G.zk_config.path .. "/" .. selection.value.path

	if type == "default" then
		vim.cmd(":e " .. fpath)
	elseif type == "horizontal" then
		vim.cmd(":split " .. fpath)
	elseif type == "vertical" then
		vim.cmd(":vs " .. fpath)
	elseif type == "tabedit" then
		vim.cmd(":tabe " .. fpath)
	end
end

local function search_title(opts)
	local path = _G.zk_config.path .. "/.zk/notebook.db"
	local titles = sqlite.with_open(path, function(db)
		return db:select("notes", {select = {"title", "path", "raw_content"}})
	end)

	pickers.new(opts, {
		prompt_title = "Zk titles",
		finder = finders.new_table {
			results = titles,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.title,
					ordinal = entry.title,
				}
			end
		},
		sorter = conf.generic_sorter(opts),
		previewer = previewers.new_buffer_previewer {
			title = "Zk preview",
			keep_last_buf = true,
			define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.raw_content, "\n"))
					putils.highlighter(self.state.bufnr, "markdown")
			end,
		},
		attach_mappings = function()
			action_set.select:replace(open_title)
			return true
		end,
	  }):find()
end

local function search_by_tag(tid, opts)
	local path = _G.zk_config.path .. "/.zk/notebook.db"
	local titles = sqlite.with_open(path, function(db)
		return db:eval("SELECT title, raw_content from notes_collections inner join notes ON notes.id = notes_collections.note_id WHERE collection_id = " .. tid)
	end)

	pickers.new(opts, {
		prompt_title = "Zk titles",
		finder = finders.new_table {
			results = titles,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.title,
					ordinal = entry.title,
				}
			end
		},
		sorter = conf.generic_sorter(opts),
		previewer = previewers.new_buffer_previewer {
			title = "Zk preview",
			keep_last_buf = true,
			define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry.value.raw_content, "\n"))
					putils.highlighter(self.state.bufnr, "markdown")
			end,
		},
		attach_mappings = function()
			action_set.select:replace(open_title)
			return true
		end,
	  }):find()
end

local function search_tag(opts)
	local path = _G.zk_config.path .. "/.zk/notebook.db"
	local tags = sqlite.with_open(path, function(db)
		return db:select("collections", {select = {"id","name"}})
	end)

	pickers.new(opts, {
		prompt_title = "Zk tags",
		finder = finders.new_table {
			results = tags,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.name,
					ordinal = entry.name,
				}
			end
		},
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				search_by_tag(selection.value.id, opts)
			end)
			return true
		end,
	}):find()
end


return require("telescope").register_extension({
	exports = {
		zk_tag = search_tag,
		zk_title = search_title,
	}
})
