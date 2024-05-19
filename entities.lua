
--
-- entity
--

daladas.vector_up = vector.new(0, 0, 0)

minetest.register_entity('daladas:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "ju52_wheels.b3d",
	textures = {
            "airutils_metal.png", --suporte bequilha
            daladas.skin_texture, --suporte trem
            "airutils_black.png", --pneu bequilha
            "airutils_metal.png", --roda bequilha
            "airutils_black.png", --pneu trem
            "airutils_metal.png", --roda trem
        },
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

minetest.register_entity('daladas:daladas',
    airutils.properties_copy(daladas.plane_properties)
)

