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
* Encode and decode to JSON
* Inflate and deflate using zlib
* Encode and decode to base64

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

    -- encoded_user1 and encoded_user2 are now a json encoded representation of
    -- user1 and user2 with the vector3's converted into something serializable
    -- you can now store encoded_user1 and encoded_user2 to disk and later
	-- load them from disk and decode to get the original structure back

	local decoded_user1 = user_model.decode(encoded_user1)
	local decoded_user2 = user_model.decode(encoded_user2)

A more advanced use case:

    -- this is the model representing an enemy
    -- the enemies are created from a factory and they have a starting the health of 100
    local enemy_model = desert.object({
        id = desert.gameobject("factories#enemy"),
        health = desert.number(100),
    })

    -- this is the player model
    -- the player is created from a factory, it has a starting health of 200, a
    -- total of 5 lives and a name
    local player_model = desert.object({
        id = desert.gameobject("factories#player"),
        health = desert.number(200),
        lives = desert.integer(5),
        name = desert.string(),
    })

    -- the game state consists of a list of enemies, a score and a player
    -- the entire game state is json encoded and zipped when encoded
    local game_model = desert.zip(desert.json(desert.object({
        enemies = desert.tableof(enemy_model),
        score = desert.integer(0),
        player = player_model,
    })))

    -- this will create an instance of the game model
    -- it will create the player instance and setup the score and an empty list
    -- of enemies
    local game = game_model.create()
    -- set the player name
    game.player.name = "Mr White"
    -- create 10 enemies
    for i=1,10 do
        table.insert(game.enemies, enemy_model.create())
    end

    -- encode the game state, first as a json object and the zipped
    local encoded_game_state = game_model.encode(game)

    -- save it

    -- decode it. this will recreate the game objects in their positions with
    -- rotation and scale
    game = game_model.decode(encoded_game_state)

## API
The API consists of a number of functions describing different data types, typically pure Lua data types such as numbers, booleans or strings, but also complex data types such as table structures or Defold user data. Each type has a corresponding API function. When the API function is invoked it will return an object (table) containing functions that can be used encode, decode and create values of the specific type. In many cases the values aren't transformed at all which usually is the case with primitive data types, but for complex data types and user data the encoding will result in a transformation of the value into a serializable form. Examples:

    pprint(desert.number().encode(123))  -- 123
    pprint(desert.integer().encode(123.45))  -- 123
    pprint(desert.vector3().encode(vmath.vector3(10.5, 200, 0.5)))  -- { x = 10.5, y = 200, z = 0.5 }

### desert.number(default)
Lua number

### desert.integer(default)
Integer, rounded down

### desert.boolean(default)
Lua boolean

### desert.string(default)
Lua string

### desert.vector3(default)
Defold vector3

### desert.vector4(default)
Defold vector4

### desert.vector(default)
Defold vector of arbitrary length

### desert.quat(default)
Defold quaternion

### desert.matrix4(default)
Defold matrix4

### desert.func(fn)
Lua function. The value will be replaced by an empty value and when decoded the function will returned.

### desert.ignore()
The value will be replaced by nil

### desert.object(table)
Lua table. The key-value pairs are expected to be desert types.

    local enemy_model = desert.object({ id = desert.number(), position = desert.vector3() })
    local enemy = enemy_model.create({ id = 1, position = vmath.vector3(10, 20, 0)})
    local encoded_enemy = enemy_model.encode(enemy)

### desert.table(table)
Lua table. The values of the table will not be processed.

### desert.tableof(model)
Lua table with values of a single desert type.

    -- a list of numbers
    local numbers = desert.tableof(desert.number())
    local encoded_numbers = numbers.encode({ 1, 2.5, 10, 50 })

    -- a list of strings
    local strings = desert.tableof(desert.string())
    local encoded_strings = strings.encode({ "Foo", "Bar" })

    -- a list of enemy objects
    local enemy_model = desert.object({ id = desert.number(), position = desert.vector3() })
    local enemies = desert.tableof(enemy_model)
    local encoded_enemies = enemies.encode({
        enemy_model.create({ id = 1, position = vmath.vector3(10, 20, 0)}),
        enemy_model.create({ id = 2, position = vmath.vector3(40, 50, 0)}),
    })

### desert.gameobject(factory_url, properties_model)
Defold game object id

    -- The enemy is a game object created from the factory with url "#factory"
    -- It has two script properties: "type" and "health"
    local enemy_model = desert.game_object("#factory", { type = desert.string(), health = desert.number() })
    local enemy_id = factory.create("#factory", vmath.vector3(100, 100, 0), nil, { type = 1, health = 100 })
    local encoded_enemy = enemy_model.encode(enemy_id)

### desert.json(model)
Encode/decode to json. Expects that the value produced by the model can be json encoded.

### desert.zip(model)
Inflate/deflate using zlib. Expects that the value produced by the model is a string.

### desert.base64(model)
Encode/decode to base64. Expected that the value produced by the model is a string.

### desert.after(model, fn)
Apply a function to the value produced when the model is decoded.
