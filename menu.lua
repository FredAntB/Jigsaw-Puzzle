local widget = require("widget")
local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
 
local CW = display.contentWidth
local CH = display.contentHeight

local background_img = "./Assets/background.png"

local flag = false -- can choose level
 
function startGame(event)
    if flag then
        composer.gotoScene("game", { effect= "zoomInOutFadeRotate", params = { cuts = (event.target.id + 2) } })
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local bg = display.newImageRect(sceneGroup, background_img, display.contentWidth, display.contentHeight)
    bg.anchorX = 0; bg.anchorY = 0

    title = display.newText(sceneGroup, "Jigsaw Puzzle", display.contentCenterX, 40, native.systemFont, 44 )
    title:setFillColor(0.4, 0.1, 0.6)

    level1 = widget.newButton({ 
        top=CH/2,
        label="Level 1", labelColor={ default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        shape = "roundedRect",
        width = 100,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4,
        id = 1,
        onRelease = startGame
    })
    level1.x = display.contentCenterX
    sceneGroup:insert(level1)
    
    level2 = widget.newButton({
        top=CH/2 + 50,
        label="Level 2", labelColor={ default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        shape = "roundedRect",
        width = 100,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4,
        id = 3,
        onRelease = startGame
    })
    level2.x = display.contentCenterX
    sceneGroup:insert(level2)
    
    level3 = widget.newButton({
        top=CH/2 + 100,
        label="Level 3", labelColor={ default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
        shape = "roundedRect",
        width = 100,
        height = 40,
        cornerRadius = 2,
        fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
        strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
        strokeWidth = 4,
        id = 13,
        onRelease = startGame
    })
    level3.x = display.contentCenterX
    sceneGroup:insert(level3)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        flag = true
    end
end

 
-- hide()
function scene:hide( event )
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        flag = false
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    title = nil
    level1 = nil
    level2 = nil
    level3 = nil
    bg = nil
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene