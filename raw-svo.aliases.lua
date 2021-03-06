-- Svof (c) 2011-2015 by Vadim Peretokin

-- Svof is licensed under a
-- Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.

-- You should have received a copy of the license along with this
-- work. If not, see <http://creativecommons.org/licenses/by-nc-sa/4.0/>.

function togglesip(what)
  assert(what == nil or what == "health" or what == "mana", "svo.togglesip wants 'health' or 'mana' as an argument")

  local beforestate = sk.getbeforestateprios()

  local hp = dict.healhealth.sip.aspriority
  local mp = dict.healmana.sip.aspriority
  if what == nil or
    what == "health" and hp < mp or
    what == "mana" and mp < hp then
      hp, mp = mp, hp
  end
  dict.healhealth.sip.aspriority = hp
  dict.healmana.sip.aspriority = mp

  local function getstring(name)
    if name == "healmana_sip" then return "<13,19,180>mana"
    elseif name == "healhealth_sip" then return "<18,181,13>health"
    end
  end

  local prios = {}
  local links = {}
  for _, j in ipairs({dict.healhealth.sip, dict.healmana.sip}) do
    prios[j.name] = j.aspriority
    links[j.name] = j
  end

  local result = getHighestKey(prios)

  echof("Swapped to "  .. getstring(result) .. getDefaultColor() .. " sipping priority.")

  make_gnomes_work()

  local afterstate = sk.getafterstateprios()
  sk.notifypriodiffs(beforestate, afterstate)
end

function aupdate()
  (openUrl or openURL)("http://doc.svo.vadisystems.com/#updating-the-system")
  -- echof("While we can't automatically update yet, here's the URL for you to download it at:")

  -- setFgColor(unpack(getDefaultColorNums))
  -- for os, url in pairs(sys.downloadurl) do
  --   echo("  "..os.." - ")
  --   setUnderline(true) echoLink(url, [[(openURL or openUrl)("]]..url..[[")]], "Download "..os.." version", true) setUnderline(false)
  -- end
  -- resetFormat()
  -- showprompt()
end

function toggle_ignore(action)
  if not dict[action] then
    echofn("%s isn't something you can ignore - see ", action)
    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("vshow ignorelist", 'svo.ignorelist()', 'Click to see things you can ignore', true)
    setUnderline(false)
    echo(".\n")
    showprompt()
    return
  end

  if svo.ignore[action] then
    unsetignore(action)
    svo.echof("Won't ignore %s anymore.", action)
  else
    setignore(action)
    svo.echof("Will ignore curing %s now.", action)
  end
  svo.showprompt()
  make_gnomes_work()
end

function show_ignore()
  echof("Things we're ignoring:%s", not next(svo.ignore) and " (none)" or '')

  setFgColor(unpack(getDefaultColorNums))
  for key in pairs(ignore) do
    echo(string.format("  %-18s", tostring(key)))
    echo("(")
    setUnderline(true)
    echoLink("remove", 'svo.ignore.'..tostring(key)..' = nil; svo.echof("Took '..tostring(key)..' off ignore.")', 'Remove '..tostring(key)..' from the ignore list', true)
    setUnderline(false)
    echo(")")

    if dict[key] and dict[key].description then
      echo(" - "..dict[key].description)

      if type(ignore[key]) == 'table' and ignore[key].because then
        echo(", ignoring because "..ignore[key].because)
      end
      echo("\n")
    else
      if type(ignore[key]) == "table" and ignore[key].because then
        echo(" - because "..ignore[key].because)
      end
      echo("\n")
    end
  end
  showprompt()
end

function aconfigs()
  echof("Doesn't do anything yet!")
end

