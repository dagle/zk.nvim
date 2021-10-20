local M = {}

-- as for now, don't configure lsp, this is just above all that
M.settings = {
	path = "~/zk"
}

-- Might merge tables in the future
function M.Setup(setting)
	m.settings = setting
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
	m.zkNew(bufnr, title)
end

function M.zkSnap(title)
	local result
	if title then
		result = vim.fn.execute("silent !zk new -W " .. m.settings.path .. " -p -t " .. title)
	else
		result = vim.fn.execute("silent !zk new -W " .. m.settings.path .. " -p")
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
		title = arg
	}
	-- vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function(err, result, ctx, cfg)
	vim.lsp.buf_request(bufnr, "workspace/executeCommand", mycmd, function (error)
		if error then
			print(error)
		end
	end)
end




-- TODO telescope functions etc

return M
