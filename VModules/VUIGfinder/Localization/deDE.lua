-- VUIGfinder German Localization
local L = PGFinderLocals;
if not L then return end

-- Only overwrite non-default values
if GetLocale() ~= "deDE" then return end

-- German translations here (kept from original PGFinder)
L.OPTIONS_ROLE = "Anmelden als:";
L.OPTIONS_MIN_LEADER_SCORE = "Min. Anführer Punkte:";
L.OPTIONS_DUNGEON_DIFFICULTY = "Schwierigkeit";
L.OPTIONS_RAID_SELECT = "Raid auswählen";
L.OPTIONS_BLIZZARD_SEARCH_INFO = "Blizzard begrenzt alle Suchergebnisse auf etwa 100, damit du mehr Ergebnisse erhältst, sei so spezifisch wie möglich.\n\n Zum Beispiel füge die Schlüsselstufen hinzu, wähle 1 Dungeon / Raid aus, da dann nur nach dieser Aktivität gesucht wird. Diese Begrenzung existiert auch in der eigenen Version ohne Addons.";
L.OPTIONS_REFRESH_BUTTON_DISABLED = "Neue Aktualisierung verfügbar in: ";

L.SPEC_BLOOD = "Blut";
L.SPEC_FROST = "Frost";
L.SPEC_UNHOLY = "Unheilig";
L.SPEC_HAVOC = "Verwüstung";
L.SPEC_VENGENACE = "Rachsucht";
L.SPEC_BALANCE = "Gleichgewicht";
L.SPEC_FERAL = "Wildheit";
L.SPEC_GUARDIAN = "Wächter";
L.SPEC_RESTORATION = "Wiederherstellung";
L.SPEC_DEVASTATION = "Verwüstung";
L.SPEC_PRESERVATION = "Bewahrung";
L.SPEC_BEASTMASTERY = "Tierherrschaft";
L.SPEC_MARKSMANSHIP = "Treffsicherheit";
L.SPEC_SURVIVAL = "Überleben";
L.SPEC_ARCANE = "Arkan";
L.SPEC_FIRE = "Feuer";
L.SPEC_BREWMASTER = "Braumeister";
L.SPEC_WINDWALKER = "Windläufer";
L.SPEC_MISTWEAVER = "Nebelwirker";
L.SPEC_HOLY = "Heilig";
L.SPEC_PROTECTION = "Schutz";
L.SPEC_RETRIBUTION = "Vergeltung";
L.SPEC_DISCIPLINE = "Disziplin";
L.SPEC_SHADOW = "Schatten";
L.SPEC_ASSASSINATION = "Meucheln";
L.SPEC_OUTLAW = "Gesetzlosigkeit";
L.SPEC_SUBTLETY = "Täuschung";
L.SPEC_ELEMENTAL = "Elementar";
L.SPEC_ENHANCEMENT = "Verstärkung";
L.SPEC_AFFLICTION = "Gebrechen";
L.SPEC_DEMONOLOGY = "Dämonologie";
L.SPEC_DESTRUCTION = "Zerstörung";
L.SPEC_ARMS = "Waffen";
L.SPEC_FURY = "Furor";

L.WARNING_OUTOFDATEMESSAGE = "Es ist eine neuere Version von VUI Gfinder verfügbar!";

L.FORTIFIED = "Verstärkt";
L.TYRANNICAL = "Tyrannisch";

-- VUI Specific
L.USE_VUI_THEME = "VUI-Themenfarbe verwenden";
L.THEME_TOOLTIP = "Wenn aktiviert, verwendet VUI Gfinder Ihre VUI-Themenfarbe";