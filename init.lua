daladas={}

dofile(minetest.get_modpath("daladas") .. DIR_DELIM .. "forms.lua")

daladas.skin_texture = "texture_daladas.png"
function daladas.set_skin(object, skin_image_name, search_string)
    if skin_image_name then
        local entity = object:get_luaentity()
        entity._color = nil
        entity._skin = skin_image_name
        local l_textures = texture_daladas.png
        for _, texture in ipairs(l_textures) do
            local indx = texture:find(search_string)
            if indx then
                l_textures[_] = skin_image_name
                --minetest.chat_send_all(l_textures[_])
            end
        end
        object:set_properties({textures=l_textures})
    end
end

function daladas.register_parts_method(self)
    --self._skin = self._vehicle_custom_data._skin

    local pos = self.object:get_pos()

    --local wheels=minetest.add_entity(pos,'ju52:wheels')
    --wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
	-- set the animation once and later only change the speed
    --wheels:set_animation({x = 1, y = 12}, 0, 0, true)
    --self.wheels = wheels
    --airutils.add_paintable_part(self, self.wheels)

    self.object:set_bone_position("aileron_base_r", {x=93.7994, y=3.35, z=-15.3002}, {x=180, y=-7.45, z=5.3})
    self.object:set_bone_position("aileron_base_l", {x=-93.7994, y=3.35, z=-15.3002}, {x=180, y=7.54, z=-5.3})

    self.object:set_bone_position("flap_base_l", {x=-49.2648, y=-1.41543, z=-12.0}, {x=0, y=185.4, z=0})
    self.object:set_bone_position("flap_base_r", {x=49.2648, y=-1.41543, z=-12.0}, {x=0, y=-185.4, z=0})

    --daladas.set_skin(self.object, self._skin, daladas.skin_texture)
end

function daladas.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end

    local pos = self.object:get_pos()
end

function daladas.step_additional_function(self)

    if (self.driver_name==nil) and (self.co_pilot==nil) then --pilot or copilot
        return
    end

    local pos = self._curr_pos

    local speed_angle = airutils.get_gauge_angle(self._indicated_speed, -45)
    self.object:set_bone_position("speed1", {x=-6.5, y=-40.6, z=16.6}, {x=0, y=-speed_angle, z=0})
    self.object:set_bone_position("speed2", {x=6.5, y=-40.6, z=16.6}, {x=0, y=-speed_angle, z=0})
    local climb_angle = airutils.get_gauge_angle(self._climb_rate)
    self.object:set_bone_position("climber1", {x=-9.5, y=-40.6, z=16.6}, {x=0, y=-(climb_angle-90), z=0})
    self.object:set_bone_position("climber2", {x=3.5, y=-40.6, z=16.6}, {x=0, y=-(climb_angle-90), z=0})
    local energy_indicator_angle = airutils.get_gauge_angle((self._max_fuel - self._energy)/1.5) - 90
    self.object:set_bone_position("fuel", {x=0, y=-40.6, z=15.35}, {x=0, y=(energy_indicator_angle+180), z=0})
    
    self.object:set_bone_position("compass", {x=0, y=-40.55, z=18.2}, {x=0, y=(math.deg(self._yaw)), z=0})
    self.object:set_bone_position("compass_plan", {x=0, y=-40.4, z=18.2}, {x=0, y=airutils.get_adf_angle(self, pos), z=0})

    --altimeters
    local altitude = (pos.y / 0.32) / 100
    local hour, minutes = math.modf( altitude )
    hour = math.fmod (hour, 10)
    minutes = minutes * 100
    minutes = (minutes * 100) / 100
    local minute_angle = (minutes*-360)/100
    local hour_angle = (hour*-360)/10 + ((minute_angle*36)/360)

    self.object:set_bone_position("altimeter_p1_1", {x=-3.5, y=-40.6, z=16.6}, {x=0, y=-(hour_angle), z=0})
    self.object:set_bone_position("altimeter_p2_1", {x=-3.5, y=-41.1, z=16.6}, {x=0, y=-(minute_angle), z=0})

    self.object:set_bone_position("altimeter_p1_2", {x=9.5, y=-40.6, z=16.6}, {x=0, y=-(hour_angle), z=0})
    self.object:set_bone_position("altimeter_p2_2", {x=9.5, y=-41.1, z=16.6}, {x=0, y=-(minute_angle), z=0})

    --power
    local power_angle = ((self._power_lever*1.5)/4.5)
    self.object:set_bone_position("power", {x=1, y=-37.4, z=14}, {x=0, y=-(power_angle - 20), z=90}) --(power_indicator_angle-45)
end

function daladas._custom_punch_when_attached(self, player)
    local itmstck=player:get_wielded_item()
    local item_name = ""
    if itmstck then item_name = itmstck:get_name() end
    local _,indx = item_name:find('dye:')
    if indx and self._engine_running == false  then
        local name = player:get_player_name()
        daladas.paint_formspec(name)
        itmstck:set_count(itmstck:get_count()-1)
	    player:set_wielded_item(itmstck)
    end
end



function destroy_blocks_around(pos, radius, radius2)
        local minp = vector.subtract(pos, radius)
        local maxp = vector.add(pos, radius)
            for x = minp.x, maxp.x do
                for y = minp.y, maxp.y do
                    for z = minp.z, maxp.z do
                        local p = {x = x, y = y, z = z}
                        if vector.distance(pos, p) <= radius and vector.distance(pos, p) >= radius2 then
                            minetest.remove_node(p)
                        end
                    end
                end
            end
        end

