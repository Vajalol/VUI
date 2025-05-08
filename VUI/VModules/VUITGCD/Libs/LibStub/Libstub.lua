-- LibStub is a simple versioning stub meant for use in Libraries.
-- http://www.wowace.com/wiki/LibStub for more info
-- LibStub is hereby placed in the Public Domain
-- Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the stub is obsolete
if LibStub and LibStub.minor >= LIBSTUB_MINOR then return end

-- Create the library instance
LibStub = LibStub or {libs = {}, minors = {} }
_G[LIBSTUB_MAJOR] = LibStub
LibStub.minor = LIBSTUB_MINOR

-- LibStub:NewLibrary(major, minor)
-- major (string) - the name of the library
-- minor (number or string) - the version of the library
--
-- returns nil if a newer or same version of the library is already present
-- returns empty library object or old library object if upgrading
function LibStub:NewLibrary(major, minor)
	assert(type(major) == "string", "Bad argument #1 to `NewLibrary' (string expected)")
	minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")
	
	local oldminor = self.minors[major]
	if oldminor and oldminor >= minor then return nil end
	self.minors[major], self.libs[major] = minor, self.libs[major] or {}
	return self.libs[major], oldminor
end

-- LibStub:GetLibrary(major, [silent])
-- major (string) - the name of the library
-- silent (boolean) - if true, library is optional, silently return nil if its not found
--
-- throws an error if the library can not be found (except silent is set)
-- returns the library object if found
function LibStub:GetLibrary(major, silent)
	if not self.libs[major] and not silent then
		error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
	end
	return self.libs[major], self.minors[major]
end

-- LibStub:IterateLibraries()
-- 
-- Returns an iterator for the currently registered libraries
function LibStub:IterateLibraries() 
	return pairs(self.libs) 
end