function aconfig()
  cecho("<a_darkblue>--<purple>(svo) <a_grey>Configuration<a_darkblue>" .. ("-"):rep(59) .. "\n")

  cecho("<a_darkcyan>  Automated healing:\n")
  cecho("<a_darkgrey>    Sipping:              Moss:\n")

  cecho(string.format(
    "%s    (%s%-2d%%%s) %s%-4d %shealth%s %-4s"
  .."(%s%-2d%%%s) %s%-4d %shealth%s %-4s\n",
    "<a_darkgrey>", "<a_darkcyan>", tostring(conf.siphealth), "<a_darkgrey>", "<a_cyan>", tostring(sys.siphealth), "<a_grey>", "<a_darkgrey>", " ",
    "<a_darkcyan>", tostring(conf.mosshealth), "<a_darkgrey>", "<a_cyan>", tostring(sys.mosshealth), "<a_grey>", "<a_darkgrey>", " "
  ))

  cecho(string.format(
    "%s    (%s%-2d%%%s) %s%-4d %smana%s %-6s"
  .."(%s%-2d%%%s) %s%-4d %smana%s %-6s\n",
    "<a_darkgrey>", "<a_darkcyan>", conf.sipmana, "<a_darkgrey>", "<a_cyan>", sys.sipmana, "<a_grey>", "<a_darkgrey>", " ",
    "<a_darkcyan>", conf.mossmana, "<a_darkgrey>", "<a_cyan>", sys.mossmana, "<a_grey>", "<a_darkgrey>", " "
  ))

  echo("\n")

  cecho("<a_darkcyan>  Curing status:\n")

  for k,v in config_dict:iter() do
    if v.vconfig1 and conf[k] and not v.vconfig2 then
      cecho("  ") fg("a_green")
      echoLink('  o  ', 'svo.config.set("'..k..'", false, true)', 'Click to disable '..k, true)
      cecho("<a_grey>Use "..(type(v.vconfig1) == "string" and v.vconfig1 or v.vconfig1())..".\n")
    elseif v.vconfig1 and not conf[k] and not v.vconfig2 then
      cecho("  ") fg("a_red")
      echoLink('  x  ', 'svo.config.set("'..k..'", true, true)', 'Click to enable '..k, true)
      cecho("<a_darkgrey>Use "..(type(v.vconfig1) == "string" and v.vconfig1 or v.vconfig1())..".\n")
    end
  end

  echo"\n"

  for k,v in config_dict:iter() do
    if not v.vconfig1 and type(v.onshow) == "string" and conf[k] and not v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_green")
      echoLink('  o  ', 'svo.config.set("'..k..'", false, true)', 'Click to disable '..k, true)
      cecho("<a_grey>"..v.onshow..".\n")
    elseif not v.vconfig1 and type(v.onshow) == "string" and not conf[k] and not v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_red")
      echoLink('  x  ', 'svo.config.set("'..k..'", true, true)', 'Click to enable '..k, true)
      cecho("<a_darkgrey>"..v.onshow..".\n")
    elseif not v.vconfig1 and type(v.onshow) == "function" and conf[k] and not v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_green")
      echoLink('  o  ', 'svo.config.set("'..k..'", false, true)', 'Click to disable '..k, true)
      v.onshow("a_grey")
    elseif not v.vconfig1 and type(v.onshow) == "function" and not conf[k] and not v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_red")
      echoLink('  x  ', 'svo.config.set("'..k..'", true, true)', 'Click to enable '..k, true)
      v.onshow("a_darkgrey")
    end
  end

  echo"\n"

  if not printCmdLine or not type(conf.unknownany) == "number" then
    cecho(string.format("    <a_blue>- <a_grey>Diagnosing after <a_cyan>%s <a_grey>unknown (any) afflictions.\n", tostring(conf.unknownany)))
  else
    cecho("    <a_blue>- <a_grey>Diagnosing after") fg("a_cyan")
    echoLink(' '..conf.unknownany..' ', "printCmdLine'vconfig unknownany '", "Click to set the # of any affs to diagnose at", true)
    cecho("<a_grey>unknown (any) afflictions.\n")
  end
  if not printCmdLine or not type(conf.unknownfocus) == "number" then
    cecho(string.format("    <a_blue>- <a_grey>Diagnosing after <a_cyan>%s <a_grey>unknown (focusable) afflictions.\n", tostring(conf.unknownfocus)))
  else
    cecho("    <a_blue>- <a_grey>Diagnosing after") fg("a_cyan")
    echoLink(' '..conf.unknownfocus..' ', "printCmdLine'vconfig unknownfocus '", "Click to set the # of focusable affs to diagnose at - this is in addition to focusing on each unknown, but focusable affliction", true)
    cecho("<a_grey>unknown (focusable) afflictions.\n")
  end

  fg("a_darkblue")
  echo(string.rep("-", 62))
  fg("purple") setUnderline(true) echoLink("vconfig2", [[svo.aconfig2()]], "View vconfig2 for advanced options", true) setUnderline(false)
  fg("a_darkblue") echo(string.rep("-", 9))
  resetFormat()
  echo"\n"
  showprompt()
  echo"\n"
end

function aconfig2()
  cecho("<a_darkblue>--<purple>(svo) <a_grey>Configuration, continued<a_darkblue>" .. string.rep("-", 48) .. "\n")

  cecho("<a_darkcyan>  Pipes:\n")
  -- cecho("<a_darkgrey>    Skullcap           Valerian           Elm\n")
  cecho(string.format(
    "%s    %-21s"
  .."   %-21s"
  .."   %s\n",
    "<a_darkgrey>",
    (pipes.skullcap.filledwith and pipes.skullcap.filledwith:title() or "Skullcap") .. (pipes.skullcap.id2 == 0 and '' or ' ('..pipes.skullcap.filledwith2:title()..')'),
    (pipes.valerian.filledwith and pipes.valerian.filledwith:title() or "Valerian") .. (pipes.valerian.id2 == 0 and '' or ' ('..pipes.valerian.filledwith2:title()..')'),
    (pipes.elm.filledwith and pipes.elm.filledwith:title() or "Elm") .. (pipes.elm.id2 == 0 and '' or ' ('..pipes.elm.filledwith2:title()..')')
  ))

  cecho(string.format(
    "%s    ID %s%-21s"
  .."%sID %s%-21s"
  .."%sID %s%s\n",
    "<a_grey>", "<a_cyan>", pipes.skullcap.id .. (pipes.skullcap.id2 == 0 and '' or ' ('..pipes.skullcap.id2..')'),
    "<a_grey>", "<a_cyan>", pipes.valerian.id .. (pipes.valerian.id2 == 0 and '' or ' ('..pipes.valerian.id2..')'),
    "<a_grey>", "<a_cyan>", pipes.elm.id .. (pipes.elm.id2 == 0 and '' or ' ('..pipes.elm.id2..')')
  ))

  cecho(string.format(
    "%s    Puffs %s%-18s"
  .."%sPuffs %s%-18s"
  .."%sPuffs %s%-2s\n",
    "<a_grey>", "<a_cyan>", pipes.skullcap.puffs .. (pipes.skullcap.id2 == 0 and '' or ' ('..pipes.skullcap.puffs2..')'),
    "<a_grey>", "<a_cyan>", pipes.valerian.puffs .. (pipes.valerian.id2 == 0 and '' or ' ('..pipes.valerian.puffs2..')'),
    "<a_grey>", "<a_cyan>", pipes.elm.puffs .. (pipes.elm.id2 == 0 and '' or ' ('..pipes.elm.puffs2..')')
  ))

