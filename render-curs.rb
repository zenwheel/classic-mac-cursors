#!/usr/bin/env ruby

require 'pathname'

# 1) find/generate file with 'CURS' resources (ResEdit)
# 2) use MPW's DeRez to decompile the resources
# 3) run this script on the DeRez output

def render(name, data)
	puts "Saving #{name}.png..."
	x = 0
	y = 0
	mask = ''
	data = data.strip.gsub(/[\s\$"]/, '') # clean up formatting
	data = data.sub(/.{4}$/) { |m|
		y = m.to_i(16)
		''
	}
	data = data.sub(/.{4}$/) { |m|
		x = m.to_i(16)
		''
	}
	data = data.sub(/.{64}$/) { |m|
		mask = m
		''
	}

	puts "Hotspot = #{x}, #{y}"
	config = "16 #{x} #{y} #{name}.png"
	File.open("cursors/#{name}.config", 'w') { |file| file.puts(config)  }

	bits = data.chars.map { |c| "%04b" % c.to_i(16) }
	mask_bits = mask.chars.map { |c| "%04b" % c.to_i(16) }

	#puts "Cursor:"
	#bits.each_slice(4) do |s|
	#	puts s.join('')
	#end
	#puts "\nMask:"
	#mask_bits.each_slice(4) do |s|
	#	puts s.join('')
	#end

	bits_string = bits.join('')
	mask_bits_string = mask_bits.join('')

	blacks = ''
	whites = ''
	command = "convert -size 16x16 xc:none"
	bits_string.chars.each_with_index do |c, i|
		m = mask_bits_string.chars[i]
		x = i % 16
		y = i / 16
		if c == '1' then
			blacks += " -draw 'point #{x},#{y}'"
		elsif m == '1' then
			whites += " -draw 'point #{x},#{y}'"
		end
	end

	command += " -fill white"
	command += whites
	command += " -fill black"
	command += blacks

	command += " \"cursors/#{name}.png\""
	system command
end

def convert(file)
	return if !File.exist?(file)
	puts "Loading #{file}..."
	Pathname.new("cursors").mkpath

	content = File.read(file)
	content = content.encode('UTF-8', 'UTF-8', :invalid => :replace) # fix old mac encoding
	content = content.gsub(/\r\n?/, "\n") # normalize line endings
	content = content.gsub(/\s*\/\*.*\*\//, '') # strip comments
	#puts content
	content.scan(/data\s+'CURS'\s+\((\-?\d+),\s+\"([^\"]*)\"[^\)]*\)\s+{([^}]*)};/) { |id, name, data| render(name, data) }
end

ARGV.each { |file| convert(file) }
