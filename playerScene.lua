fruitClass=require("app.scenes.fruit")

local playerScene = class("playerScene", function()
    return display.newScene("playerScene")
end)

-- playerScene.stage=0
-- print("playerScene.stage",playerScene.stage)

function playerScene:ctor()
    --print("playerScene:ctor")
    --audio.playBGMSync("music/playerbg.ogg", true)--播放背景音乐
    -- local sprite=display.newSprite("playBG.png", display.cx, display.cy)
    -- self:addChild(sprite)
    self.highScore=0    ---最高分数
    self.stage=1        ---当前关卡
    self.target=1000    ---通关分数
    self.curScore=0     ---当前分数
    self.xCount=8       ---水平方向水果数
    self.yCount=8       ---垂直方向水果数
    self.fruitGap=0     ---水果间距
    self.scoreStep=10   ---水果基分
    self.activeScore=0  ---当前高亮的水果得分
    self.sliderVal=0    ---进度条百分比

    self:init()
-----初始化随机数
    math.newrandomseed()
-----左下角水果的左下角的下标
    self.matrixLBX=(display.width-self.xCount*fruitClass.getWidth()-(self.xCount-1)*self.fruitGap)/2
    self.matrixLBY=(display.width-self.yCount*fruitClass.getWidth()-(self.yCount-1)*self.fruitGap)/2+130

    self:initMatrix()
    --如果初始化的矩阵没有可消除的水果，则从新初始化
    while self:checkMatrix()==false do
        for x=1,self.xCount do
            for y=1,self.yCount do
                self.matrix[x][y]:removeFromParent()
            end
        end
        self.matrix={}
        self:initMatrix()
    end
    --self:initMatrix()
end

function playerScene:init()
    --display.addSpriteFrames("fruit.plist","fruit.png")
    

    display.newSprite("playBG.png")
        :pos(display.cx,display.cy)
        :addTo(self)

----进度条
    self.slider=ccui.Slider:create()
    self.slider:align(display.LEFT_BOTTOM, 0, 0)
    self.slider:addTo(self)
    self.slider:loadBarTexture("The_time_axis_Tunnel.png", 1)
    self.slider:loadSlidBallTextures("The_time_axis_Trolley.png","The_time_axis_Trolley.png", "The_time_axis_Trolley.png",1)
    self.slider:setPercent(self.sliderVal)
    self.slider:setTouchEnabled(false)

----high score
    display.newSprite("#high_score.png")
        :align(display.LEFT_CENTER, display.left+15, display.top-30)
        :addTo(self)
    
    display.newSprite("#highscore_part.png")
        :align(display.LEFT_CENTER, display.cx+10, display.top-26)
        :addTo(self)

    ----从磁盘文件读取最高分
    local userDefault=cc.UserDefault:getInstance()
    self.highScore=tonumber(userDefault:getStringForKey("HighScore")) or 0
    
    self.highSorceLabel=display.newBMFontLabel({
        text=tostring(self.highScore),
        font="font/earth38.fnt",
    })
        :align(display.CENTER, display.cx+105, display.top-24)
        :addTo(self)

---stage
    local userDefault=cc.UserDefault:getInstance()
    self.stage=tonumber(userDefault:getStringForKey("stage")) or 1
    display.newSprite("#stage.png")
        :align(display.LEFT_CENTER, display.left+15, display.top-80)
        :addTo(self)

    display.newSprite("#stage_part.png")
        :align(display.LEFT_CENTER, display.left+170, display.top-80)
        :addTo(self)
    
    self.highStageLabel=display.newBMFontLabel({
        text=tostring(self.stage),
        font="font/earth32.fnt",
    })
        :align(display.CENTER, display.left+214, display.top-78)
        :addTo(self)