local c1,s1 =
    unpack(pipes.skullcap.arty and
        {"<gold>", "Arty"} or
            (pipes.skullcap.lit and {"<a_yellow>", "Lit!"} or {"<a_darkgrey>", "Unlit."})

    )
local c2,s2 =
    unpack(pipes.valerian.arty and
        {"<gold>", "Arty"} or
            (pipes.valerian.lit and {"<a_yellow>", "Lit!"} or {"<a_darkgrey>", "Unlit."})

    )
local c3,s3 =
    unpack(pipes.elm.arty and
        {"<gold>", "Arty"} or
            (pipes.elm.lit and {"<a_yellow>", "Lit!"} or {"<a_darkgrey>", "Unlit."})

    )

  cecho(string.format("    %s%-24s%s%-24s%s%s\n\n",
    c1,s1,
    c2,s2,
    c3,s3
   ))

  cecho("<a_darkcyan>  Advanced options:\n")

  for k,v in config_dict:iter() do
    if not v.vconfig1 and type(v.onshow) == "string" and conf[k] and v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_green")
      echoLink('  o  ', 'svo.config.set("'..k..'", false, true)', 'Click to disable '..k, true)
      cecho("<a_grey>"..v.onshow..".\n")
    elseif not v.vconfig1 and type(v.onshow) == "string" and not conf[k] and v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_red")
      echoLink('  x  ', 'svo.config.set("'..k..'", true, true)', 'Click to enable '..k, true)
      cecho("<a_darkgrey>"..v.onshow..".\n")
    elseif not v.vconfig1 and type(v.onshow) == "function" and conf[k] and v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_green")
      echoLink('  o  ', 'svo.config.set("'..k..'", false, true)', 'Click to disable '..k, true)
      v.onshow("a_grey")
    elseif not v.vconfig1 and type(v.onshow) == "function" and not conf[k] and v.vconfig2 and not v.vconfig2string then
      cecho("  ") fg("a_red")
      echoLink('  x  ', 'svo.config.set("'..k..'", true, true)', 'Click to enable '..k, true)
      v.onshow("a_darkgrey")
    end
  end

  echo"\n"

  cecho("    <a_blue>- <a_grey>Using ") setFgColor(unpack(getDefaultColorNums))
  echoLink(tostring(conf.echotype and conf.echotype or conf.org), '$(sys).config.showcolours()', "View other available styles", true)
  cecho("<a_grey>-style echos.\n")

  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>%s\n", (function ()
      if not conf.warningtype then
        return "Extended instakill warnings are disabled."
      elseif conf.warningtype == "all" then
        if math.random(1, 10) == 1 then
          return "Will prefix instakill warnings to all lines on the left. (muahah)"
        else
          return "Will prefix instakill warnings to all lines on the left." end
      elseif conf.warningtype == "prompt" then
        return "Will prefix instakill warnings only to prompt lines."
      elseif conf.warningtype == "right" then
        return "Will align instakill warnings to all lines on the right."
      end
    end)()))
  else
    cecho("    <a_blue>- ")
    fg("a_grey")
    echoLink((function ()
      if not conf.warningtype then
        return "Extended instakill warnings are disabled."
      elseif conf.warningtype == "all" then
        if math.random(1, 10) == 1 then
          return "Will prefix instakill warnings to all lines on the left. (muahah)"
        else
          return "Will prefix instakill warnings to all lines on the left." end
      elseif conf.warningtype == "prompt" then
        return "Will prefix instakill warnings only to prompt lines."
      elseif conf.warningtype == "right" then
        return "Will align instakill warnings to all lines on the right."
      end
    end)(), 'printCmdLine"vconfig warningtype "', "Change the warningtype - can be all, prompt, right or none", true)
    cecho("\n")
  end

  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>Assuming <a_cyan>%s%% <a_grey>of stats under blackout/recklessness.\n", tostring(conf.assumestats)))
  else
    cecho("    <a_blue>- <a_grey>Assuming ") fg("a_cyan")
    echoLink(tostring(conf.assumestats).."%", 'printCmdLine"vconfig assumestats "', "Set the % of health and mana to assume under blackout or recklessness", true)
    cecho(" <a_grey>of stats under blackout/recklessness.\n")
  end

  cecho("    <a_blue>- <a_grey>Applying for health affs only above ") fg("a_cyan")
  echoLink(tostring(conf.healthaffsabove).."%", 'printCmdLine"vconfig healthaffsabove "', "Set the % of health below which we'll be sipping, and above we'll be applying for health afflictions", true)
  cecho(" <a_grey>health.\n")

  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>Won't use mana skills below <a_cyan>%s%%<a_grey> mana.\n", tostring(conf.manause)))
  else
    cecho("    <a_blue>- <a_grey>Won't use mana skills below ") fg("a_cyan")
    echoLink(tostring(conf.manause).."%", 'printCmdLine"vconfig manause "', "Set the % of mana below which the system won't use mana-draining skills", true)
    cecho("<a_grey> mana.\n")
  end

