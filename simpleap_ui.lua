local black	= {0, 0, 0, 1}
local red	= {1, 0, 0, 1}
local green	= {0, 1, 0, 1}
local white	= {1, 1, 1, 1}
local cyan	= {0, 1, 1, 1}
local magenta	= {1, 0, 1, 1}
local yellow	= {1, 1, 0, 1}
local roboto	= loadFont(getXPlanePath() .. "Resources/fonts/Roboto-Regular.ttf")


function onMouseDown ( component , x , y , button , parentX , parentY )
    if x > 6 and y > 200 and x < 106 and y < 250 then
        set(ap_enabled, get(ap_enabled) == 1 and 0 or 1)
    end
end



function draw()
	local x, y = size[1]/2, size[2]/2
	--drawCircle(x , x , math.min(x, y)/2, true, magenta)
	--drawRectangle(x, y, x, y, cyan)
	--drawTriangle(x , y , 0 , y , x , 0 , yellow)
    drawRectangle(6, 200, 100, 50, get(ap_enabled) == 0 and red or green)
	drawText(roboto, 53, 220, get(ap_enabled) == 0 and "AP OFF" or "AP ON", 18, false, false, TEXT_ALIGN_CENTER, get(ap_enabled) == 0 and white or black)
end