---target
    display.newSprite("#tarcet.png")
        :align(display.LEFT_CENTER, display.cx-50, display.top-80)
        :addTo(self)

    display.newSprite("#tarcet_part.png")
        :align(display.LEFT_CENTER, display.cx+130, display.top-78)
        :addTo(self)

    self.highTargetLabel=display.newBMFontLabel({
        text=tostring(self.target),
        font="font/earth32.fnt",
    })
        :align(display.CENTER, display.cx+200, display.top-76)
        :addTo(self)

----current score
    display.newSprite("#score_now.png")
        :align(display.CENTER, display.cx, display.top-150)
        :addTo(self)
    
    self.curSorceLabel=display.newBMFontLabel({
        text=tostring(self.curScore),
        font="font/earth48.fnt",
    })
        :align(display.CENTER, display.cx, display.top-150)
        :addTo(self)

----选中水果分数
    self.activeScoreLabel=display.newTTFLabel({text="",size=30})
        :pos(display.width/2,120)
        :addTo(self)
    
    self.activeScoreLabel:setColor(display.COLOR_WHITE)

----声音
    local cnt=1
    sound=display.newSprite("#sound.png")
    sound:align(display.CENTER, display.right - 60, display.top - 30)
    sound:addTo(self)
    sound:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name=="ended" then 
            if cnt%2==1 then 
                --print("touch sound")
                audio.stopBGM()
                cnt=cnt+1
            else
                audio.playBGMSync("music/mainbg.ogg", true)
                cnt=cnt+1
            end
        end
        if event.name=="began" then 
            return true
        end
    end)
    sound:setTouchEnabled(true)
end
---------初始化水果矩阵
function playerScene:initMatrix()
    self.activeTable={}---保存高亮的水果
    self.matrix={}     ---水果矩阵
    for x=1,self.xCount do
        self.matrix[x]={}
    end
    for x=1,self.xCount do
        for y=1,self.yCount do
            self:createDropFruit(x,y)
        end
    end
end
----------创建水果
function playerScene:createDropFruit(x,y,fruitIndex)
    -- print("x,y",x,y)
    -- for k,v in pairs(self.matrix)do
    --     print(k,v)
    -- end
    local newFruit=fruitClass.new(x,y,fruitIndex)
    local endPosition=self:positionOfFruit(x,y)
    local startPosition=cc.p(endPosition.x,endPosition.y+display.height)
    newFruit:setPosition(startPosition)
    local speed=startPosition.y/(2*display.height)
    newFruit:runAction(cc.MoveTo:create(1, endPosition))
    --使用二维数组
    self.matrix[x][y]=newFruit
    -- print("newfruit index",newFruit.fruitIndex)
    -- print(newFruit)
    self:addChild(newFruit)
    local cnt=1
    newFruit:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name=="ended" then
            --local cnt=1
            if newFruit.isActive then 
                if cnt==1 then 
                    self:inActive()
                else 
                    self.activeScore=(5*2+10*(cnt-1))*cnt/2
                    self.curScore=self.curScore+self.activeScore
                    self.curSorceLabel:setString(tostring(self.curScore))
                    ---进度条的百分比是百分制
                    self.sliderVal=self.curScore/self.target*100
                    if self.sliderVal >100 then 
                    -----跳转到通关页面                       
                        self:removeActiveFruit()
                        self:stopAllActions()
                        self:switchFinishLayer()
                    --end   
                    else
                        self.slider:setPercent(self.sliderVal)
                        self:removeActiveFruit()
                        self:playBrokenBgm(cnt)
                        self:dropFruit()
                        if self:checkMatrix()==false then 
                            for x=1,self.xCount do
                                for y=1,self.yCount do
                                    self.matrix[x][y]:removeFromParent()
                                end
                            end
                            self.matrix={}
                            self:initMatrix()
                        end
                    end
                end 
            else
                self:inActive()
                cnt=self:activeNeighbor(newFruit,cnt)
                if cnt==1 then 
                    newFruit:setActive(false)
                else 
                    audio.playEffectSync("music/itemSelect.ogg", false)
                end
                --print("cnt= ",cnt)         
            end
        end
        if event.name=="began" then
            return true
        end
    end)
    newFruit:setTouchEnabled(true)
    -- print("add newfruit ",newFruit.fruitIndex)
