-- Pushblocks
-- (c)2019 Nigel Garnett.

local function push_pull(pos,pt,dir)
    local ptpos = minetest.get_pointed_thing_position(pt, true)
    local add = { x=0, y=0, z=0 }
    if pos.y > ptpos.y then add.y = dir end
    if pos.y < ptpos.y then add.y = -dir end
    if pos.x > ptpos.x then add.x = dir end
    if pos.x < ptpos.x then add.x = -dir end
    if pos.z > ptpos.z then add.z = dir end
    if pos.z < ptpos.z then add.z = -dir end
    return add
end


local function move_block(pos,dir,clicker)
    local node = minetest.get_node(pos)
    local newpos = { x=pos.x+dir.x, y=pos.y+dir.y, z=pos.z+dir.z }
    local moveto_node = minetest.get_node(newpos)
    if moveto_node.name == "air" then
        minetest.set_node(newpos,{name=node.name})
        minetest.set_node(pos,{name="air"})
    else
        minetest.sound_play("system-fault",{pos = newpos, gain = 10})
    end
end


minetest.register_node("pushblocks:ball", {
    description = "Pushblocks Ball",
    drawtype = "mesh",
    mesh = "mymeshnodes_sphere.obj",
    tiles = {"pushblocks_plain_ball.png^[colorize:#ff00ff:100"},
    is_ground_content = false,
    stack_max = 1,
    light_source = core.LIGHT_MAX,
    groups = {cracky = 3, snappy = 3, crumbly = 3},
    on_blast = function() end,
    on_punch = function(pos, node, puncher, pointed_thing)
        if puncher:get_player_control().sneak then
            local inv = puncher:get_inventory()
            if not (creative and creative.is_enabled_for
                    and creative.is_enabled_for(puncher:get_player_name()))
                    or not inv:contains_item("main", "pushblocks:ball") then
                local leftover = inv:add_item("main", "pushblocks:ball")
                if not leftover:is_empty() then
                    minetest.add_item(self.object:get_pos(), leftover)
                end
            end
            minetest.set_node(pos,{name="air"})
        else
            move_block(pos, push_pull(pos,pointed_thing,1), puncher)
        end
        return true
    end,
    on_dig = function() end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        move_block(pos, push_pull(pos,pointed_thing,-1), clicker)
        return false
    end,
    can_dig = function(pos,player)
        return false
    end,
})
