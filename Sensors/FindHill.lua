local sensorInfo = {
	name = "HillPositions",
	desc = "Return array of all hill positions.",
	author = "Fanda333",
	date = "2024-08-16",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = -1 -- actual, no caching

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end

-- speedups
local SpringGetGroundHeight = Spring.GetGroundHeight


function fillIn(map,startX,startY,label,width,height)
    stack = {{startX,startY}}
    while table.getn(stack) >= 1 do
        local popped = table.remove(stack)
        local x = popped[1]
        local y = popped[2]
        if x >= 1 and x < width and y >= 1 and y < height and map[x][y] == -1 then
            map[x][y] = label
            table.insert(stack,{x-1,y})
            table.insert(stack,{x+1,y})
            table.insert(stack,{x,y-1})
            table.insert(stack,{x,y+1})
        end
    end
end


-- @description
return function(hillHeight)
    local scale = 8
	local width = Game.mapSizeX/Game.squareSize
    local height = Game.mapSizeZ/Game.squareSize

    -- bitmap. hills area are -1. later we will fill them
    local map = {}
    for x = 1,width/scale do
        map[x] = {}
        for y = 1,height/scale do
            map[x][y] = SpringGetGroundHeight(x*scale*Game.squareSize,y*scale*Game.squareSize)==hillHeight and -1 or 0
        end
    end

    --fill in and count hills
    local hillCounter = 0
    for x = 1,width/scale do
        for y = 1,height/scale do
            if map[x][y] == -1 then
                hillCounter = hillCounter + 1
                fillIn(map,x,y,hillCounter,width/scale,height/scale)
            end
        end
    end

    local hillPositions = {}
    for x = 1,width/scale do
        for y = 1,height/scale do
            if map[x][y] ~= 0 then
                hillPositions[map[x][y]] = {x*scale*Game.squareSize,y*scale*Game.squareSize}
            end
        end
    end
    return hillPositions
end