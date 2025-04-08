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

local scaleX = display.contentScaleX
local scaleY = display.contentScaleY

local offsetX = (CW - sheetW) / 8
local offsetY = (CH - sheetH) / 4

-- offsetX: -25.625 offsetY: -67.5

local bg_img = "./Assets/background.png"
local puzzle = "./Assets/puzzle.png"

local board = {}
local empty_location = {}

-- verify if a piece is adjacent to the empty space
local function isAdjacent(piece, empty_location)
    return (piece.row == empty_location[1] and math.abs(piece.column - empty_location[2]) == 1) or
           (piece.column == empty_location[2] and math.abs(piece.row - empty_location[1]) == 1)
end

-- logic for piece movement
function movePiece(self, event)
    if event.phase == "began" then
        if not isAdjacent(self, empty_location) then
            -- If the piece is not adjacent to the empty space, do nothing
            return
        end
    elseif event.phase == "ended" then
        -- Swap the piece with the empty space
        local empty_piece = board[empty_location[1]][empty_location[2]]
        local tempX, tempY = self.x, self.y
        self.x, self.y = empty_piece.image.x, empty_piece.image.y
        empty_piece.image.x, empty_piece.image.y = tempX, tempY

        -- Update the board table
        board[empty_location[1]][empty_location[2]] = self
        self.row, self.column = empty_location[1], empty_location[2]

        board[self.row][self.column] = empty_piece
        empty_piece.row, empty_piece.column = self.row, self.column

        -- Update the empty location
        empty_location = {self.row, self.column}
    end
    return true
end

-- Load the image of the jigsaw piece
function loadImages(cuts, sheet, sceneGroup)
    local pieceW = (sheetW / cuts) * scaleX
    local pieceH = (sheetH / cuts) * scaleY

    for i = 1, cuts do
        board[i] = {}
        for j = 1, cuts do
            piece_number = cuts*(i - 1) + j
            piece = display.newImageRect(sceneGroup, sheet, piece_number, pieceW, pieceH)
            piece.anchorX = 0; piece.anchorY = 0
            piece.x = (j - 1) * pieceW - offsetX; piece.y = (i - 1) * pieceH - offsetY
            board[i][j] = {
                id = piece_number,
                image = piece,
                row = i,
                column = j
            }
        end
    end
    -- return board
end

-- shuffle the images for the jigsaw
function shuffleBoard(cuts, shuffles)
    empty_location = {cuts, cuts}
    board[cuts][cuts].image.alpha = 0
    while shuffles > 0 do
        -- Generate a random direction to move the empty space
        local directions = {
            {x = 0, y = -1}, -- Up
            {x = 0, y = 1},  -- Down
            {x = -1, y = 0}, -- Left
            {x = 1, y = 0}   -- Right
        }
        local move = directions[math.random(1, #directions)]

        -- Calculate the new position of the empty space
        local newX = empty_location[1] + move.x
        local newY = empty_location[2] + move.y
        
        -- Check if the new position is within bounds
        if newX > 0 and newX <= cuts and newY > 0 and newY <= cuts then
            -- Swap the empty space with the adjacent piece
            local empty_piece = board[empty_location[1]][empty_location[2]]
            local adjacent_piece = board[newX][newY]

            -- Swap positions visually
            local tempX, tempY = empty_piece.image.x, empty_piece.image.y
            empty_piece.image.x, empty_piece.image.y = adjacent_piece.image.x, adjacent_piece.image.y
            adjacent_piece.image.x, adjacent_piece.image.y = tempX, tempY

            -- Swap positions in the board table
            board[empty_location[1]][empty_location[2]] = adjacent_piece
            adjacent_piece.row = empty_location[1]
            adjacent_piece.column = empty_location[2]

            board[newX][newY] = empty_piece
            empty_piece.row = newX
            empty_piece.column = newY

            -- Update the empty location
            empty_location = {newX, newY}

            -- Decrement the shuffle counter
            shuffles = shuffles - 1
        end
    end
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

    -- set background color for puzzle
    p_bg = display.newRect(sceneGroup, math.abs(offsetX), math.abs(offsetY), sheetW * scaleX, sheetH * scaleY)
    p_bg:setFillColor(0)
    p_bg.anchorX = 0; p_bg.anchorY = 0
    
    loadImages(cuts, sheet, sceneGroup)

    shuffleBoard(cuts, cuts * cuts * 2)
end

-- add event listeners to the pieces
function addEventListeners()
    for i = 1, #board do
        for j = 1, #board[i] do
            local piece = board[i][j].image
            piece.touch = movePiece
            piece:addEventListener("touch", piece)
        end
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    local bg = display.newImageRect(sceneGroup, bg_img, display.contentWidth, display.contentHeight)
    bg.anchorX = 0; bg.anchorY = 0

    createBoard(event.params.cuts, sceneGroup)
end
 
 
-- show()
function scene:show( event )
    
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        addEventListeners()
 
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