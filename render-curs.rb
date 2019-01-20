#!/usr/bin/env ruby

require 'pathname'

$build_path = "#{__dir__}/build"

def render(name, data)
	puts "Saving #{name}.png..."
	hs_x = 0
	hs_y = 0
	mask = ''
	data = data.strip.gsub(/[\s\$"]/, '') # clean up formatting
	data = data.sub(/.{4}$/) { |m|
		hs_y = m.to_i(16)
		''
	}
	data = data.sub(/.{4}$/) { |m|
		hs_x = m.to_i(16)
		''
	}
	data = data.sub(/.{64}$/) { |m|
		mask = m
		''
	}

	#puts "Hotspot = #{hs_x}, #{hs_y}"

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

	command += " \"#{$build_path}/16x16/#{name}.png\""
	system command

	command = "convert \"#{$build_path}/16x16/#{name}.png\" -scale 32x32 \"#{$build_path}/32x32/#{name}.png\""
	system command

	command = "convert \"#{$build_path}/16x16/#{name}.png\" -scale 64x64 \"#{$build_path}/64x64/#{name}.png\""
	system command

	delay = ''
	delay = ' 30' if name =~ /-\d{2}$/
	config = "16 #{hs_x} #{hs_y} 16x16/#{name}.png#{delay}\n"
	config += "32 #{hs_x * 2} #{hs_y * 2} 32x32/#{name}.png#{delay}\n"
	config += "64 #{hs_x * 4} #{hs_y * 4} 64x64/#{name}.png#{delay}\n"
	File.open("#{$build_path}/#{name.sub /-\d{2}$/, ''}.config", 'a') { |file| file.puts(config)  }
end

def convert(file)
	return if !File.exist?(file)
	puts "Loading #{file}..."
	Pathname.new("#{$build_path}/16x16").mkpath
	Pathname.new("#{$build_path}/32x32").mkpath
	Pathname.new("#{$build_path}/64x64").mkpath

	content = File.read(file)
	content = content.encode('UTF-8', 'UTF-8', :invalid => :replace) # fix old mac encoding
	content = content.gsub(/\r\n?/, "\n") # normalize line endings
	content = content.gsub(/\s*\/\*.*\*\//, '') # strip comments
	#puts content
	content.scan(/data\s+'CURS'\s+\((\-?\d+),\s+\"([^\"]*)\"[^\)]*\)\s+{([^}]*)};/) { |id, name, data| render(name, data) }
end

ARGV.each { |file| convert(file) }
