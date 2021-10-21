local sqlite = require('sqlite')

local M = {}

-- as for now, don't configure lsp, this is just above all that
M.settings = {
	path = "~/zk"
}

-- Might merge tables in the future
function M.Setup(setting)
	M.settings = setting
end

function M.zkNew(bufnr, title)
	local arg = vim.fn.expand("%:p")
	local mycmd = {
		command = "zk.new",
		arguments = {arg},
		title = title,
	}
	vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function(error, result)
		if result and not error then
			vim.cmd(":e " .. result.path)
		else
			print(error)
		end
	end)
end

function M.zkAsk(bufnr)
	local title = vim.fn.input("Zk Title: ")
	M.zkNew(bufnr, title)
end

function M.zkSnap(title)
	local result
	if title then
		result = vim.fn.execute("silent !zk new -W " .. M.settings.path .. " -p -t " .. title)
	else
		result = vim.fn.execute("silent !zk new -W " .. M.settings.path .. " -p")
	end
	local trimmed = string.gsub(result, ".*\r", "")
	vim.api.nvim_command('topleft new ' .. trimmed)
	-- local buf = vim.api.nvim_get_current_buf()
	-- local win = vim.api.nvim_get_current_win()
end


function M.zkIndex(bufnr)
	local arg = vim.fn.expand("%:p")
	local mycmd = {
		command = "zk.index",
		arguments = {arg},
		-- title = arg
	}
	-- vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function(err, result, ctx, cfg)
	vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function (error)
		if error then
			print(error)
		end
	end)
end

-- raw search!
function M.search_raw()
	require ("telescope.builtin").live_grep({
		prompt_title = "Zk",
		cwd = M.settings.path,
	})
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local putils = require "telescope.previewers.utils"
local previewers = require "telescope.previewers"
-- this might reduce the copy paste
-- local action_set = require "telescope.actions.set"

function M.search_title(opts)
	-- maybe move this to oneshot_job
	local path = M.settings.path .. "/.zk/notebook.db"
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
		-- feels a bit copy-pasty atm
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":e " .. fpath)
			end)
			actions.select_horizontal:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":split " .. fpath)
			end)
			actions.select_vertical:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":vs " .. fpath)
			end)
			actions.select_tab:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":tabe " .. fpath)
			end)
			return true
		end,
	  }):find()
end

-- search all collections?
function M.search_tag(opts)
	local path = M.settings.path .. "/.zk/notebook.db"
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
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				-- local current_picker = action_state.get_current_picker(prompt_bufnr)
				M.search_by_tag(selection.value.id, opts)
			end)
			return true
		end,
	}):find()
end

function M.search_by_tag(tid, opts)
	local path = M.settings.path .. "/.zk/notebook.db"
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
		-- feels a bit copy-pasty atm
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":e " .. fpath)
			end)
			actions.select_horizontal:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":split " .. fpath)
			end)
			actions.select_vertical:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":vs " .. fpath)
			end)
			actions.select_tab:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				local fpath = M.settings.path .. "/" .. selection.value.path
				vim.cmd(":tabe " .. fpath)
			end)
			return true
		end,
	  }):find()
end


M.search_tag()

return M
