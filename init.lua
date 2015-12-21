local pillow_rightclick = nil

-- if beds is available, this will act like one
if beds then
	pillow_rightclick = function(pos, node, clicker)
		beds.on_rightclick(pos, clicker)
	end
end

-- Store the description of the pillow, since I have to make two copies.
--  There may be a neater way to turn the pillow over, but I haven't
--  thought of it. A problem with this is that they don't stack together.
local desc = {
	description = 'Body Pillow',
	drawtype = 'mesh',
	visual_scale = 1.0,
	tiles = {'body_pillow_03.png'},
	use_texture_alpha = true,
	mesh = 'body_pillow.b3d',
	paramtype = 'light',
	inventory_image = 'body_pillow_icon.png',
	groups = {oddly_breakable_by_hand=1, flammable=2},
	automatic_rotate = false,
	walkable = true,
	selection_box = { type = 'fixed', fixed = {-0.3, -0.5, -0.3, 0.3, -0.3, 1.3}, },
	collision_box = { type = 'fixed', fixed = {-0.3, -0.5, -0.3, 0.3, -0.3, 1.3}, },
	paramtype2 = 'facedir',

	-- sleep if the bed mod is there
	on_rightclick = pillow_rightclick,

	-- Shift-left-click to turn the pillow over.
	-- The mesh is set on the bottom of its cube, to lie on the ground.
	-- Really turning it over would leave it floating in the air.
	on_punch = function(pos, node, puncher, pointed_thing)
		if not (puncher and puncher:get_player_control().sneak) then
			return
		end

		if node and node.name == 'body_pillow:body_pillow' then
			minetest.swap_node(pos, {name='body_pillow:body_pillow_reversed', param2=node.param2})
		else
			minetest.swap_node(pos, {name='body_pillow:body_pillow', param2=node.param2})
		end
	end,

	-- place it neatly, even on a wall, and not inside anything
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0
		local be_free = {x=0,y=0,z=0}

		if p0.y == p1.y then
			-- placing on a wall
			be_free = {x = p1.x, y = p1.y + 1, z = p1.z}

			if p0.x > p1.x then
				param2 = 49
			elseif p0.x < p1.x then --
				param2 = 15
			elseif p0.z > p1.z then --
				param2 = 8
			elseif p0.z < p1.z then --
				param2 = 30
			end
		else
			-- placing on the ground
			local placer_pos = placer:getpos()
			if placer_pos then
				local dir = {
					x = p1.x - placer_pos.x,
					y = p1.y - placer_pos.y,
					z = p1.z - placer_pos.z
				}
				param2 = minetest.dir_to_facedir(dir)

				if math.abs(dir.x) > math.abs(dir.z) then
					be_free.x = p1.x + (dir.x / math.abs(dir.x))
					be_free.y = p1.y
					be_free.z = p1.z
				else
					be_free.x = p1.x
					be_free.y = p1.y
					be_free.z = p1.z + (dir.z / math.abs(dir.z))
				end
			end
		end

		-- be_free is the cube that the pillow will extend into.
		-- Don't let it be set inside a solid object.
		local nod = minetest.get_node_or_nil(be_free)
		if not nod
			or not nod.name
			or not minetest.registered_nodes[nod.name]
			or minetest.registered_nodes[nod.name].walkable == true then
			return
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
}
-- another copy of the description table, for the reversed pillow
local desc2 = table.copy(desc)
desc2.tiles = {'body_pillow_04.png'},

-- side one
minetest.register_node('body_pillow:body_pillow', desc)
-- side two
minetest.register_node('body_pillow:body_pillow_reversed', desc2)

-- register recipe
minetest.register_craft({
	output = 'body_pillow:body_pillow',
	recipe = {
		{"", "wool:white", ""},
		{"wool:red", "wool:green", "wool:blue"},
		{"wool:orange", "wool:violet", "wool:yellow"},
	},
})
