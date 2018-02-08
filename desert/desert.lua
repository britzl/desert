local json = require "desert.json"
local base64 = require "desert.base64"

local M = {}

local V3_ZERO = vmath.vector3(0)
local V3_ONE = vmath.vector3(1)
local V4_ZERO = vmath.vector4(0)
local V4_ONE = vmath.vector4(1)
local QUAT_ZERO = vmath.quat()

local function m4_to_t(m4)
	return {
		m00 = m4.m00, m01 = m4.m01, m02 = m4.m02, m03 = m4.m03,
		m10 = m4.m10, m11 = m4.m11, m12 = m4.m12, m13 = m4.m13,
		m20 = m4.m20, m21 = m4.m21, m22 = m4.m22, m23 = m4.m23,
		m30 = m4.m30, m31 = m4.m31, m32 = m4.m32, m33 = m4.m33,
	}
end
local function t_to_m4(t)
	local m4 = vmath.matrix4()
	for k,v in pairs(t) do
		m4[k] = v
	end
	return m4
end
local function v_to_t(v)
	local t = {}
	while true do
		local ok, num = pcall(function() return v[#t + 1] end)
		if not ok then
			break
		end
		t[#t + 1] = num
	end
	return t
end
local function t_to_v(t) return vmath.vector(t) end
local function v3_to_t(v3) return { x = v3.x, y = v3.y, z = v3.z } end
local function t_to_v3(t) return vmath.vector3(t.x, t.y, t.z) end
local function v4_to_t(v4) return { x = v4.x, y = v4.y, z = v4.z, w = v4.w } end
local function t_to_v4(t) return vmath.vector4(t.x, t.y, t.z, t.w) end
local function quat_to_t(q) return { x = q.x, y = q.y, z = q.z, w = q.w } end
local function t_to_quat(t) return vmath.quat(t.x, t.y, t.z, t.w) end

local function is_nil(v)
	return type(v) == "nil"
end
local function is_number(v)
	return type(v) == "number"
end
local function is_string(v)
	return type(v) == "string"
end
local function is_boolean(v)
	return type(v) == "boolean"
end
local function is_table(v)
	return type(v) == "table"
end
local function is_userdata(v)
	return type(v) == "userdata"
end
local function is_model(v)
	return type(v) == "table" and v.encode and v.decode and v.create
end



function M.primitive(default)
	return {
		encode = function(v)
			assert(type(v) or is_table(v) or is_number(v) or is_string(v) or is_boolean(v))
			return v
		end,
		decode = function(v)
			assert(is_nil(v) or is_table(v) or is_number(v) or is_string(v) or is_boolean(v))
			return v
		end,
		create = function()
			return default
		end
	}
end


function M.number(default)
	assert(not default or is_number(default), "Expected no default value or a number")
	return {
		encode = function(v)
			assert(is_number(v))
			return v
		end,
		decode = function(v)
			assert(is_number(v))
			return v
		end,
		create = function()
			return default or 0
		end,
	}
end


function M.integer(default)
	assert(not default or is_number(default), "Expected no default value or a number")
	return {
		encode = function(v)
			assert(is_number(v))
			return math.floor(v)
		end,
		decode = function(v)
			assert(is_number(v))
			return v
		end,
		create = function()
			return default or 0
		end
	}
end


function M.string(default)
	assert(not default or is_string(default), "Expected no default value or a string")
	return {
		encode = function(v)
			assert(is_string(v))
			return v
		end,
		decode = function(v)
			assert(is_string(v))
			return v
		end,
		create = function()
			return default or ""
		end
	}
end


function M.boolean(default)
	assert(not default or is_boolean(default), "Expected no default value or a boolean")
	if default == nil then default = false end
	return {
		encode = function(v)
			assert(is_boolean(v))
			return v and 1 or 0
		end,
		decode = function(v)
			assert(is_number(v))
			return v == 1
		end,
		create = function()
			return default
		end
	}
end


function M.table(default)
	return {
		encode = function(v)
			assert(is_table(v))
			return v
		end,
		decode = function(v)
			assert(is_table(v))
			return v
		end,
		create = function()
			return default or {}
		end
	}
end


function M.ignore()
	return {
		encode = function(v) return nil end,
		decode = function(v) return nil end,
		create = function() return nil end,
	}
end


function M.vector3(default)
	assert(not default or is_userdata(default), "Expected no default value or userdata")
	return {
		encode = function(v3)
			if not v3 then
				return nil
			else
				assert(type(v3) == "userdata", "Expected userdata")
				assert(v3.x and v3.y and v3.z, "Expected a vector 3")
				return v3_to_t(v3)
			end
		end,
		decode = function(t)
			if not t then
				return nil
			else
				assert(type(t) == "table", "Expected a table")
				assert(t.x and t.y and t.z, "Expected table to have x, y and z components")
				return t_to_v3(t)
			end
		end,
		create = function()
			return default or vmath.vector3()
		end,
	}
end


function M.vector4(default)
	assert(not default or is_userdata(default), "Expected no default value or userdata")
	return {
		encode = function(v4)
			if not v4 then
				return nil
			else
				assert(type(v4) == "userdata", "Expected userdata")
				assert(v4.x and v4.y and v4.z and v4.w, "Expected userdata to have x, y, z and w components")
				return v4_to_t(v4)
			end
		end,
		decode = function(t)
			if not t then
				return nil
			else
				assert(type(t) == "table", "Expected a table")
				assert(t.x and t.y and t.z and t.w)
				return t_to_v4(t)
			end
		end,
		create = function()
			return default or vmath.vector4()
		end
	}
end


function M.vector(default)
	assert(not default or is_userdata(default), "Expected no default value or userdata")
	return {
		encode = function(v)
			if not v then
				return nil
			else
				assert(type(v) == "userdata", "Expected userdata")
				return v_to_t(v)
			end
		end,
		decode = function(t)
			if not t then
				return nil
			else
				assert(type(t) == "table", "Expected a table")
				return t_to_v(t)
			end
		end,
		create = function()
			return default or vmath.vector({})
		end,
	}
end


function M.quat(default)
	assert(not default or is_userdata(default), "Expected no default value or userdata")
	return {
		encode = function(q)
			if not q then
				return nil
			else
				assert(type(q) == "userdata", "Expected userdata")
				assert(q.x and q.y and q.z and q.w, "Expected userdata to have x, y, z and w components")
				return quat_to_t(q)
			end
		end,
		decode = function(t)
			if not t then
				return nil
			else
				assert(type(t) == "table", "Expected a table")
				assert(t.x and t.y and t.z and t.w, "Expected table to have x, y, z and w components")
				return t_to_quat(t)
			end
		end,
		create = function()
			return default or vmath.quat()
		end
	}
end


function M.matrix4(default)
	assert(not default or is_userdata(default), "Expected no default value or userdata")
	return {
		encode = function(m4)
			if not m4 then
				return nil
			else
				assert(type(m4) == "userdata", "Expected userdata")
				return m4_to_t(m4)
			end
		end,
		decode = function(t)
			if not t then
				return nil
			else
				assert(type(t) == "table", "Expected a table")
				return t_to_m4(t)
			end
		end,
		create = function()
			return default or vmath.matrix4()
		end
	}
end


function M.func(fn)
	assert(fn and type(fn) == "function", "You must provide a function")
	return {
		encode = function(v) return "" end,
		decode = function(v) return fn end,
		create = function() return fn end,
	}
end


function M.gameobject(factory_url, properties)
	assert(factory_url, "You must provide a factory url")
	assert(properties, "You must provide a list of properties")
	return {
		encode = function(id)
			assert(id and type(id) == "userdata", "Expected userdata")
			local pos = go.get_position(id)
			local rot = go.get_rotation(id)
			local scale = go.get_scale(id)
			local props = {}
			for script,script_props in pairs(properties) do
				props[script] = {}
				for key,fn in pairs(script_props) do
					local url = msg.url(nil, id, script)
					local value = go.get(url, key)
					props[script][key] = fn.encode(value)
				end
			end
			return {
				p = (pos ~= V3_ZERO) and v3_to_t(pos) or nil,
				r = (rot ~= QUAT_ZERO) and quat_to_t(rot) or nil,
				s = (scale ~= V3_ONE) and v3_to_t(scale) or nil,
				pr = props,
			}
		end,
		decode = function(t)
			assert(t and type(t) == "table", "Expected a table")
			local pos = t.p and t_to_v3(t.p) or V3_ZERO
			local rot = t.r and t_to_quat(t.r) or QUAT_ZERO
			local scale = t.s and t_to_v3(t.s) or V3_ONE
			local props = {}
			for script,script_props in pairs(properties) do
				for key,fn in pairs(script_props) do
					props[key] = fn.decode(t.pr[script][key])
				end
			end
			return factory.create(factory_url, pos, rot, props, scale)
		end,
		create = function()
			return factory.create(factory_url)
		end
	}
end


function M.tableof(model)
	assert(model and is_model(model), "Expected an object model")
	return {
		encode = function(t)
			local res = {}
			for k,v in pairs(t) do
				res[k] = model.encode(v)
			end
			return res
		end,
		decode = function(t)
			local res = {}
			for k,v in pairs(t) do
				res[k] = model.decode(v)
			end
			return res
		end,
		create = function()
			return {}
		end
	}
end


function M.object(model)
	assert(model and is_table(model), "Expected an object model to encode/decode")
	return {
		encode = function(data)
			assert(data and type(data) == "table", "You must provide data to encode")
			local result = {}
			for k,v in pairs(data) do
				if model[k] then
					result[k] = model[k].encode(v)
				else
					result[k] = v
				end
			end
			return result
		end,
		decode = function(data)
			assert(data and type(data) == "table", "You must provide data to decode")
			local result = {}
			for k,v in pairs(data) do
				if model[k] then
					result[k] = model[k].decode(v)
				else
					result[k] = v
				end
			end
			return result
		end,
		create = function()
			local result = {}
			for k,v in pairs(model) do
				result[k] = v.create()
			end
			return result
		end,
	}
end


function M.json(model)
	assert(model and is_model(model), "Expected an object model to json encode/decode")
	return {
		encode = function(v)
			return json.encode(model.encode(v))
		end,
		decode = function(v)
			return model.decode(json.decode(v))
		end,
		create = function()
			return model.create()
		end
	}
end



function M.base64(model)
	assert(model and is_model(model), "Expected an object model to base64 encode/decode")
	return {
		encode = function(v)
			return base64.encode(model.encode(v))
		end,
		decode = function(v)
			return model.decode(base64.decode(v))
		end,
		create = function()
			return model.create()
		end
	}
end


function M.zip(model)
	assert(model and is_model(model), "Expected an object model to zip/unzip")
	return {
		encode = function(v)
			local encoded = model.encode(v)
			assert(type(encoded) == "string", "Expected a string to zip encode")
			return zlib.deflate(encoded)
		end,
		decode = function(v)
			assert(type(v) == "string", "Expected a string to zip decode")
			return model.decode(zlib.inflate(v))
		end,
		create = function()
			return model.create()
		end
	}
end

return  M
