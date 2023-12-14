lg = love.graphics
lk = love.keyboard

DURATION_REAL = false
PIANO_WIDTH = 40
PIANO_HEIGHT = 120

function noteToTime(notes)
	return notes * 4 * 60 / BPM
end

function timeToNotes(time)
	return time / 4 / 60 * BPM
end

function note7to12(note, sharp)
	--[[if note <= 3 then
		return note * 2 - 1 + sharp
	else
		return note * 2 - 2 + sharp
	end]]
	return note * 2 - (note <= 3 and 1 or 2) + sharp
end

function generateSound(time, frequency)
	soundData = love.sound.newSoundData(time * SAMPLE_SPEC, SAMPLE_SPEC, 16, 1)
	for i = 0, SAMPLE_SPEC * time - 1 do
        value = math.min(
			(1 - i / (SAMPLE_SPEC * time)),
			math.min(8 * i / (SAMPLE_SPEC * time), 1)
		)
		* 
		math.sin(i * math.pi * 2 / SAMPLE_SPEC * frequency)
		
		power = 2
		value = value >= 0 and math.pow(value, power) or -math.pow(-value, power)
		--value = 10*value
		
		soundData:setSample(i, value)
	end
	local source = love.audio.newSource(soundData, "stream")
	love.audio.play(source)
	
	return source
end

function noteToChar(note)
	if note == 0 then
		return 'r'
	elseif note == 1 then
		return 'c'
	elseif note == 2 then
		return 'd'
	elseif note == 3 then
		return 'e'
	elseif note == 4 then
		return 'f'
	elseif note == 5 then
		return 'g'
	elseif note == 6 then
		return 'a'
	elseif note == 7 then
		return 'b'
	end
end

function charToNote(char)
	if char == 'c' then
		return 1
	elseif char == 'd' then
		return 2
	elseif char == 'e' then
		return 3
	elseif char == 'f' then
		return 4
	elseif char == 'g' then
		return 5
	elseif char == 'a' then
		return 6
	elseif char == 'b' then
		return 7
		
	elseif char == 'r' then
		return 0
	
	elseif char == '&d' then
		return 1.5
	elseif char == '&e' then
		return 2.5
	elseif char == '&g' then
		return 4.5
	elseif char == '&a' then
		return 5.5
	elseif char == '&b' then
		return 6.5
	
	elseif char == '#c' then
		return 1.5
	elseif char == '#d' then
		return 2.5
	elseif char == '#f' then
		return 4.5
	elseif char == '#g' then
		return 5.5
	elseif char == '#a' then
		return 6.5
		
	else
		return -1
	end
end

function noteToFrequency(nite, sharp, octave)
	--return 16.35 * math.pow(2, (note7to12(note, sharp)-1) / 12 + (octave))
	return 2 * 16.35 * math.pow(2, (note7to12(note, sharp)-1) / 12 + (octave))
	--return 4 * 16.35 * math.pow(2, (note7to12(note, sharp)-1) / 12 + (octave))
end

function love.load()
	love.graphics.setBackgroundColor(1,1,1)
	
	fileStart = 'BEGIN:IMELODY\r\nVERSION:1.2\r\nFORMAT:CLASS1.0\r\n'
	fileBeatStart = 'BEAT:'
	fileBeatEnd = '\r\n'
	fileMelodyStart = 'MELODY:'
	fileMelodyEnd = '\r\nEND:IMELODY'
	
	-- whole note		𝅝
	-- half note		𝅗𝅥
	-- eighth note		𝅘𝅥𝅮
	-- sixteenth note	𝅘𝅥𝅯
	-- thirty-second note	𝅘𝅥𝅰
	
	-- BPM=60 one beat is 1 second so a whole note in 4/4 time would be 4 seconds long.
	-- BPM=120 (typical for a march) one beat is 1/2 a second so a whole note in 4/4 time would be 2 seconds long.
	-- BPM=80 one beat is 3/4 of a second so a whole note in 4/4 time would be 3 seconds long.
	
	notes = ''
	
	octave = 4
	
	note = -1
	sharp = ''
	short = false
	
	duration = 4
	BPM = 120
	
	if arg[2] then
		local file = io.open(arg[2], 'r')
		notes = file:read('*all')
		file:close()
		
		notes = string.gsub(notes, fileStart, "")
		notes = string.gsub(notes, fileBeatStart, "")
		
		for i = 1, #notes do
			if notes:sub(i,i) == '\n' then
				BPM = tonumber(notes:sub(1,i))
				notes = notes:sub(i, -1)
				break
			end
		end
		
		notes = string.gsub(notes, fileMelodyStart, "")
		notes = string.gsub(notes, fileMelodyEnd, "")
		notes = string.gsub(notes, fileBeatEnd, "")
	end
	
	timeLastNote = love.timer.getTime()
	
	lg.setLineWidth(3)
	width, height = lg.getDimensions()
	
	--SAMPLE_SPEC = 44100
	SAMPLE_SPEC = 48000
	--generateSound(noteToTime(1), 440)
