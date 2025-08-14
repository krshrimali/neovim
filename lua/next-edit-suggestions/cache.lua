local M = {}

-- Cache implementation using LRU (Least Recently Used) strategy
local cache = {}
local cache_order = {}
local cache_stats = {
  hits = 0,
  misses = 0,
  size = 0,
  max_size = 1000,
}

-- Setup cache
function M.setup(max_size)
  cache_stats.max_size = max_size or 1000
  cache = {}
  cache_order = {}
  cache_stats.hits = 0
  cache_stats.misses = 0
  cache_stats.size = 0
end

-- Generate cache key from context
function M.generate_key(context)
  local key_parts = {
    context.filename or "unknown",
    context.filetype or "text",
    table.concat(context.lines_before or {}, "\n"),
    context.current_line or "",
    tostring(context.col or 0),
    table.concat(context.lines_after or {}, "\n"),
  }
  
  -- Create a hash of the context for efficient storage
  local key = table.concat(key_parts, "|||")
  return vim.fn.sha256(key)
end

-- Get item from cache
function M.get(key)
  if cache[key] then
    cache_stats.hits = cache_stats.hits + 1
    
    -- Move to front (most recently used)
    M.move_to_front(key)
    
    return cache[key]
  else
    cache_stats.misses = cache_stats.misses + 1
    return nil
  end
end

-- Set item in cache
function M.set(key, value)
  if cache[key] then
    -- Update existing item
    cache[key] = value
    M.move_to_front(key)
  else
    -- Add new item
    if cache_stats.size >= cache_stats.max_size then
      M.evict_lru()
    end
    
    cache[key] = value
    table.insert(cache_order, 1, key)
    cache_stats.size = cache_stats.size + 1
  end
end

-- Move key to front of cache order (most recently used)
function M.move_to_front(key)
  for i, k in ipairs(cache_order) do
    if k == key then
      table.remove(cache_order, i)
      table.insert(cache_order, 1, key)
      break
    end
  end
end

-- Evict least recently used item
function M.evict_lru()
  if #cache_order > 0 then
    local lru_key = table.remove(cache_order)
    cache[lru_key] = nil
    cache_stats.size = cache_stats.size - 1
  end
end

-- Clear cache
function M.clear()
  cache = {}
  cache_order = {}
  cache_stats.size = 0
end

-- Get cache statistics
function M.get_stats()
  return {
    hits = cache_stats.hits,
    misses = cache_stats.misses,
    size = cache_stats.size,
    max_size = cache_stats.max_size,
    hit_rate = cache_stats.hits > 0 and (cache_stats.hits / (cache_stats.hits + cache_stats.misses)) or 0,
  }
end

-- Cleanup expired entries (if we add TTL in the future)
function M.cleanup()
  -- For now, just a placeholder for future TTL implementation
  -- Could add timestamp-based expiration here
end

-- Get cache size in bytes (approximate)
function M.get_memory_usage()
  local total_size = 0
  for key, value in pairs(cache) do
    -- Rough estimation of memory usage
    total_size = total_size + #key
    if type(value) == "table" then
      total_size = total_size + #vim.json.encode(value)
    else
      total_size = total_size + #tostring(value)
    end
  end
  return total_size
end

-- Resize cache
function M.resize(new_max_size)
  cache_stats.max_size = new_max_size
  
  -- Evict items if current size exceeds new max
  while cache_stats.size > new_max_size do
    M.evict_lru()
  end
end

-- Debug function to inspect cache contents
function M.debug_info()
  return {
    stats = M.get_stats(),
    memory_usage = M.get_memory_usage(),
    keys = vim.tbl_keys(cache),
    order = cache_order,
  }
end

return M