minetest.register_entity("daladas:bombe", {
    drawtype = "mesh",
    mesh = "bombe.obj",
    textures = {"texture_bombe.png"},
    radius = 0,  -- Rayon initial de la sphère
    minetest.sound_play({
        name = "oug",  -- Remplacez "modname_" par le nom de votre mod
        pos = pos,  -- Si vous voulez un son positionnel
        gain = 1.0,  -- Volume maximal
        max_hear_distance = 10,
		}),
    on_step = function(self, dtime)
        -- Vitesse d'expansion de l'onde de choc
        local expansion_rate = 0.01  -- Ajustez selon vos besoins

        -- Augmenter le rayon de l'onde de choc en fonction du temps écoulé depuis le dernier appel
        self.radius = self.radius + expansion_rate * dtime

        -- Détruisez les blocs dans le rayon de la sphère
        destroy_blocks_around(self.object:get_pos(), self.radius, (self.radius-(expansion_rate+5)))
 
        -- Ajuster la taille visuelle de l'entité en fonction de son rayon
        self.object:set_properties({
            visual_size = {x = self.radius*2, y = self.radius*2}
        })

        -- Détruisez l'entité lorsque la sphère a atteint une certaine taille maximale
        if self.radius >= 10 then
            self.object:remove()
        end
    end
})



--local ctrl = get_player_control()
--local attached_to = player:get_attach()
--    if attached_to and attached_to:get_luaentity() and attached_to:get_luaentity().name == "daladas:daladas" and ctrl.aux then
--        local pos = attached_to:get_pos()
--        pos.y = pos.y - 1 -- Ajuster la hauteur de la bombe pour qu'elle soit juste en dessous de l'avion
--        local entity = minetest.add_entity(pos, "daladas:bombe")
--        if entity then
--            local bombe = entity:get_luaentity()
--            if bombe then
--                bombe.velocity = {x = 0, y = -5, z = 0} -- Vitesse de chute de la bombe
--            end
--        end
--    end


daladas.plane_properties = {
	initial_properties = {
	    physical = true,
        collide_with_objects = false,
	    collisionbox = {-3, -0.5, -3, 3, 3, 3},
	    selectionbox = {-5, -1.5, -5, 5, 3, 5},
	    visual = "mesh",
        backface_culling = false,
	    mesh = "daladas.obj",
        stepheight = 0.6,
        textures = {"texture_daladas.png"
        },
    },
    textures = {},
    _anim_frames = 10,
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "",
    hp_max = 80,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.5,
    buoyancy = 1.1,
    physics = airutils.physics,
    _vehicle_name = "daladas",
    _seats = {
        {x=0,y=0,z=-10},
    },
    _seats_rot = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,},  --necessary when using reversed seats
    _have_copilot = false, --wil use the second position of the _seats list
    _have_landing_lights = true,
    _have_auto_pilot = true,
    _have_adf = true,
    _have_manual = false,
    _max_plane_hp = 120,
    _enable_fire_explosion = true,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 1,
    _wing_angle_extra_flaps = 2.5,
    _wing_span = 50, --meters
    _min_speed = 4,
    _max_speed = 30,
    _max_fuel = 60,
    _fuel_consumption_divisor = 50000,
    _speed_not_exceed = 60,
    _damage_by_wind_speed = 0.5,
    _hard_damage = true,
    _min_attack_angle = 0.2,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 3,  --3
    _tail_lift_max_speed = 10,  --7
    _max_engine_acc = 10, --========================V==========================
    _tail_angle = 0,
    _lift = 27, --=========V===========================
    _trunk_slots = 50, --the trunk slots
    _rudder_limit = 30.0,
    _elevator_limit = 60,--=======================plus bas c'est, plus on peut le controler avec les touches
    _flap_limit = -30.0, --just a decorarion, in degrees
    _elevator_response_attenuation = 2,
    _pitch_intensity = 0.4, 
    _yaw_intensity = 20, 
    _yaw_turn_rate = 10, --degrees
    _elevator_pos = {x=0, y=21.8837, z=-87.2391},
    _rudder_pos = {x=0, y=25.109, z=-92.2073},
    _aileron_r_pos = {x=0,y=0,z=0},
    _aileron_l_pos = {x=0,y=0,z=0},
    _invert_ailerons = true,
    _color = "#DDDDDD",
    _color_2 = "#FFFFFF",
    _skin_target_texture = daladas.skin_texture,
    _skin = "texture_daladas.png",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 0,
    _elevator_angle = 0,
    _power_lever = 0,
    _last_applied_power = 0,
    _energy = 10, --===========V
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = false,
    _instruction_mode = false, --flag to intruction mode
    _command_is_given = false, --flag to mark the "owner" of the commands now
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _inv = nil,
    _inv_id = "",
    _collision_sound = "oug", --the col sound
    _engine_sound = "daladas_engine",
    _painting_texture = {daladas.skin_texture,}, --the texture to paint
    _painting_texture_2 = {"texture_daladas.png",}, --the texture to paint
    _mask_painting_associations = {},
    _register_parts_method = daladas.register_parts_method, --the method to register plane parts
    _destroy_parts_method = daladas.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _custom_punch_when_attached = daladas._custom_punch_when_attached, --the method to execute click action inside the plane
    _custom_step_additional_function = daladas.step_additional_function,

    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

dofile(minetest.get_modpath("daladas") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("daladas") .. DIR_DELIM .. "entities.lua")

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/daladas.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end


local old_entities = {"ju52:seat_base","ju52:engine"}
for _,entity_name in ipairs(old_entities) do
    minetest.register_entity(":"..entity_name, {
        on_activate = function(self, staticdata)
            self.object:remove()
        end,
    })
end

