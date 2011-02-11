-- Config file

--  Native LCD dimensions used in fullscreen mode
local lcd_width  = 1024
local lcd_height = 768

local C = {
  fullscreen  = 0,                 -- fullscreen mode
  width       = 800,               -- windowed width  (800+)
  height      = 600,               -- windowed height (600+)
}

-- Export config settings
config = C

-- Internal configuration

if C.fullscreen ~= 0 then
  C.width  = lcd_width
  C.height = lcd_height
end

if (C.width < 512 or C.height < 512) then
  LogMessage("Config file error: width and height should be > 512")
end

-- background texture dimension
if (C.width >= 1024 and C.height >= 1024) then
  C.quadsize    = 1024              
  C.persistence = 0.987
else 
  C.quadsize    = 512
  C.persistence = 0.975
end

C.title       = 1                 -- begin in title sequence
C.level       = 1

C.test        = 0
