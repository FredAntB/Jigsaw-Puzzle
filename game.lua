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

local hasEventListener = false
local gameOverText = nil

local board = {}
local cuts = 0
local empty_location = {}

-- find the piece containing the image that was touched based on it's x, y values
function findRowAndColByCoordinates(x, y)
    -- Calculate the width and height of each piece
    local pieceW = (sheetW / cuts) * scaleX
    local pieceH = (sheetH / cuts) * scaleY
    
    -- Calculate the row and column based on the x and y coordinates
    local column = math.floor((x + offsetX) / pieceW) + 1
    local row = math.floor((y + offsetY) / pieceH) + 1

    -- Return the row and column as a table
    return { row = row, column = column }
end

-- verify if a piece is adjacent to the empty space
function isAdjacent(piece)
    return (piece.row == empty_location[1] and math.abs(piece.column - empty_location[2]) == 1) or
           (piece.column == empty_location[2] and math.abs(piece.row - empty_location[1]) == 1)
end

-- verify if the game is over
function verifyGameOver()
    local isGameOver = true
    for i = 1, cuts do
        for j = 1, cuts do
            local piece_number = cuts * (i - 1) + j
            print("Expected piece_number: " .. piece_number .. ", Actual ID: " .. board[i][j].id)
            if board[i][j].id ~= piece_number then
                isGameOver = false
                break
            end
        end
        if not isGameOver then break end
    end

    return isGameOver
end

-- logic for piece movement
function movePiece(self, event)
    if event.phase == "began" then
        -- Retrieve the corresponding piece to the touched image
        local rowcol = findRowAndColByCoordinates(self.x, self.y)
        local touched_piece = board[rowcol.row][rowcol.column]

        if isAdjacent(touched_piece) then
            -- Swap the piece with the empty space
            local empty_piece = board[empty_location[1]][empty_location[2]]

            -- Swap positions visually
            local tempX, tempY = touched_piece.image.x, touched_piece.image.y
            touched_piece.image.x, touched_piece.image.y = empty_piece.image.x, empty_piece.image.y
            empty_piece.image.x, empty_piece.image.y = tempX, tempY

            -- Update the board table
            board[empty_location[1]][empty_location[2]] = touched_piece
            board[touched_piece.row][touched_piece.column] = empty_piece

            -- Update the row and column values
            local tempRow, tempCol = touched_piece.row, touched_piece.column
            touched_piece.row, touched_piece.column = empty_location[1], empty_location[2]
            empty_piece.row, empty_piece.column = tempRow, tempCol

            -- Update the empty location
            empty_location = {tempRow, tempCol}
        end
        
        if verifyGameOver() then
            gameOverText.alpha = 1

            removeEventListeners()
        end
    end
    return true
end

-- Load the image of the jigsaw piece
function loadImages(sheet, sceneGroup)
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
function shuffleBoard(shuffles)
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
            local tempRow, tempCol = adjacent_piece.row, adjacent_piece.column
            board[empty_location[1]][empty_location[2]] = adjacent_piece
            adjacent_piece.row = empty_location[1]
            adjacent_piece.column = empty_location[2]

            board[newX][newY] = empty_piece
            empty_piece.row = tempRow
            empty_piece.column = tempCol

            -- Update the empty location
            empty_location = {tempRow, tempCol}

            -- Decrement the shuffle counter
            shuffles = shuffles - 1
        end
    end
    return {board, empty_location}
end

-- Crepate the board
function createBoard(sceneGroup)
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
    
    loadImages(sheet, sceneGroup)
    
    shuffleBoard(cuts * cuts * 2)

    gameOverText = display.newText(sceneGroup, "You Win!", CW / 2, CH / 4 - 90, native.systemFont, 40)
    gameOverText:setFillColor(0.4, 0.1, 0.6)
    gameOverText.alpha = 0
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
    hasEventListener = true
end

-- remove event listeners to the pieces
function removeEventListeners()
    for i = 1, #board do
        for j = 1, #board[i] do
            local piece = board[i][j].image
            piece.touch = movePiece
            piece:removeEventListener("touch", piece)
        end
    end
    hasEventListener = false
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    cuts = event.params.cuts

    local bg = display.newImageRect(sceneGroup, bg_img, display.contentWidth, display.contentHeight)
    bg.anchorX = 0; bg.anchorY = 0

    createBoard(sceneGroup)
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
        if hasEventListener then
            removeEventListeners()
        end
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