#if skills.healing then
  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>Your highest Healing skill is <a_darkgrey>%s<a_grey>; using <a_darkgrey>%s<a_grey> Healing mode.\n", (conf.healingskill and conf.healingskill or "(none set)"), tostring(conf.usehealing)))
  else
    cecho("    <a_blue>- <a_grey>Your highest Healing skill is ") fg("a_darkgrey")
    echoLink(conf.healingskill and conf.healingskill or "(none set)", 'printCmdLine"vconfig healingskill "', "Click to change your healingskill", true)
    cecho("<a_grey>; using ") fg("a_darkgrey")
    echoLink(tostring(conf.usehealing), 'printCmdLine"vconfig usehealing "', "Click to change your healing mode - can be full, partial or none", true)
    cecho("<a_grey> Healing mode.\n")
  end
#end
#if skills.kaido then
  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>Transmuting if below <a_cyan>%d%%<a_grey> (<a_cyan>%dh<a_grey>); using <a_darkgrey>%s<a_grey> mode.\n", (conf.transmuteamount or "?"), (sys.transmuteamount or "?"), tostring(conf.transmute)))
  else
    cecho("    <a_blue>- <a_grey>Transmuting if below") fg("a_cyan")
    echoLink(' '..(conf.transmuteamount or "?")..'%', 'printCmdLine"vconfig transmuteamount "', "Set the amount percent of max health below which transmute will be used", true)
    cecho("<a_grey> (") fg("a_cyan")
    echoLink((sys.transmuteamount or "?").."h", 'printCmdLine"vconfig transmuteamount "', "Set the amount percent of max health below which transmute will be used", true)
    cecho("<a_grey>); using ") fg("a_darkgrey")
    echoLink(tostring(conf.transmute), 'printCmdLine"vconfig transmute "', "Set the mode in which to use transmute in - can be replaceall, replacehealth, supplement or none.  \nreplaceall means that it won't sip health nor eat moss to heal your health, but only use transmute.  \nreplacehealth will mean that it will not sip health, but use moss and transmute.  \nsupplement means that it'll use all three ways to heal you, and none means that it won't use transmute.", true)
    cecho("<a_grey> mode.\n")
  end
#end
#if skills.metamorphosis then
  if not printCmdLine then
    cecho(string.format("    <a_blue>- <a_grey>Your highest morph skill is <a_darkgrey>%s<a_grey> (", (conf.morphskill and conf.morphskill or "(none set)")))
    echoLink("view defs you can do", 'svo.viewmetadefs()', "View defences you can put up")
    echo(").\n")
  else
    cecho("    <a_blue>- <a_grey>Your highest morph skill is ") fg("a_darkgrey")
    echoLink(conf.morphskill and conf.morphskill or "(none set)", 'printCmdLine"vconfig morphskill "', "Change the highest morph skill you have", true)
    cecho("<a_grey> (")
    echoLink("view defs you can do", 'svo.viewmetadefs()', "View defences you can put up")
    echo(").\n")
  end
#end
  if not conf.customprompt then
    cecho("    <a_blue>- ") fg("a_grey")
    echoLink("Standard prompt is in use.", '$(sys).config.set("customprompt", "on", true)', "Enable custom prompt", true)
    echo("\n")
  else
    cecho("    <a_blue>- ") fg("a_grey")
    echoLink("Custom prompt is in use", '$(sys).config.set("customprompt", "off", true)', "Disable custom prompt", true)
    echo(" (")
    echoLink("view", 'svo.config.showprompt(); printCmdLine("vconfig customprompt "..tostring(svo.conf.customprompt))', "View the custom prompt you've currently set")
    echo(")")

    echo(" (")
    echoLink("reset", 'svo.setdefaultprompt(); svo.echof("Default custom prompt restored.")', "Reset the custom prompt to default")
    cecho("<a_grey>)\n")
  end

  for k,v in config_dict:iter() do
    if v.vconfig2string and type(v.onshow) == "string" then
      cecho("    <a_blue>- ")
      cecho("<a_grey>"..v.onshow..".\n")

    elseif v.vconfig2string and type(v.onshow) == "function" then
      cecho("    <a_blue>- ")
      v.onshow("a_grey")
    end
  end


  fg("a_darkblue")
  echo(string.rep("-", 62))
  fg("purple") setUnderline(true) echoLink("vconfig", [[svo.aconfig()]], "View vconfig for basic options", true) setUnderline(false)
  fg("a_darkblue") echo(string.rep("-", 10))
  resetFormat()

  echo"\n"
  showprompt()
  echo"\n"
end

#if skills.metamorphosis then
function viewmetadefs()
  echof("You can put up any of these defences, given your morph skill:\n  %s", oneconcat(sk.morphsforskill) ~= "" and oneconcat(sk.morphsforskill) or "(none, actually)")
end
#end

function asave()
  signals.saveconfig:emit()
  showprompt()
end

