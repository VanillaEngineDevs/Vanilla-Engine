function uitextflarge(text,x,y,limit,align,hovered,r,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "center"
	local hovered = hovered or false
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0

	if not hovered then graphics.setColor(0,0,0) else graphics.setColor(1,1,1) end
	for i = -6, 6 do
		for j = -6, 6 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
	if not hovered then graphics.setColor(1,1,1) else graphics.setColor(0,0,0) end
	love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end
function uitextf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "left"
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	for i = -2, 2 do
		for j = -2, 2 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end
function uitext(text,x,y,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end
function uitextColored(text,x,y,r,col1,col2,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	local col1 = col1 or {0,0,0,1}
	local col2 = col2 or {1,1,1,1}
	graphics.setColor(col1[1],col1[2],col1[3],col1[4])
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(col2[1],col2[2],col2[3],col2[4])
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end
function uitextfColored(text,x,y,limit,align,col1,col2,r,sx,sy,ox,oy,kx,ky)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local limit = limit or 750
	local align = align or "center"
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(col1[1],col1[2],col1[3],col1[4])
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.printf(text,x+i,y+j,limit,align,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(col2[1],col2[2],col2[3],col2[4])
	love.graphics.printf(text,x,y,limit,align,r,sx,sy,ox,oy,kx,ky)
end

function borderedText(text,x,y,r,sx,sy,ox,oy,kx,ky,alpha)
	local x = x or 0
	local y = y or 0
	local r = r or 0
	local sx = sx or 1
	local sy = sy or 1
	local ox = ox or 0
	local oy = oy or 0
	local kx = kx or 0
	local ky = ky or 0
	graphics.setColor(0,0,0, alpha or 1)
	for i = -1, 1 do
		for j = -1, 1 do
			love.graphics.print(text,x+i,y+j,r,sx,sy,ox,oy,kx,ky)
		end
	end
	graphics.setColor(1,1,1, alpha or 1)
	love.graphics.print(text,x,y,r,sx,sy,ox,oy,kx,ky)
end