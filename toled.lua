

tOled = {
	locked	= false
	, text	= ""
}

function tOled.new( config )
	local o = {}
	local disp = {}
	o.config = config
	setmetatable(o, { __index = tOled })
	return o
end


function tOled:init()
	if self.config.type == 2 then
		spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
		-- we won't be using the HSPI /CS line, so disable it again
		gpio.mode(8, gpio.INPUT, gpio.PULLUP)
		self.disp = u8g.ssd1306_128x64_hw_spi( self.config.spi.cs, self.config.spi.dc, self.config.spi.res)
	else
		i2c.setup( 0, self.config.i2c.sda, self.config.i2c.scl, i2c.SLOW )
		self.disp = u8g.ssd1306_128x64_i2c( self.config.i2c.sla )
	end

	self.disp:setFont( u8g.font_6x10 )
	self.disp:setFontRefHeightExtendedText()
	self.disp:setDefaultForegroundColor()
	self.disp:setFontPosTop()

	-- Show boot message
	self:_splash()
end

function tOled:_splash()
	self:update( "Initialising..." )
end

function tOled:lock()
	self.locked = true
end

function tOled:unlock()
	self.locked = false
end

function tOled:isLocked()
	return self.locked
end

function tOled:update( text )
	self.text = text
	self:_display()
end

function tOled:_draw()
	self.disp:drawStr( 0, 0, self.text )
end

function tOled:_display()
	self.disp:firstPage()
	repeat
		self:_draw()
	until self.disp:nextPage() == false
end
