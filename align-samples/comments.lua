-- Try: select all lines, `ga` then `--`

local M = {}

M.host = "localhost" -- server hostname
M.port = 8080 -- listening port
M.timeout = 30 -- seconds before timeout
M.retries = 3 -- max retry attempts
M.debug = false -- enable debug logging
M.workers = 4 -- number of worker threads

return M
