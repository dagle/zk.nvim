local M = {}

function M.setup(args)
	args = args or {}
	local defs = {
		path = "~/zk",
	}
	Zk_config = vim.tbl_extend("force", defs, args)
	_G.zk_config = Zk_config
end

function M.zkNew(bufnr, opts)
	local arg = vim.fn.expand(Zk_config.path)
	local mycmd = {
		command = "zk.new",
		arguments = {arg, opts},
	}
	vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function(error, result)
		if result and not error then
			vim.cmd(":e " .. result.path)
		else
			error(error)
		end
	end)
end

function M.zkAsk(bufnr)
	local title = vim.fn.input("Zk Title: ")
	M.zkNew(bufnr, {title = title})
end

function M.zkSnap(title)
	local result
	if title then
		result = vim.fn.execute("silent !zk new -W " .. Zk_config.path .. " -p -t " .. title)
	else
		result = vim.fn.execute("silent !zk new -W " .. Zk_config.path .. " -p")
	end
	local trimmed = string.gsub(result, ".*\r", "")
	vim.api.nvim_command('topleft new ' .. trimmed)
end

function M.zkIndex(bufnr)
	local arg = vim.fn.expand(Zk_config.path)
	local mycmd = {
		command = "zk.index",
		arguments = {arg},
	}
	vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function (error)
		if error then
			error(error)
		end
	end)
end

-- Just a handly wrapper
-- this should take opts
function M.search_raw()
	require ("telescope.builtin").live_grep({
		prompt_title = "Zk",
		cwd = Zk_config.path,
	})
end

return M
