
-- Interval structure
Interval = {
	new = function(b, e)
		return {begin_t = b, end_t = e}
	end
}

-- ListNode structure
ListNode = {
	new = function(v)
		return {val = v, next = nil}
	end
}

-- TreeNode structure
TreeNode = {
	new = function(v)
		return {val = v, left = nil, right = nil}
	end
}

------------------------------------------------------------------------
-- from http://stackoverflow.com/a/1093991/2954435

clone = function(object, ...) 
    local ret = {}

    -- clone base class
    if type(object)=="table" then 
            for k,v in pairs(object) do 
                    if type(v) == "table" then
                            v = clone(v)
                    end
                    -- don't clone functions, just inherit them
                    if type(v) ~= "function" then
                            -- mix in other objects.
                            ret[k] = v
                    end
            end
    end
    -- set metatable to object
    setmetatable(ret, { __index = object })

    -- mix in tables
    for _,class in ipairs(arg) do
            for k,v in pairs(class) do 
                    if type(v) == "table" then
                            v = clone(v)
                    end
                    -- mix in v.
                    ret[k] = v
            end
    end
    return ret
end

------------------------------------------------------------------------

function array_to_string(arr)
	return "[" .. table.concat(arr, ", ") .. "]"
end

function matrix_to_string(arr)
	local ret = "["
	for k, v in pairs(arr) do
		if k ~= 1 then
			ret = ret .. ", "
		end
	    ret = ret .. array_to_string(v)
	end
	return ret .. "]"
end

function to_string(n)
	if type(n) == "boolean" then
		if n == true then return "true"
		else return "false"
		end
	elseif type(n) == "table" then
		-- For intervals
		if n.begin_t ~= nil and n.end_t ~= nil then
			return "[" .. n.begin_t .. ", " .. n.end_t .. "]"
		end

		local ret = "["
		for k, v in pairs(n) do
			if k ~= 1 then ret = ret .. ", " end
		    ret = ret .. to_string(v)
		end
		return ret .. "]"
	elseif type(n) == "number" then
		return "" .. n
	elseif type(n) == "string" then
		return "\"" .. n .. "\""
	else
		print("Unsupported type: " .. type(n))
	end
end

------------------------------------------------------------------------
-- from http://stackoverflow.com/a/25976660/2954435
function equals(table1, table2)
   local avoid_loops = {}
   local function recurse(t1, t2)
      -- compare value types
      if type(t1) ~= type(t2) then return false end
      -- Base case: compare simple values
      if type(t1) ~= "table" then return t1 == t2 end
      -- Now, on to tables.
      -- First, let's avoid looping forever.
      if avoid_loops[t1] then return avoid_loops[t1] == t2 end
      avoid_loops[t1] = t2
      -- Copy keys from t2
      local t2keys = {}
      local t2tablekeys = {}
      for k, _ in pairs(t2) do
         if type(k) == "table" then table.insert(t2tablekeys, k) end
         t2keys[k] = true
      end
      -- Let's iterate keys from t1
      for k1, v1 in pairs(t1) do
         local v2 = t2[k1]
         if type(k1) == "table" then
            -- if key is a table, we need to find an equivalent one.
            local ok = false
            for i, tk in ipairs(t2tablekeys) do
               if equals(k1, tk) and recurse(v1, t2[tk]) then
                  table.remove(t2tablekeys, i)
                  t2keys[tk] = nil
                  ok = true
                  break
               end
            end
            if not ok then return false end
         else
            -- t1 has a key which t2 doesn't have, fail.
            if v2 == nil then return false end
            t2keys[k1] = nil
            if not recurse(v1, v2) then return false end
         end
      end
      -- if t2 has a key which t1 doesn't have, fail.
      if next(t2keys) then return false end
      return true
   end
   return recurse(table1, table2)
end

------------------------------------------------------------------------

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

------------------------------------------------------------------------

function test_anagram(a0, a1)
    if #a0 ~= #a1 then return False end
    local t0, t1 = copy(a0), copy(a1)
    table.sort(t0)
    table.sort(t1)
    return equals(t0, t1)
end

------------------------------------------------------------------------

function read_interval_array(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		local b = tonumber(f:read())
		local e = tonumber(f:read())
		ret[i] = Interval.new(b, e)
	end
	return ret
end

function read_interval_matrix(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_interval_array(f)
	end
	return ret
end

function read_interval_matrix_arr(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_interval_matrix(f)
	end
	return ret
end

function read_num_array(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = tonumber(f:read())
	end
	return ret
end

function read_num_matrix(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_num_array(f)
	end
	return ret
end

function read_num_matrix_arr(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_num_matrix(f)
	end
	return ret
end

function read_bool_array(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		t = tonumber(f:read())
		if t == 0 then
			ret[i] = false
		else
			ret[i] = true
		end		
	end
	return ret
end

function read_bool_matrix(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_bool_array(f)
	end
	return ret
end

function read_bool_matrix_arr(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_bool_matrix(f)
	end
	return ret
end

function read_string_array(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = f:read()
	end
	return ret
end

function read_string_matrix(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_string_array(f)
	end
	return ret
end

function read_string_matrix_arr(f)
	local num = tonumber(f:read())
	local ret = {}
	for i = 1, num do
		ret[i] = read_string_matrix(f)
	end
	return ret
end
