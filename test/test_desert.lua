local desert = require "desert.desert"

return function()

	describe("desert", function()
		before(function()
		end)

		after(function()
		end)

		it("should be able to encode and decode a number", function()
			local num = 123.456
			local r = desert.number().encode(num)
			assert(num == desert.number().decode(r))
		end)

		it("should be able to encode and decode an integer", function()
			local num = 123.456
			local r = desert.integer().encode(num)
			assert(123 == desert.integer().decode(r))
		end)

		it("should be able to encode and decode a string", function()
			local s = "lorem ipsum"
			local r = desert.string().encode(s)
			assert(s == desert.string().decode(r))
		end)

		it("should be able to encode and decode a boolean", function()
			assert(desert.boolean().decode(desert.boolean().encode(true)) == true)
			assert(desert.boolean().decode(desert.boolean().encode(false)) == false)
		end)

		it("should be able to encode and decode a vector3", function()
			local v3 = vmath.vector3(1, 2, 3)
			local t = desert.vector3().encode(v3)
			assert(t.x == v3.x and t.y == v3.y and t.z == v3.z)
			assert(v3 == desert.vector3().decode(t))
		end)

		it("should be able to encode and decode a vector4", function()
			local v4 = vmath.vector4(1, 2, 3, 4)
			local t = desert.vector4().encode(v4)
			assert(t.x == v4.x and t.y == v4.y and t.z == v4.z and t.w == v4.w)
			assert(v4 == desert.vector4().decode(t))
		end)

		it("should be able to encode and decode a matrix4", function()
			local m4 = vmath.matrix4()
			m4.m00 = 00 m4.m01 = 01 m4.m02 = 02 m4.m03 = 03
			m4.m10 = 10 m4.m11 = 11 m4.m12 = 12 m4.m13 = 13
			m4.m20 = 20 m4.m21 = 21 m4.m22 = 22 m4.m23 = 23
			m4.m30 = 30 m4.m31 = 31 m4.m32 = 32 m4.m33 = 33
			local t = desert.matrix4().encode(m4)
			local decoded = desert.matrix4().decode(t)
			assert(m4 == decoded)
		end)

		it("should be able to encode and decode a vector", function()
			local v = vmath.vector({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
			local v2 = vmath.vector({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
			local t = desert.vector().encode(v)
			local decoded = desert.vector().decode(t)
		end)

		it("should be able to encode and decode a quaternion", function()
			local q = vmath.quat(1, 2, 3, 4)
			local t = desert.quat().encode(q)
			assert(t.x == q.x and t.y == q.y and t.z == q.z and t.w == q.w)
			assert(q == desert.quat().decode(t))
		end)

		it("should be able to encode and decode a list of values of the same type", function()
			local list = { 1, 2, 3 }
			local model = desert.tableof(desert.number())
			local t = model.encode(list)
			assert(#t == #list)
			local list2 = model.encode(t)
			assert(#list == #list2)
			assert(list[1] == list2[1])
			assert(list[2] == list2[2])
			assert(list[3] == list2[3])
		end)

		it("should be able to encode and decode a game object", function()
			local factory_url = "factories#desert"
			local pos = vmath.vector3(10, 20, 0.5)
			local rot = vmath.quat_rotation_z(math.rad(45))
			local scale = vmath.vector3(1.5, 2.5, 1.0)
			local props = { foo = 123, bar = vmath.vector3(5, 6, 7) }
			local id = factory.create(factory_url, pos, rot, props, scale)
			local model = desert.gameobject(factory_url, { script = { foo = desert.number(), bar = desert.vector3() } })
			local t = model.encode(id)
			go.delete(id)

			local newid = model.decode(t)
			assert(go.get_position(newid) == pos)
			assert(go.get_scale(newid) == scale)
			assert(go.get_rotation(newid) == rot)
			assert(go.get(msg.url(nil, newid, "script"), "foo") == 123)
			assert(go.get(msg.url(nil, newid, "script"), "bar") == vmath.vector3(5, 6, 7))
			go.delete(newid)
		end)

		it("should be able to encode and decode a game object with default values", function()
			local factory_url = "factories#desert"
			local id = factory.create(factory_url)
			local pos = go.get_position(id)
			local rot = go.get_rotation(id)
			local scale = go.get_scale(id)
			local model = desert.gameobject(factory_url, {})
			local t = model.encode(id)
			go.delete(id)

			local newid = model.decode(t)
			assert(go.get_position(newid) == pos)
			assert(go.get_scale(newid) == scale)
			assert(go.get_rotation(newid) == rot)
			go.delete(newid)
		end)

		it("should be able to encode and decode an object", function()
			local model = desert.object({
				num = desert.number(),
				int = desert.integer(),
				s = desert.string(),
				b = desert.boolean(),
				v3 = desert.vector3(),
				v4 = desert.vector4(),
				quat = desert.quat(),
			})
			local data = {
				num = 123.456,
				int = 123.501,
				s = "abcdefgh",
				b = true,
				v3 = vmath.vector3(1, 2, 3),
				v4 = vmath.vector4(4, 5, 6, 7),
				quat = vmath.quat(11, 12, 13, 14),
			}
			local result = model.decode(model.encode(data))
			assert(data.num == result.num)
			assert(math.floor(data.int) == result.int)
			assert(data.s == result.s)
			assert(data.b == result.b)
			assert(data.v3 == result.v3)
			assert(data.v4 == result.v4)
			assert(data.quat == result.quat)
		end)

		it("should be able to encode and decode to json", function()
			local model = desert.json(desert.object({
				num = desert.number(),
				v3 = desert.vector3(),
			}))
			local data = {
				num = 123.456,
				v3 = vmath.vector3(1, 2, 3),
			}
			local encoded = model.encode(data)
			assert(type(encoded) == "string")
			local decoded = json.decode(encoded)
			assert(type(decoded) == "table")
		end)

		it("should be able to inflate and deflate using zlib", function()
			local model = desert.zip(desert.string())
			local data = "foobar"
			local encoded = model.encode(data)
			assert(type(encoded) == "string")
			local decoded = model.decode(encoded)
			assert(data == decoded)
		end)

		it("should be able to create default values for types", function()
			local model = desert.object({
				num = desert.number(),
				int = desert.integer(),
				s = desert.string(),
				b = desert.boolean(),
				v3 = desert.vector3(),
				v4 = desert.vector4(),
				quat = desert.quat(),
			})
			local data = model.create()
			assert(type(data) == "table")
			assert(type(data.num) == "number")
			assert(type(data.int) == "number")
			assert(type(data.s) == "string")
			assert(type(data.b) == "boolean")
			assert(type(data.v3) == "userdata")
			assert(type(data.v4) == "userdata")
			assert(type(data.quat) == "userdata")
		end)

		it("should be able to encode and decode a function", function()
			local model = desert.object({
				rng = desert.func(math.random),
				time = desert.func(os.time),
			})
			local encoded = model.encode({
				rng = math.random,
				time = os.time,
			})
			local decoded = model.decode(encoded)
			assert(decoded.rng == math.random)
			assert(decoded.time == os.time)
		end)

		it("should be able to run a function once an object is decoded", function()
			local model = desert.tableof(desert.vector3())
			local input = { vmath.vector3(10), vmath.vector3(20), vmath.vector3(30) }
			local encoded = model.encode(input)

			local decoded = desert.after(model, function(t)
				for i,v3 in ipairs(t) do t[i] = v3 * 10 end
				return t
			end).decode(encoded)
			
			assert(decoded[1] == vmath.vector3(10) * 10)
			assert(decoded[2] == vmath.vector3(20) * 10)
			assert(decoded[3] == vmath.vector3(30) * 10)
		end)
	end)
end
