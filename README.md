# desert
(de)sert is a Lua table (de)serialiser for the Defold game engine. The purpose of this library project is to simplify how data structures are serialized. In many cases it's enough to JSON encode and zip the data structure, but what if the data structure contains values that can't be automatically converted to JSON, for example userdata values such as vectors and matrices? Desert has been created to handle these cases and a few more. Desert can:

* Encode and decode
  * Primitive types (string, number, integer, boolean, nil) and Lua tables
  * Defold userdata
    * Vector3
    * Vector4
    * Vector (arbitrary length)
    * Matrix4
	* Quaternion
  * Game objects including script properties
* Encode and decode to JSON (with optional zlib compression)

## Limitations
Currently Desert has the following limitations:

* Defold userdata of type hash or url is not supported
* Keys must be of type string


## Installation
You can use the Desert in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

https://github.com/britzl/desert/archive/master.zip

Or point to the ZIP file of a [specific release](https://github.com/britzl/desert/releases).


## Usage
Desert is based around the concept of data models. You start by creating a data model that describes each element of your data structure, meaning it's keys and value types. Once the model is created it can be used to serialize and deserialize data in the format described by the model.

	local desert = require "desert.desert"

	local user_model = desert.json(desert.object({
		id = desert.number(),
		name = desert.string(),
		position = vmath.vector3(),
	}))

	local user1 = { id = 1234, name = "Mr Brown", position = vmath.vector3(10, 20, 30) }
	local user2 = { id = 5678, name = "Mr Pink", position = vmath.vector3(40, 50, 60) }

	local encoded_user1 = user_model.encode(user1)
	local encoded_user2 = user_model.encode(user2)

	-- store encoded_user1 and encoded_user2 to disk
	-- load them from disk and decode to get the original structure back

	local decoded_user1 = user_model.decode(encoded_user1)
	local decoded_user2 = user_model.decode(encoded_user2)

## API

### desert.number(default)

### desert.integer(default)

### desert.boolean(default)

### desert.string(default)

### desert.vector3(default)

### desert.vector4(default)

### desert.vector(default)

### desert.quat(default)

### desert.matrix4(default)

### desert.func(fn)

### desert.ignore()

### desert.object(table)

### desert.tableof(model)

### desert.gameobject(factory_url, properties_model)

### desert.json(model)

### desert.zip(model)
