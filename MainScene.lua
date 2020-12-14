
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    audio.playBGMSync("music/mainbg.ogg", true)--播放背景音乐
    local sprite=display.newSprite("mainBG.png", display.cx, display.cy)
    self:addChild(sprite)

    display.addSpriteFrames("fruit.plist","fruit.png")--添加精灵帧，包含水果按钮等图片
    local btn=ccui.Button:create("startBtn_N.png","startBtn_S.png","startBtn_N.png",1)
    self:addChild(btn)
    btn:setPosition(display.cx, display.cy-80) 
    btn:addTouchEventListener(function (ref,eventType)
        if cc.EventCode.BEGAN==eventType then
            print("began")
            audio.playEffectSync("music/btnStart.ogg", false)
        elseif cc.EventCode.MOVED==eventType then
            print("moved")
        elseif cc.EventCode.ENDED==eventType then
            print("ended")
            local newSceneClass=require("app.scenes.playerScene")
            local newScene=newSceneClass:new()
            display.replaceScene(newScene, "turnOffTiles", 0.3)
        elseif cc.EventCode.CANCELLED==eventType then
            print("cancelled")
        end
    end)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
