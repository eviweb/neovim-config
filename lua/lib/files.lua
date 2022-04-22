-- lua/lib/files.lua

--- Get the parent directory of a given path
-- @param string path
function dirname(path)
	local dir = '.'

	if path:match('/.+/[^/]+$') then
		dir = path:gsub('/[^/]+$', '')
	elseif path:match('^/') then
		dir = '/'
	end

	return dir
end
