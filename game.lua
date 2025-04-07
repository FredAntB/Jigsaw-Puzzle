local graphics = require( "graphics" )
local composer = require( "composer" )
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local CW = display.contentWidth
local CH = display.contentHeight

local sheetW = 525
local sheetH = 750

local puzzle = "./Assets/puzzle.png"

-- Load the image of the jigsaw piece
function loadImages(cuts, sheet)
    local pieceW = sheetW / cuts
    local pieceH = sheetH / cuts

    local board = {}
    for i = 1, cuts do
        board[i] = {}
        for j = 1, cuts do
            piece_number = cuts*(i - 1) + j
            piece = display.newImageRect(sheet, piece_number, (i - 1) * pieceW, (j - 1) * pieceH)
            piece.anchorX = 0; piece.anchorY = 0
            board[i][j] = piece
        end
    end
    -- group:insert(board)
    return board
end

-- shuffle the images for the jigsaw
function shuffleBoard(cuts, board, shuffles)
    local empty_location = {cuts, cuts}
    repeat
        local x = math.random(-1, 1)
        local y = math.random(-1, 1)
        local first_axis = math.random(1, 2)

        if first_axis == 1 then
            if empty_location[1] + x < cuts + 1 and empty_location[1] + x > 0 then
                local temp = board[empty_location[1] + x][empty_location[2]]
                board[empty_location[1] + x][empty_location[2]] = board[empty_location[1]][empty_location[2]]
                board[empty_location[1]][empty_location[2]] = temp
            end
            
            if empty_location[2] + y < cuts + 1 and empty_location[2] + y > 0 then
                local temp = board[empty_location[1]][empty_location[2] + y]
                board[empty_location[1]][empty_location[2] + y] = board[empty_location[1]][empty_location[2]]
                board[empty_location[1]][empty_location[2]] = temp
            end
        elseif first_axis == 2 then
            if empty_location[2] + y < cuts + 1 and empty_location[2] + y > 0 then
                local temp = board[empty_location[1]][empty_location[2] + y]
                board[empty_location[1]][empty_location[2] + y] = board[empty_location[1]][empty_location[2]]
                board[empty_location[1]][empty_location[2]] = temp
            end
            
            if empty_location[1] + x < cuts + 1 and empty_location[1] + x > 0 then
                local temp = board[empty_location[1] + x][empty_location[2]]
                board[empty_location[1] + x][empty_location[2]] = board[empty_location[1]][empty_location[2]]
                board[empty_location[1]][empty_location[2]] = temp
            end
        end
        
        shuffles = shuffles - 1
    until shuffles > 0
    return {board, empty_location}
end

-- Crepate the board
function createBoard(cuts, sceneGroup)
    local options =
    {
        width = sheetW / cuts,
        height = sheetH / cuts,
        numFrames = cuts * cuts,  --number of frames in the sheet
        sheetContentWidth = sheetW,  --width of original 1x size of entire sheet
        sheetContentHeight = sheetH  --height of original 1x size of entire sheet
    }
    sheet = graphics.newImageSheet( puzzle, options )

    -- local board = loadImages(cuts, sheet)
    piece = display.newImageRect(sheet, 1, 0, 0, sheetW / cuts, sheetH / cuts)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    print("we are going to do " .. event.params.cuts)

    createBoard(event.params.cuts, sceneGroup)
end
 
 
-- show()
function scene:show( event )
    
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end

 
-- hide()
function scene:hide( event )
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
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