end
----取消高亮
function playerScene:inActive()
    for k, fruit in pairs(self.activeTable) do
        if (fruit) then
            fruit:setActive(false)
        end
    end
	self.activeTable = {}
end
------检查水果矩阵是否可消除
function playerScene:checkMatrix()
    for y=1,self.yCount-1 do
        for x=1,self.xCount-1 do
            if self.matrix[x][y].fruitIndex==self.matrix[x+1][y].fruitIndex or  self.matrix[x][y].fruitIndex==self.matrix[x][y+1].fruitIndex then 
                return true 
            end
        end
    end
    for x=1,self.xCount-1 do
        if self.matrix[x][8].fruitIndex==self.matrix[x+1][8].fruitIndex then 
            return true
        end
    end
    for y=1,self.yCount-1 do
        if self.matrix[8][y].fruitIndex==self.matrix[8][y+1].fruitIndex then 
            return true
        end
    end
    return false 
end
----水果的坐标：从矩阵坐标转化为屏幕上的坐标
function playerScene:positionOfFruit(x,y)
    local px=self.matrixLBX+(fruitClass.getWidth()+self.fruitGap)*(x-1)+fruitClass.getWidth()/2
    local py=self.matrixLBY+(fruitClass.getWidth()+self.fruitGap)*(y-1)+fruitClass.getWidth()/2

    return cc.p(px,py)
end
----跳转到通关层
function playerScene:switchFinishLayer()
    audio.playEffectSync("music/wow.ogg", false)
    local resultLayer=display.newColorLayer(cc.c4b(0, 0, 0, 100))
    resultLayer:addTo(self)

    --设置层吞没触摸事件
    resultLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name=="began" then 
            return true 
        end
    end)

    local listener=cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,event)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN)

    local eventDispatcher=resultLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, resultLayer)
    resultLayer:setTouchEnabled(true)
    ----------------------------------------------------------------------
    local label1=ccui.Text:create("恭喜过关！","",60)
    label1:setPosition(display.cx-100, display.cy+200)
    label1:addTo(resultLayer)
    local label2=ccui.Text:create("最高得分：","",60)
    label2:setPosition(display.cx-100, display.cy+100)
    label2:addTo(resultLayer)
    local label3=ccui.Text:create(tostring(self.curScore),"",60)
    label3:setPosition(display.cx+100, display.cy+100)
    label3:addTo(resultLayer)
    --display.pause()
    ----创建start按钮
    local btn=ccui.Button:create("startBtn_N.png","startBtn_S.png","startBtn_N.png",1)
    btn:addTo(resultLayer)
    btn:setPosition(display.cx, display.cy-80) 
    btn:addTouchEventListener(function (ref,eventType)
        if cc.EventCode.ENDED==eventType then
            audio.playEffectSync("music/btnStart.ogg", false)                          
            local newSceneClass=require("app.scenes.MainScene")
            local newScene=newSceneClass:new()
            display.replaceScene(newScene, "turnOffTiles", 0.3)
        end
    end)
    local userDefault=cc.UserDefault:getInstance()
    local ret=userDefault:getStringForKey("HighScore")
    self.stage=self.stage+1
    userDefault:setStringForKey("stage", tostring(self.stage))
    if tonumber(ret) < self.curScore then 
        userDefault:setStringForKey("HighScore", tostring(self.curScore))
    end
end

function playerScene:activeNeighbor(fruit,cnt)
    if fruit.isActive==false then 
        fruit:setActive(true)
		table.insert(self.activeTable, fruit)
	end
    -- for i=1,self.xCount do
    --     for j=1,self.yCount do
    --         print("matrix[i][j]",self.matrix[i][j])
    --     end
    -- end
    --print("fruit.x,fruit.y".fruit.x,fruit.y)

    --递归遍历左边的水果
    if fruit.x-1>=1 then 
        local left=self.matrix[fruit.x-1][fruit.y]
        if left.isActive==false and left.fruitIndex==fruit.fruitIndex then 
            cnt=cnt+1
            left:setActive(true)
            table.insert(self.activeTable,left)
            cnt=self:activeNeighbor(left,cnt)
        end
    end
    --递归遍历右边的水果
    if fruit.x+1<=self.xCount then 
        local right=self.matrix[fruit.x+1][fruit.y]
        if right.isActive==false and right.fruitIndex==fruit.fruitIndex then 
            cnt=cnt+1
            right:setActive(true)
            table.insert(self.activeTable,right)
            cnt=self:activeNeighbor(right,cnt)
        end
    end
    --递归遍历下边的水果
    if fruit.y-1>=1 then 
        local down=self.matrix[fruit.x][fruit.y-1]
        if down.isActive==false and down.fruitIndex==fruit.fruitIndex then 
            cnt=cnt+1
            down:setActive(true)
            table.insert(self.activeTable,down)
            cnt=self:activeNeighbor(down,cnt)
        end
    end
    --递归遍历上边的水果
    if fruit.y+1<=self.yCount then 
        local up=self.matrix[fruit.x][fruit.y+1]
        if up.isActive==false and up.fruitIndex==fruit.fruitIndex then 
            cnt=cnt+1
            up:setActive(true)
            table.insert(self.activeTable,up)
            cnt=self:activeNeighbor(up,cnt)
        end
    end
    return cnt
end
----移除高亮的水果
function playerScene:removeActiveFruit()
    --print("maxn",table.maxn(self.activeTable))
    for k,fruit in pairs(self.activeTable) do
        if fruit then
            self:playBomEffect(fruit.x,fruit.y)
            local sprite=display.newSprite("circle.png")
            sprite:addTo(self)
            sprite:setPosition(self:positionOfFruit(fruit.x,fruit.y))
            local action=cc.ScaleTo:create(0.1,1.01)
            sprite:runAction(action)
            sprite:performWithDelay(function()
                sprite:removeFromParent()
            end, 0.1)
            self.matrix[fruit.x][fruit.y]=nil
            fruit:removeFromParent()
        end
    end
    self.activeTable={}
end
----掉落水果
function playerScene:dropFruit()
    local emptyInfo={}
    for x=1,self.xCount do
        local emptyFruit=0---记录每一列的空格数
        for y=1,self.yCount do
            local tmp=self.matrix[x][y]
            if tmp==nil then 
                emptyFruit=emptyFruit+1
            else
                if emptyFruit>0 then 
                    newY=y-emptyFruit
                    self.matrix[x][newY]=tmp
                    tmp.y=newY
                    --print("x,y",x,y)
                    --print("tmp.x,tmp.y,tmp.index",tmp.x,tmp.y,tmp.fruitIndex)
                    self.matrix[x][y]=nil
                    --print("tmp",tmp)
                    local endPosition=self:positionOfFruit(x,newY)
                    --print("endposition.x,enposition.y",endPosition.x,endPosition.y)
                    tmp:stopAllActions()
                    tmp:runAction(cc.MoveTo:create(0.3, endPosition))
                end
            end
        end
        emptyInfo[x]=emptyFruit--记录每一列的空格个数
    end
    --print("emptyInfo.size",table.maxn(emptyInfo))
    for x=1,self.xCount do
        for y=self.yCount-emptyInfo[x]+1,self.yCount do
            self:createDropFruit(x, y)
        end
    end
end

function playerScene:playBrokenBgm(cnt)
    audio.playEffectSync("music/broken"..tostring(cnt)..".ogg", false)
    audio.playEffectSync("music/effectBom.ogg", false)
end

function playerScene:playBomEffect(x,y)
    local effect=cc.ParticleSystemQuad:create("stars.plist")
    effect:setPosition(self:positionOfFruit(x,y))
    effect:addTo(self)
end

function playerScene:onEnter()
end

function playerScene:onExit()
end


return playerScene
