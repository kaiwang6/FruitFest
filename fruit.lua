local fruitClass=class("fruitClass",function(x,y,fruitIndex)
    --display.addSpriteFrames("fruit.plist","fruit.png")
    --在mainScene里面添加过精灵帧之后，就不需要再次添加
    fruitIndex=fruitIndex or math.random(100)  % 8 +1
    --print("fruitIndex",fruitIndex)
    local sprite=display.newSprite("#fruit"  .. fruitIndex .. '_1.png')
    sprite.isActive=false
    sprite.x=x
    sprite.y=y
    sprite.fruitIndex=fruitIndex
    return sprite
end)

function fruitClass:ctor()
    --print("create a fruit")
end

-----设置高亮
function fruitClass:setActive(active)
    self.isActive=active

    local frame
    if active then 
        frame=display.newSpriteFrame("fruit" .. self.fruitIndex .. '_2.png')
    else
        frame=display.newSpriteFrame("fruit" .. self.fruitIndex .. '_1.png')
    end
    self:setSpriteFrame(frame)
end

-----获取水果的宽度
function fruitClass.getWidth()
    width=0
    if 0==width then
        local sprite=display.newSprite("#fruit1_1.png")
        width=sprite:getContentSize().width
    end
    return width
end


return fruitClass