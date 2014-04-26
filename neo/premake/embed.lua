--
-- Embed the Cg renderprogs into renderer/RenderProgs_embedded.cpp as static data buffers.
--

local function stripfile( fname )
	print( fname )

	local f = io.open( fname )
	local s = f:read( "*a" )
	f:close()

	-- strip tabs
	--s = s:gsub("[\t]", "")
	
	-- strip any CRs
	s = s:gsub("[\r]", "")
	
	-- strip out comments
	s = s:gsub("\n%-%-[^\n]*", "")
			
	-- escape backslashes
	s = s:gsub("\\", "\\\\")

	-- strip duplicate line feeds
	s = s:gsub("\n+", "\n")

	-- strip out leading comments
	s = s:gsub("^%-%-\n", "")

	-- escape line feeds
	s = s:gsub("\n", "\\n")
	
	-- escape double quote marks
	s = s:gsub("\"", "\\\"")
	
	return s
end

local function loadfile(fname)
	print(fname)

	local f = io.open(fname)
	local s = f:read("*a")
	f:close()
	
	-- escape line feeds
	--s = s:gsub("\n", "\n\"")
	
	-- escape double quote marks
	s = s:gsub("\"", "\\\"")
	
	return s
end


local function writeline(out, s, continues)
	out:write("\t\"")
	out:write(s)
	out:write(iif(continues, "\"\n", "\"},\n\n"))
end


local function writefile(out, fname, contents)
	local max = 1024

	--out:write("\t/* " .. fname .. " */\n")
	
	-- break up large strings to fit in Visual Studio's string length limit		
	local start = 1
	local len = contents:len()
	while start <= len do
		local n = len - start
		if n > max then n = max end
		local finish = start + n

		-- make sure I don't cut an escape sequence
		while contents:sub(finish, finish) == "\\" do
			finish = finish - 1
		end			

		writeline(out, contents:sub(start, finish), finish < len)
		start = finish + 1
	end		

	--out:write("\n")
end

local function writefilesimple( out, filename, contents )

	-- add some extra EOL so we don't break out of the loop too early
	contents = contents .. "\n"

	-- split at line ends and grab everything before
	for line in string.gmatch( contents, "([^\n]*)\n" ) do
		out:write( "\t\t\"" .. line .. "\\n\"\n" )
    end

	out:write( "\t\t\0\n\t},\n\t\n" )
	
end

function doembed()

	-- load the manifest of script files
	scripts = dofile( "../base/renderprogs/_manifest.lua" )
	
	local out = io.open("renderer/RenderProgs_embedded.h", "w+b")
	out:write("// Cg shaders, as static data buffers for release mode builds\n")
	out:write("// DO NOT EDIT - this file is autogenerated - see BUILD.txt\n")
	out:write("// To regenerate this file, run: premake4 embed\n\n")
	out:write("struct cgShaderDef_t\n{\n")
	out:write("\tconst char* name;\n");
	out:write("\tconst char* shaderText;\n");
	out:write("};\n\n");
	--out:write("extern const cgShaderDef_t cg_renderprogs[];\n")
	
	--out:close()
	out:write("static const cgShaderDef_t cg_renderprogs[] =\n{\n")
	
	-- out = io.open("renderer/RenderProgs_embedded.cpp", "w+b")
	-- out:write("// Cg shaders, as static data buffers for release mode builds \n")
	-- out:write("// DO NOT EDIT - this file is autogenerated - see BUILD.txt \n")
	-- out:write("// To regenerate this file, run: premake4 embed \n\n")
	-- out:write("#include \"RenderProgs_embedded.h\"\n\n")
	-- out:write("const cgShaderDef_t cg_renderprogs[] =\n")
	
	for i,filename in ipairs( scripts ) do
		print( filename )			
		--out:write("const char glsl_" .. fn .. "[] = {\n")
		out:write("\t{\n\t\t\"renderprogs/" .. filename .. "\",\n")
		
		local s = loadfile( "../base/renderprogs/" .. filename )
		writefilesimple( out, filename, s )
		
		--out:write("\t0}\n");
	end
	
	out:write( "\t{0, 0},\n\t\n};\n" );
	out:close()
end
