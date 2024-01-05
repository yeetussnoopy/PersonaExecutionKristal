local spell, super = Class(Spell, "execute")

function spell:init()
	super.init(self)

	-- Display name
	self.name = "Execute"
	-- Name displayed when cast (optional)
	self.cast_name = "Execute"

	-- Battle description
	self.effect = "Kills\nbelow 50%"
	-- Menu description
	self.description = "Deals large physical damage to 1 enemy."

	-- TP cost
	self.cost = 40

	-- Target mode (ally, party, enemy, enemies, or none)
	self.target = "enemy"

	-- Tags that apply to this spell
	self.tags = { "Damage" }
end

function spell:getCastMessage(user, target)
	return "* " .. user.chara:getName() .. " used " .. self:getCastName() .. "!"
end

function spell:onCast(user, target)
	local damage = math.floor((((user.chara:getStat("attack") * 100) / 20) - 3 * (target.defense)) * 1.3)

	local function zoom(scale, wait, overwrite_pos)
		local tx, ty = target:getRelativePos(target.width / 2, target.height / 2)
		Game.battle.camera:setZoom(scale)
		if overwrite_pos then
			Game.battle.camera:setPosition(overwrite_pos[1], overwrite_pos[2])
		else
			Game.battle.camera:setPosition(tx, ty)
		end
	end

	local cam_x, cam_y = Game.battle.camera.x, Game.battle.camera.y
	local user_hold_x, user_hold_y = user.x, user.y
	
	local old_target_layer = target.layer




	local function generateSlash(scale_x)
		local cutAnim = Sprite("effects/attack/cut")
		cutAnim.color = COLORS.black
		Assets.playSound("scytheburst")
		Assets.playSound("criticalswing", 1.2, 1.3)
		local afterimage1 = AfterImage(user, 0.5)
		local afterimage2 = AfterImage(user, 0.6)
		afterimage1.physics.speed_x = 2.5
		afterimage2.physics.speed_x = 5
		afterimage2:setLayer(afterimage1.layer - 1)
		user:setAnimation("battle/attack", function()
			user:setAnimation("battle/idle")
		end)
		cutAnim:setOrigin(0.5, 0.5)
		cutAnim:setScale(4.5 * scale_x, 4.5)
		cutAnim:setPosition(target:getRelativePos(target.width / 2, target.height / 2))
		cutAnim.layer = target.layer + 0.01
		cutAnim:play(1 / 15, false, function(s) s:remove() end)
		user.parent:addChild(cutAnim)
		user.parent:addChild(afterimage1)
		user.parent:addChild(afterimage2)
		target:setAnimation("hurt", function()
			target:setAnimation("idle")
		end)
	end



	Game.battle.timer:after(0.1 / 2, function()
		rect2 = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		rect2:setColor(love.math.colorFromBytes(0, 0, 0))
		rect2:setLayer(100)
		Game.stage:addChild(rect2)
		Assets.playSound("noise")

		Game.battle.timer:after(0.5, function()
			local tx, ty = target:getRelativePos(target.width / 2, target.height / 2)

			user.x = tx + 40
			user.y = ty - 18

			user:setSprite("pose")


			zoom(2)

			rect2:remove()

			Game.battle.timer:after(0.8, function()
				Assets.playSound("grab")
				user:setSprite("battle/attackready_1")


				Game.battle.timer:after(1, function()
					Assets.playSound("noise")
					zoom(3.2)


					local layer_hold = target
					target:setLayer(100)

					rect2 = Rectangle(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
					rect2:setColor(love.math.colorFromBytes(255, 0, 0))
					rect2:setLayer(99)
					Assets.playSound("noise")


					Game.battle:addChild(rect2)


					local fx = target:addFX(ColorMaskFX({ 0, 0, 0 }))

					Game.battle.timer:after(1.2, function()
						generateSlash(1)
						--target:hurt(500, user, target.onDefeatFatal)
						Game.battle.timer:after(1.21, function()
							generateSlash(-1)

							Game.battle.timer:after(1.22, function()
								
								if target.health < (target.max_health * 0.50) then
								generateSlash(1)
								generateSlash(-1)
								target:hurt(target.health + 999, user, target.onDefeatFatal)
								else
									generateSlash(1)
									target:hurt(damage, user, target.onDefeatFatal)
								end
								Game.battle.timer:after(1.25, function()
									if target then
										target:setLayer(old_target_layer)
										target:removeFX(fx)
									end
									user.x = user_hold_x
									user.y = user_hold_y
									zoom(1)
									Game.battle.camera:setPosition(cam_x, cam_y)
									rect2:remove()
									Game.battle:finishActionBy(user)
								end)
							end)
						end)
					end)
				end)
			end)
		end)
	end)



	return false
end

return spell