function ashow()
  echof("Defence modes:")
  echo "  " defences.print_def_list()

  if sys.deffing then
    echof("Currently deffing up; waiting on %s to come up.", sk.showwaitingdefup())
  end

  echo"\n"

  echofn("View priorities (")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink("reset all to default", '$(sys).prio.usedefault(true)', "Click here to reset all of the systems curing/defup priorities back to default", true)
  setUnderline(false)
  echo(", ")
  setUnderline(true)
  echoLink("import", '$(sys).prio.list(true); printCmdLine"vimportprio "', "Click here select a priority list to import", true)
  setUnderline(false)
  echo(", ")
  setUnderline(true)
  echoLink("export", 'printCmdLine"vexportprio " ', "Click here to give your priorities a name & export them", true)
  setUnderline(false)
  echo("):\n")
  echo("  ")
  setUnderline(true)
  echoLink("herb", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("herb")]])', 'View herb balance priorities', true)
  setUnderline(false) setUnderline(false) echo", " setUnderline(true) setUnderline(true)
  echoLink("focus", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("focus")]])', 'View focus balance priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("salve", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("salve")]])', 'View salve balance priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("purgative", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("purgative")]])', 'View purgative balance priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("smoke", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("smoke")]])', 'View smoke priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("sip", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("sip")]])', 'View sip balance priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("balance/equilibrium", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("physical")]])', 'View balance priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("misc", 'tempTimer(0, [[echo([=[ \n]=]); svo.printorder("misc")]])', 'View miscellaneous priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("aeon/retardation", 'tempTimer(0, [[echo([=[ \n]=]); svo.printordersync()]])', 'View slow curing priorities', true)
  setUnderline(false) echo", " setUnderline(true)
  echoLink("parry", 'tempTimer(0, [[echo([=[ \n]=]); svo.sp.show()]])', 'View the parry setup', true)
  resetFormat()
  echo"\n"

  echofn("Serverside use:   ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(conf.serverside and "enabled" or "disabled", "$(sys).tntf_set('serverside', "..(conf.serverside and "false" or "true").. ', false); svo.ashow()', (conf.serverside and "Disable" or "Enable")..' use of serverside by Svof', true)
  resetFormat()
  echo"\n"


  echofn("Anti-illusion:    ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(conf.aillusion and "enabled" or "disabled", "$(sys).tntf_set('ai', "..(conf.aillusion and "false" or "true").. ', false); svo.ashow()', (conf.aillusion and "Disable" or "Enable")..' anti-illusion', true)
  resetFormat()
  echo"\n"

  echofn("Defence keepup:   ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(conf.keepup and "enabled" or "disabled", "$(sys).tntf_set('keepup', "..(conf.keepup and "false" or "true").. ', false); svo.ashow()', (conf.keepup and "Disable" or "Enable")..' keepup', true)
  resetFormat()
  echo"\n"

  echofn("Bashing triggers: ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(conf.bashing and "enabled" or "disabled", "$(sys).tntf_set('bashing', "..(conf.bashing and "false" or "true").. ', false); svo.ashow()', (conf.bashing and "Disable" or "Enable")..' bashing triggers', true)
  resetFormat()
  echo"\n"

  echofn("Arena mode:       ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(conf.arena and "enabled" or "disabled", "$(sys).tntf_set('arena', "..(conf.arena and "false" or "true").. ', false); svo.ashow()', (conf.arena and "Disable" or "Enable")..' arena triggers', true)
  resetFormat()
  echo"\n"

echo"\n"
  echofn("Cure method: ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink(tostring(conf.curemethod), [=[
    svo.echof([[Possible options are:
  * conconly - default - uses only the usual Concoctionist potions, salves and herbs
  * transonly - uses only the new Alchemy cures
  * preferconc - uses either available cures that you have, but prefers Concoctions ones. This method does optimize for curing speed - if you don't have a herb in your inventory but have an equivalent mineral, it'll eat the mineral since it's quicker (don't have to outr the herb)
  * prefertrans - similar to preferconc, but prefers Transmutation cures
  * prefercustom - allows you to individually select which cures would you prefer over which, using the vshow curelist menu. Similar to other prefers, the system will use your preferred cure if you have it and fall back to the alternative if you don't. If the cure is a herb/mineral and your preferred cure is in the rift but the alternative is already available in the inventory, then the system will eat the alternative, because that is faster than outring it.]]);
    printCmdLine"vconfig curemethod "]=], "Set the curemethod to use - conconly, transonly, preferconc, prefertrans or prefercustom", true)
  setUnderline(false)

  if conf.curemethod and conf.curemethod == "prefercustom" then
    echo(" (")
    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("configure it", 'svo.showcurelist()', "Setup which cures would you prefer over which for prefercustom - also accessible via vshow curelist", true)
    setUnderline(false)
    setFgColor(unpack(getDefaultColorNums))
    echo(")")
  end
  echo"\n"

  echofn("Current parry strategy is:  ")
  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  local spname
  if not sp_config.parry or sp_config.parry == '' then
    spname = "(none)"
  elseif type(sp_config.parry) == "function" then
    spname = "(custom "..tostring(sp_config.parry)..")"
  else
    spname = tostring(sp_config.parry)
  end

  echoLink(spname, 'svo.sp.setparry(nil, true)', 'Click to change the parry strategy. When in "manual", use the p* (pra, pla, ph, etc...) alises to parry/guard with', true)
  setUnderline(false)
  echo'\n'

  if me.doqueue.repeating then
    echof("Do-Repeat is enabled: %s", tostring(me.doqueue[1]) or "(nothing yet)") end


  if conf.curemethod and (conf.curemethod == "preferconc" or conf.curemethod == "prefertrans") then
    echofn("Cure method is %s: ", tostring(conf.curemethod))
    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("reset sip alternatives", [[
      svo.es_potions = svo.es_potions or {}
      for thing, category in pairs(svo.es_categories) do
        svo.es_potions[category] = svo.es_potions[category] or {}
        if category ~= "venom" then
          svo.es_potions[category][thing] = {sips = 1, vials = 1, decays = 0}
        end
      end
      svo.echof("Reset alternatives, will use the preferred potions now.")
    ]], 'Reset sipping alternatives for '..tostring(conf.curemethod)  , true)
    setUnderline(false)
    echo("\n")
  end

  if conf.lag ~= 0 then
    echof("Lag tolerance level: %d", conf.lag)
  end

  local c = table.size(me.lustlist)
  if conf.autoreject == "black" then
    echofn("People we're autorejecting:  %s ", (c ~= 0 and c or 'none'))
  elseif conf.autoreject == "white" then
    echofn("People we're not autorejecting: %s ", (c ~= 0 and c or 'none'))
  end

  setFgColor(unpack(getDefaultColorNums))
  setUnderline(true)
  echoLink("(view)", 'echo"\\n" expandAlias"vshow lustlist"', 'Click here view the names', true)
  echo"\n"

  if next(me.unparryables) then
    echofn("Things we can't use for parrying: %s ", oneconcat(me.unparryables))

    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("(reset)", 'echo"\\n" svo.me.unparryables = {} svo.echof"Cleared list of stuff we can\'t parry with."', 'Click here to reset', true)
    echo"\n"
  end

  do
    local c = 0
    for herb, count in pairs(rift.precache) do
      c = c + count
    end

    echofn("# of herbs we're precaching: %d ", c)

    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("(view)", 'echo"\\n" svo.showprecache()', 'Click here open the menu for precache', true)
    echo"\n"
  end

  do
    local c = table.size(ignore)

    echofn("# of things we're ignoring:  %d ", c)

    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("(view)", 'echo"\\n" svo.show_ignore()', 'Click here open the ignore list menu', true)
    echo"\n"
  end

  if next(affs) then
    showaffs()
  end

  if conf.customprompt and (affs.blackout or innews) then
    echofn("Custom prompt is enabled, but not showing due to %s. ",
      (function ()
        local t = {}
        if affs.blackout then t[#t+1] = "blackout" end
        if innews then t[#t+1] = "being in the editor" end
        return concatand(t)
      end
    )())
    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("(reset)", 'svo.config.set("customprompt", "on")', 'Click here to re-enable the custom prompt', true)
    echo"\n"
  end

  if conf.paused then
    echof("System is currently paused.") end
  if me.dopaused then
    echof("Do system is currently paused.") end

  if sk.gettingfullstats then
    echof("Healing health and mana to up to full stats (cancel).") end

  -- warn people if they have mana above health as sip priority by accident
  if prio.getnumber("healmana", "sip") > prio.getnumber("healhealth", "sip") then
    echofn("Your mana sip priority is above health sipping (")
    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true) echoLink("change", 'svo.togglesip("health")', 'Click to change to health', true) setUnderline(false)
    echo(")\n")
  end

  raiseEvent("svo onshow")

  showprompt()
end


function showaffs(window)
  if sys.sync then echof(window or "main", "Slow curing mode enabled.") end
  echof(window or "main", "Current list of affs: " .. tostring(affs))
end

function showbals(window)
  echof(window or "main", "Balance state: " ..
    (function (tbl)
      local result = {}
      for i,j in pairs(tbl) do
        if j then
          result[#result+1] = string.format("<50,205,50>%s%s", i,getDefaultColor())
        else
          result[#result+1] = string.format("<205,201,201>%s (off)%s", i,getDefaultColor())
        end
      end

      table.sort(result)
      return table.concat(result, ", ")
    end)(bals))
    showprompt()
end

function showserverside()
  local function echoaction(action, last)
    dechoLink(string.format("<153,204,204>[<0,204,0>%s<153,204,204>] %"..(last and '' or '-23').."s",
      serverignore[action] and ' ' or 'x', action),
      string.format([[svo.%ssetserverignore("%s"); svo.showserverside()]], serverignore[action] and 'un' or '', action),
      serverignore[action] and ('Make Svof handle '..action..' instead of serverside') or ('Make serverside handle '..action..' instead of Svof'), true)
  end

  local actions = sk.getallserversideactions()

  echof("Things serverside can do but Svof will be handling instead:")
  for i = 1, #actions, 3 do
    local action1, action2, action3 = actions[i], actions[i+1], actions[i+2]

    echoaction(action1)
    if action2 then echoaction(action2) end
    if action3 then echoaction(action3, true) end
    echo'\n'
  end

  echo'\n'

  if not conf.serverside then
    dechoLink(getDefaultColor().."  (enable serverside use)", 'svo.tntf_set("serverside", true)', 'Serverside use is disabled - click here to enable it', true)
    echo'\n'
  end

  dechoLink(getDefaultColor().."  (disable all)", 'svo.enableallserverside()', 'Click here to make serverside handle everything', true)
  dechoLink(getDefaultColor().."  (restore defaults)", 'svo.enabledefaultserverside()', 'Click here to restore default options', true)
  echo'\n'
  showprompt()
end

function svo.enableallserverside()
  local actions = sk.getallserversideactions()

  for i = 1, #actions do
    local action = actions[i]

    setserverignore(action)
  end

  echof("Disabled all serverside overrides; serverside will now handle everything.")
  showprompt()
end

function svo.enabledefaultserverside()
  unsetserverignore"impale"
  unsetserverignore"lovers"
  unsetserverignore"roped"
  unsetserverignore"transfixed"
  unsetserverignore"webbed"
  unsetserverignore"selfishness"

  echof("Restored defaults on what should Svof handle instead of serverside.")
  showprompt()
end

function showcurelist()
  local herb_list  = rift.curativeherbs
  local herbs      = rift.herb_conversions
  local vials_list = rift.forestalvials
  local vials      = rift.vial_conversions

  local function showfor(list, conversion)
    for i = 1, #list do
      local forestal, alchy = list[i], conversion[list[i]]
      local preferred = me.curelist[forestal]

      if forestal == preferred then -- split the logic instead of stuffing into one uncomprehensible string.format
        cecho(string.format("<white>%15s", forestal))
      else
        cechoLink(string.format("<dim_grey>%15s", forestal), [[svo.me.curelist.]]..forestal..[[ = "]]..forestal..[["; svo.showcurelist()]], "Click to prefer "..forestal.." over "..alchy, true)
      end

      cechoLink(" <royal_blue><<BlueViolet>-<royal_blue>> ", [[svo.me.curelist.]]..forestal..[[ = "]]..(forestal == preferred and alchy or forestal)..[["; svo.showcurelist()]], "Click to swap "..forestal.." and "..alchy.." cures", true)

      if alchy == preferred then
        cecho(string.format("<white>%-15s", alchy))
      else
        cechoLink(string.format("<dim_grey>%-15s", alchy), [[svo.me.curelist.]]..forestal..[[ = "]]..alchy..[["; svo.showcurelist()]], "Click to prefer "..alchy.." over "..forestal, true)
      end

      echo("\n")
    end
  end

  echof("Click on what you'd like to be preferred in prefercustom curemethod:\n")
  decho(string.format("%s            herbs/minerals\n", getDefaultColor()))

  showfor(herb_list, herbs)

  if conf.curemethod ~= "prefercustom" then
    echo"\n"
    echofn("This is the setup for the prefercustom curemethod - which you aren't currently using (you're using %s).\n  Do you want to change to prefercustom? Click here if so: ", conf.curemethod)

    setFgColor(unpack(getDefaultColorNums))
    setUnderline(true)
    echoLink("vconfig curemethod prefercustom", 'svo.config.set("curemethod", "prefercustom", true); svo.showcurelist()', 'Click to change the curemethod from '..conf.curemethod..' to prefercustom, which allows you to individually specify which cures you prefer', true)
    setUnderline(false)
    echo'\n'
  end

  echo"\n"
  showprompt()
end


function app(what, quiet)
  assert(what == nil or what == "on" or what == "off" or type(what) == "boolean", "svo.app wants 'on' or 'off' as an argument")

  if what == "on" or what == true or (what == nil and not conf.paused) then
    conf.paused = true
  elseif what == "off" or what == false or (what == nil and conf.paused) then
    conf.paused = false
    sk.paused_for_burrow = nil
  end

  if not quiet then echof("System " .. (conf.paused and "paused" or "unpaused") .. ".") end
  raiseEvent("svo config changed", "paused")

  make_gnomes_work()
end

function dop(what, echoback)
  assert(what == nil or what == "on" or what == "off" or type(what) == "boolean", "svo.dop wants 'on' or 'off' as an argument")

  if what == "on" or what == true or (what == nil and not me.dopaused) then
    me.dopaused = true
  elseif what == "off" or what == false or (what == nil and me.dopaused) then
    me.dopaused = false
  end

  if echoback then echof("Do system " .. (me.dopaused and "paused" or "unpaused") .. ".") end

  make_gnomes_work()
end

function dv()
  sys.manualdiag = true
  make_gnomes_work()
end

function inra()
  if not sys.enabledgmcp then echof("You need to enable GMCP for this alias to work.") return end

  sk.inring = true
  sendGMCP("Char.Items.Inv")
  sendSocket"\n"
end

function get_herbs()
  if not sys.enabledgmcp then echof("You need to enable GMCP for this alias to work.") return end

  if (affs.blindaff or defc.blind) and not defc.mindseye then echof("vget herbs doesn't work when you're true blind (if you do have mindseye, perhaps check def?)") return end

  sk.retrieving_herbs = true
  send("ql", false)
end

function adf()
  me.manualdefcheck = true
  make_gnomes_work()
end

function manualdef()
  doaction(dict.defcheck.physical)
end

function manualdiag()
  if sys.sync then sk.gnomes_are_working = true end
  killaction(dict.diag.physical)
  doaction(dict.diag.physical)
  if sys.sync then sk.gnomes_are_working = false end
end

function reset.affs(echoback)
  for aff in pairs(affs) do
    if aff ~= "lovers" then
      removeaff(aff)
    end
  end

  affsp = {}

  if echoback then
    if math.random(10) == 1 then
      echof("BEEP BEEP! Affs reset.")
    else
      echof("All afflictions reset.")
    end
  end
end

function reset.general()
  actions = pl.OrderedMap()
  lifevision.l = pl.OrderedMap()

  for bal in pairs(bals_in_use) do
    bals_in_use[bal] = {}
  end

  actions_performed = {}
  sk.onpromptfuncs = {}
  sk.checkaeony()
  signals.aeony:emit()
  signals.canoutr:emit()
  innews = false
  passive_cure_paragraph = false
  check_generics()
end

function reset.defs(echoback)
  for def, status in pairs(defc) do
    if not defs_data[def] or (defs_data[def] and not defs_data[def].stays_on_death) then
      defc[def] = nil
    end
  end

  -- parry is also counted as a def and is reset on burst/death, so clear it here as well
  local t = sps.parry_currently
  for limb, _ in pairs(t) do t[limb] = false end

  if echoback then echof("all defences reset.") end
end

signals.charname:connect(function() reset.defs() end)
signals.gmcpcharname:connect(function() reset.defs() end)

function reset.bals(echoback)
  -- create a new table instead of resetting the values in the old, because if you
  -- screw up and delete some balances - you'd expect reset to restore them
  bals = {
    herb = true, sip = true, moss = true,
    purgative = true, salve = true,
    balance = true, equilibrium = true, focus = true,
    tree = true, leftarm = "unset", rightarm = "unset",
    dragonheal = true, smoke = true,
#if skills.voicecraft then
    voice = true,
#end
#if class == "druid" then
    hydra = true,
#end
#if skills.domination then
    entities = true,
#end
#if skills.healing then
    healing = true,
#end
#if skills.venom then
    shrugging = true,
#end
#if skills.chivalry or skills.shindo or skills.kaido or skills.metamorphosis then
    fitness = true,
#end
#if skills.chivalry then
    rage = true,
#end
#if skills.physiology then
    humour = true, homunculus = true,
#end
  }

  for balance in pairs(bals) do raiseEvent("svo got balance", balance) end

  if echoback then echof("All balances reset.") end
end

function ignorelist()
  local t = {}
  local count = 0

  local skip
  for k,v in pairs(dict) do
    for balance, _ in pairs(v) do
      if balance == "waitingfor" or balance == "happened" then skip = true end
    end

    if not skip then t[#t+1] = k end
    skip = false
  end
  table.sort(t)
  echof("Things we can ignore:") echo"  "

  for _, name in ipairs(t) do
    echo(string.format("%-20s", name))
    count = count + 1
    if count % 4 == 0 then echo "\n  " end
  end
  echo'\n' showprompt()
end

function afflist()
  local function getaffs()
    local t = {}

    for k,v in pairs(dict) do
      if v.aff and not v.aff.notagameaff then t[#t+1] = k end
    end
    table.sort(t)

    return t
  end

  -- key-value table with an explanation message
  local function getuncurables(affs)
    local uncurables = {}
    local type = type

    -- check all balances, and if any get flagged, add with a message listing all balances
    for _, affname in ipairs(affs) do
      local uncurablebalances = {}
      for balancename, balancedata in pairs(dict[affname]) do
        if type(balancedata) == "table" and balancedata.uncurable then uncurablebalances[#uncurablebalances+1] = balancename end
      end

      if uncurablebalances[1] then
        uncurables[affname] = string.format("%s affliction doesn't have a cure on the %s balance%s", affname, concatand(uncurablebalances), (#uncurablebalances > 1 and 's' or ''))
      end
    end

    return uncurables
  end

  local t = getaffs()
  local uncurables = getuncurables(t)
  local count = 0

  echof("Affliction list (%d):", #t) echo"  "

  local underline = setUnderline; _G.setUnderline = function () end

  local function getspacecount(name)
    if not valid["proper_"..name] and not uncurables[name] then
      return 23
    elseif valid["proper_"..name] and not uncurables[name] then
      return 37
    elseif valid["proper_"..name] and uncurables[name] then
      return 47
    elseif not valid["proper_"..name] and uncurables[name] then
      return 37
    end
  end

  local function gettext(name)
    if not valid["proper_"..name] and not uncurables[name] then
      return name
    elseif valid["proper_"..name] and not uncurables[name] then
      return name.." <0,128,128>pr<r>"
    elseif valid["proper_"..name] and uncurables[name] then
      return name.." <0,128,128>pr uc<r>"
    elseif not valid["proper_"..name] and uncurables[name] then
      return name.." <0,128,128>uc<r>"
    end
  end

  local function gethinttext(name)
    if not uncurables[name] then
      return "Click to the the function to use for "..name
    else
      return "Click to the the function to use for "..name..". Note also that this action has no in-game equivalent (UnCurable), so server-side priority can't be set for this"
    end
  end

  for _, name in ipairs(t) do
    dechoLink(string.format("%-"..getspacecount(name).."s", gettext(name)),
        string.format([[svo.echof("Function to use for this aff:\nsvo.valid.%s()")]], not valid["proper_"..name] and "simple"..name or "proper_"..name), gethinttext(name), true)
    count = count + 1
    if count % 3 == 0 then echo "\n  " end
  end
  if count % 3 == 0 then echo "\n  " end
  echo'\n' showprompt()
  _G.setUnderline = underline
end

function adddefinition(tag, func)
  assert(type(tag) == "string" and type(func) == "string", "svo.adddefinition: need both tag and function to be strings")
  cp.adddefinition(tag, func)
end

function vaff(aff)
  if not dict[aff] or not dict[aff].aff then echof(aff.." isn't a known affliction to add.") return end

  if debug.traceback():find("Trigger", 1, true) then
    (svo.valid["proper_"..aff] or svo.valid["simple"..aff])()
  else
    if dict[aff].aff and dict[aff].aff.forced then
      dict[aff].aff.forced()
    elseif dict[aff].aff then
      dict[aff].aff.oncompleted()
    else
      addaff(dict[aff])
    end

    if aff == "aeon" then removeaff("retardation") end
    signals.after_lifevision_processing:unblock(cnrl.checkwarning)
    sk.checkaeony()
    signals.aeony:emit()
    make_gnomes_work()
  end
end

function vrmaff(aff)
  if not dict[aff] or not dict[aff].aff then echof(aff.." isn't a known affliction to remove.") return end

  if lifevision.l[aff.."_aff"] then
    lifevision.l:set(aff.."_aff", nil)
  end

  if dict[aff].gone then
    dict[aff].gone.oncompleted()
  else
    removeaff(aff)
  end
  signals.after_lifevision_processing:unblock(cnrl.checkwarning)
  sk.checkaeony()
  signals.aeony:emit()
  make_gnomes_work()
end

#if skills.kaido then
  transmute = function()
    -- custom check here, not using isadvisable because this should ignore prone
    if (not defc.dragonform and (stats.currenthealth < sys.transmuteamount) and not doingaction"healhealth" and not doingaction"transmute" and can_usemana()) then
        doaction("transmute", "physical")
    end
  end
#else
  transmute = function()
  end
#end