end

function love.resize()
	width, height = lg.getDimensions()
end

function love.keypressed(key, scancode, isrepeat)
	-- '#' is right, 'b' is left
	if note == -1 then
		if key == 'z' then -- c
			note = 1
			sharp = ''
		elseif key == 'x' then -- d
			note = 2
			sharp = ''
		elseif key == 'c' then -- e
			note = 3
			sharp = ''
		elseif key == 'v' then -- f
			note = 4
			sharp = ''
		elseif key == 'b' then -- g
			note = 5
			sharp = ''
		elseif key == 'n' then -- a
			note = 6
			sharp = ''
		elseif key == 'm' then -- b
			note = 7
			sharp = ''
			
		elseif key == 'p' then -- delay
			note = 0
			sharp = ''
			short = false
		elseif key == '[' then -- short delay
			note = 0
			sharp = ''
			short = true
		
		elseif key == 's' then -- c#
			note = 1
			sharp = '#'
		elseif key == 'd' then -- d#
			note = 2
			sharp = '#'
		elseif key == 'g' then -- f#
			note = 4
			sharp = '#'
		elseif key == 'h' then -- g#
			note = 5
			sharp = '#'
		elseif key == 'j' then -- a#
			note = 6
			sharp = '#'
		else
			note = -1
			sharp = ''
		end
		
		if note ~= -1 then
			local mySharp = 0
			if sharp == '#' then
				mySharp = 1
			end
			
			local soundDuration = noteToTime(1)
			if not DURATION_REAL then
				soundDuration = noteToTime(math.pow(2, -duration))
			end
			
			if note > 0 then
				soundSource = generateSound(soundDuration, noteToFrequency(note, mySharp, octave))
				--print(noteToFrequency(note, mySharp, octave))
			end
			
			timeLastNote = love.timer.getTime()
		end
	end
	
	if key == 'return' then
		local file = io.open('output.imy', 'w')
		file:write(
			fileStart .. 
			fileBeatStart .. BPM .. fileBeatEnd .. 
			fileMelodyStart .. string.gsub(notes, "%s+", "") .. fileMelodyEnd
		)
		file:close()
	
	elseif key == 'backspace' then
		local success = false
		for i=#notes-1, 1, -1 do
			if notes:sub(i,i) == ' ' then
				notes = notes:sub(1, i)
				success = true
				break
			end
		end
		if not success then
			notes = ''
		end
	elseif key == 'down' then
		duration = math.min(5, duration + 1)
	elseif key == 'up' then
		duration = math.max(0, duration - 1)
	
	elseif key == 'right' then
		octave = math.min(7, octave + 1)
	elseif key == 'left' then
		octave = math.max(4, octave - 1)
	
	elseif key == 'space' or key == '0' then
		local time = 120
		local soundDataSize = time * SAMPLE_SPEC
		local soundData = love.sound.newSoundData(soundDataSize, SAMPLE_SPEC, 16, 1)
		
		soundCounter = 0
		
		local i = 1
		if key == '0' then
			i = math.max(1, #notes - 4*12)
		end
		while i < #notes do
			local success = true
			
			tryOctave = notes:sub(i,i)
			--print('tryOctave: ' .. tryOctave)
			if tryOctave == '*' then
				i = i + 1
				octave = tonumber(notes:sub(i,i))
				i = i + 1
			else
				octave = 4
			end
			
			trySingleNote = charToNote(notes:sub(i,i))
			--print('trySingleNote: ' .. trySingleNote)
			if trySingleNote ~= -1 then
				note = trySingleNote
				sharp = ''
				i = i + 1
			else
				trySharpNote = charToNote(notes:sub(i,i+1))
				--print('trySharpNote: ' .. trySharpNote)
				if trySharpNote ~= -1 then
					note = math.floor(trySharpNote)
					sharp = '#'
					i = i + 2
				else
					--error('Can\'t play note: ' .. notes:sub(i,i+1))
					success = false
				end
			end
			
			if success then
				--print('duration: ' .. notes:sub(i,i))
				duration = tonumber(notes:sub(i,i))
				i = i + 1
				
				--print('space: ' .. notes:sub(i,i))
				if notes:sub(i,i) == ' ' then
					i = i + 1
				end
				
				local mySharp = 0
				if sharp == '#' then
					mySharp = 1
				end
				local frequency = noteToFrequency(note, mySharp, octave)
				local noteDuration = noteToTime(math.pow(2, -duration))
				
				if note > 0 then
					for j = 0, SAMPLE_SPEC * noteDuration - 1 do
						if j+soundCounter < soundDataSize then
							value = (
								math.min(
									math.pow( (1 - j / (SAMPLE_SPEC * noteDuration)) , 0.5),
									math.pow( math.min(8 * j / (SAMPLE_SPEC * noteDuration), 1) , 0.5)
								)
								* 
								math.sin(j * math.pi * 2 / SAMPLE_SPEC * frequency)
							)
							
		                    --power = 1.5
		                    --value = value >= 0 and math.pow(value, power) or -math.pow(-value, power)
		                    
							soundData:setSample(j+soundCounter, value)
						else
							break
						end
					end
				end
				soundCounter = soundCounter + SAMPLE_SPEC * noteDuration
			else
				i = i + 1
			end
			
		end
		local source = love.audio.newSource(soundData, "stream")
		love.audio.play(source)
		
		note = -1
		sharp = ''
	
	elseif key == 'q' then
		love.event.quit()
	end
end

function love.keyreleased(key, scancode, isrepeat)
	if note ~= -1 then
		
		if DURATION_REAL then
			if note > 0 then
				soundSource:stop()
			end
			duration = math.min(5, math.floor(1 / timeToNotes(love.timer.getTime() - timeLastNote)))
		end
		
		noteChar = noteToChar(note)
		
		-- Standart octave is 4, no symbol. Visible as '1'
		-- Octave 5 is '*5', visible as '2'
		-- Octave 6 is '*6', visible as '3'
		-- Octave 7 is '*7', visible as '4'
		
		if octave == 4 or noteChar == 'r' then
			octaveString = ''
		elseif octave == 5 then
			octaveString = '*5'
		elseif octave == 6 then
			octaveString = '*6'
		elseif octave == 7 then
			octaveString = '*7'
		end
		
		myDuration = duration
		if short then
			myDuration = math.min(5, duration + 1)
			short = false
		end
		
		notes = notes .. octaveString .. sharp .. noteChar .. myDuration .. ' '
		
		note = -1
		sharp = ''
	end
end

function love.draw()
	lg.setColor(0,0,0)
	for i = 1, 7 do
		lg.rectangle("line", PIANO_WIDTH*i, height - PIANO_HEIGHT, PIANO_WIDTH-5, PIANO_HEIGHT)
		lg.print(noteToChar(i), PIANO_WIDTH*i + 5, height - PIANO_HEIGHT + 5)
	end
	for i = 1, 2 do
		lg.rectangle("line", PIANO_WIDTH*(i+.5), height - PIANO_HEIGHT*1.5, PIANO_WIDTH-5, PIANO_HEIGHT*.5)
	end
	for i = 4, 6 do
		lg.rectangle("line", PIANO_WIDTH*(i+.5), height - PIANO_HEIGHT*1.5, PIANO_WIDTH-5, PIANO_HEIGHT*.5)
	end
	
	if sharp ~= '#' then
		lg.rectangle("fill", PIANO_WIDTH*note, height - PIANO_HEIGHT, PIANO_WIDTH-5, PIANO_HEIGHT)
	else
		lg.rectangle("fill", PIANO_WIDTH*(note+.5), height - PIANO_HEIGHT*1.5, PIANO_WIDTH-5, PIANO_HEIGHT*.5)
	end
	
	lg.print('duration: ' .. duration .. ' octave: ' .. octave .. ' BPM: ' .. BPM, PIANO_WIDTH * 8, height - 20)
	
	lg.printf(notes, 0, 0, width)
end
