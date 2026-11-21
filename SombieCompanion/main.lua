local json = require("json")

local W, H = 1100, 720
local sidebar = 205
local tabs = {"Dashboard", "Events", "Members", "Projects", "Resources", "Missions", "Files", "Sheets"}
local active = "Dashboard"
local data = {events={}, members={}, projects={}, resources={}, missions={}, spreadsheets={}}
local selected = nil
local selectedKey = nil
local modal = nil
local buttons = {}
local notice, noticeTimer = "", 0
local font, smallFont, titleFont, tinyFont
local imageCache = {}
local sheetIndex, sheetRow, sheetCol = 1, 1, 1
local sheetTyping = false
local fileEntries = {}

local C = {
    bg={0.88,0.82,0.83}, white={0.91,0.84,0.85}, palePink={0.84,0.70,0.74},
    paleBlue={0.75,0.79,0.83}, line={0.68,0.59,0.62},
    pink={0.72,0.46,0.55}, blue={0.43,0.55,0.63}, peach={0.83,0.61,0.53},
    text={0.22,0.18,0.20}, muted={0.39,0.33,0.36}, green={0.38,0.56,0.46},
    red={0.75,0.42,0.42}, yellow={0.75,0.61,0.36}
}

local function set(c) love.graphics.setColor(c) end
local function rect(x,y,w,h,c,outline)
    set(c); love.graphics.rectangle("fill",x,y,w,h)
    if outline then set(outline); love.graphics.rectangle("line",x,y,w,h) end
end
local function line(x1,y1,x2,y2,c) set(c or C.line); love.graphics.line(x1,y1,x2,y2) end
local function txt(s,x,y,f,c)
    love.graphics.setFont(f or font); set(c or C.text); love.graphics.print(tostring(s or ""),x,y)
end
local function wrapText(s, f, maxWidth)
    local lines, current = {}, ""
    for word in tostring(s or ""):gmatch("%S+") do
        local test = current == "" and word or current .. " " .. word
        if f:getWidth(test) > maxWidth and current ~= "" then
            lines[#lines+1] = current; current = word
        else current = test end
    end
    if current ~= "" then lines[#lines+1] = current end
    return lines
end
local function wrapped(s,x,y,maxWidth,f,c,lineHeight,maxLines)
    local lines=wrapText(s,f or font,maxWidth)
    for i=1,math.min(#lines,maxLines or #lines) do txt(lines[i],x,y+(i-1)*(lineHeight or 18),f,c) end
    return #lines
end
local function short(s,n) s=tostring(s or ""); if #s>n then return s:sub(1,n-3).."..." end; return s end
local function removeLastUtf8Char(value)
    value=tostring(value or "")
    local i=#value
    while i>0 do
        local byte=value:byte(i)
        if byte<128 or byte>=192 then break end
        i=i-1
    end
    return value:sub(1,math.max(0,i-1))
end
local function notify(s) notice=s; noticeTimer=2.6 end
local function saveData()
    local ok, encoded=pcall(json.encode,data)
    if ok then
        love.filesystem.write("clan_data.json",encoded)
        notify("Saved on this computer")
    else notify("Save failed: "..tostring(encoded)) end
end
local function ensureShape()
    for _,k in ipairs({"events","members","projects","resources","missions","spreadsheets"}) do
        if type(data[k])~="table" then data[k]={} end
    end
    for _,p in ipairs(data.projects) do p.notes=p.notes or ""; p.tasks=p.tasks or {}; p.attachments=p.attachments or {} end
    for _,e in ipairs(data.events) do e.notes=e.notes or ""; e.tasks=e.tasks or {}; e.attachments=e.attachments or {} end
    for _,m in ipairs(data.members) do m.notes=m.notes or ""; m.servers=m.servers or {"","",""} end
    for _,r in ipairs(data.resources) do r.notes=r.notes or ""; r.attachments=r.attachments or {} end
    for _,m in ipairs(data.missions) do m.notes=m.notes or ""; m.attachments=m.attachments or {} end
end
local function loadData()
    if love.filesystem.getInfo("clan_data.json") then
        local raw=love.filesystem.read("clan_data.json")
        local ok, decoded=pcall(json.decode,raw)
        if ok and type(decoded)=="table" then data=decoded else notify("Save file could not be read") end
    end
    ensureShape()
end
local function addButton(label,x,y,w,h,fn,style)
    local mx,my=love.mouse.getPosition(); local hover=mx>=x and mx<=x+w and my>=y and my<=y+h
    local fill=C.white; local border=C.line; local ink=C.text
    if style=="primary" then fill=C.pink; border=C.pink
    elseif style=="blue" then fill=C.paleBlue; border=C.line
    elseif style=="peach" then fill=C.peach; border=C.peach
    elseif hover then fill=C.palePink end
    rect(x,y,w,h,fill,border)
    love.graphics.setFont(font); local tw=font:getWidth(label)
    txt(label,x+(w-tw)/2,y+(h-font:getHeight())/2, font,ink)
    buttons[#buttons+1]={x=x,y=y,w=w,h=h,fn=fn}
end
local function keyForTab()
    return ({Events="events",Members="members",Projects="projects",Resources="resources",Missions="missions"})[active]
end
local function labelForKey(k) return ({events="Event",members="Member",projects="Project",resources="Resource",missions="Mission"})[k] or "Entry" end
local function openModal(kind, record, extra)
    local specs={
        event={{"Event name","name"},{"Date / time","date"},{"Leader","leader"},{"Description","description",true}},
        member={{"Player name","name"},{"Clan role","role"},{"Specialty / notes","notes",true},{"Server 1","server1"},{"Server 2","server2"},{"Server 3","server3"}},
        project={{"Project name","name"},{"Goal / description","description",true},{"Target date","date"}},
        resource={{"Resource name","name"},{"Current quantity","quantity"},{"Needed quantity","needed"},{"Category","category"},{"Notes","notes",true}},
        mission={{"Mission name","name"},{"Objective","objective",true},{"Reward / points","reward"}},
        note={{"Notes","notes",true}}, task={{"Task / checklist item","task"}},
        attachment={{"Attachment label","label"},{"Full file path","path"}},
        attendee={{"Attendee names (comma separated)","attendees",true}}
    }
    modal={kind=kind,record=record,fields={},focus=1,extra=extra}
    for _,sp in ipairs(specs[kind] or {}) do
        local val=""
        if record then
            if sp[2]=="server1" then val=(record.servers and record.servers[1]) or ""
            elseif sp[2]=="server2" then val=(record.servers and record.servers[2]) or ""
            elseif sp[2]=="server3" then val=(record.servers and record.servers[3]) or ""
            else val=tostring(record[sp[2]] or "") end
        end
        modal.fields[#modal.fields+1]={label=sp[1],key=sp[2],value=val,multiline=sp[3] or false}
    end
end
local function currentList()
    return data[keyForTab()] or {}
end
local function openDetail(k, index)
    selectedKey=k; selected=index; active=({events="Events",members="Members",projects="Projects",resources="Resources",missions="Missions"})[k]
end
local function addRecord()
    if not modal then return end
    local kind=modal.kind; local rec=modal.record or {}; local vals={}
    for _,f in ipairs(modal.fields) do vals[f.key]=f.value end
    if kind=="note" then rec.notes=vals.notes or ""
    elseif kind=="task" then
        rec.tasks=rec.tasks or {}; if vals.task and vals.task:match("%S") then rec.tasks[#rec.tasks+1]={text=vals.task,done=false} end
    elseif kind=="attachment" then
        local path=(vals.path or ""):gsub('^"',''):gsub('"$','')
        local f=io.open(path,"rb")
        if not f then notify("File path could not be opened"); return end
        local bytes=f:read("*a"); f:close()
        local filename=path:gsub("\\","/"):match("([^/]+)$") or "attachment"
        local safe=filename:gsub("[^%w%._%-]","_")
        local folder="attachments"; love.filesystem.createDirectory(folder)
        local stored=folder.."/"..tostring(os.time()).."_"..safe
        local ok=love.filesystem.write(stored,bytes)
        if not ok then notify("Could not copy attachment into app storage"); return end
        rec.attachments=rec.attachments or {}
        rec.attachments[#rec.attachments+1]={label=(vals.label and vals.label~="" and vals.label) or filename,file=stored,filename=filename}
    elseif kind=="attendee" then rec.attendees=vals.attendees or ""
    else
        for k,v in pairs(vals) do rec[k]=v end
        if kind=="member" then rec.servers={vals.server1 or "",vals.server2 or "",vals.server3 or ""} end
        if kind=="resource" then rec.quantity=tonumber(rec.quantity) or 0; rec.needed=tonumber(rec.needed) or 0 end
        if not rec.name or not rec.name:match("%S") then notify("Please enter a name"); return end
        rec.created=rec.created or os.date("%Y-%m-%d")
        if not modal.record then
            local key=kind.."s"
            if kind=="mission" then key="missions" elseif kind=="member" then key="members" elseif kind=="resource" then key="resources" elseif kind=="project" then key="projects" elseif kind=="event" then key="events" end
            data[key][#data[key]+1]=rec
            selectedKey=key; selected=#data[key]
        end
    end
    modal=nil; ensureShape(); saveData()
end
local function deleteSelected()
    if selectedKey and selected and data[selectedKey][selected] then
        table.remove(data[selectedKey],selected); selected=nil; selectedKey=nil; saveData()
    end
end
local function openAttachment(att)
    local full=love.filesystem.getSaveDirectory().."/"..att.file
    full=full:gsub("\\", "/")
    local prefix=full:match("^%a:/") and "file:///" or "file://"
    local url=prefix..full:gsub(" ","%%20")
    love.system.openURL(url)
end
local function imageFor(att)
    if not att or not att.file then return nil end
    local ext=(att.filename or att.file):lower():match("%.([%w]+)$")
    if ext~="png" and ext~="jpg" and ext~="jpeg" then return nil end
    if imageCache[att.file] then return imageCache[att.file] end
    local bytes=love.filesystem.read(att.file)
    if not bytes then return nil end
    local ok,img=pcall(function() return love.graphics.newImage(love.filesystem.newFileData(bytes,att.filename or "image")) end)
    if ok then imageCache[att.file]=img; return img end
    return nil
end

function love.load()
    love.window.setMode(W,H,{resizable=true,minwidth=850,minheight=560})
    W,H=love.graphics.getDimensions()
    font=love.graphics.newFont(14); smallFont=love.graphics.newFont(12); tinyFont=love.graphics.newFont(10); titleFont=love.graphics.newFont(24)
    love.graphics.setBackgroundColor(C.bg); loadData()
end
function love.resize(w,h) W,H=w,h end

local function drawHeader()
    rect(sidebar+22,18,W-sidebar-44,66,C.white,C.line)
    txt("Sombie Clan Companion",sidebar+42,28,titleFont,C.blue)
    txt("Personal organiser  |  Saved on this computer",sidebar+44,59,smallFont,C.muted)
    txt(os.date("%a, %d %b %Y"),W-170,44,smallFont,C.muted)
end
local function drawSidebar()
    rect(0,0,sidebar,H,C.paleBlue)
    txt("Sombie",22,24,titleFont,C.blue); txt("Clan companion",23,57,smallFont,C.muted)
    line(20,88,sidebar-20,88)
    for i,t in ipairs(tabs) do
        local y=108+(i-1)*48; local on=active==t
        if on then rect(12,y-7,sidebar-24,39,C.white,C.line); rect(12,y-7,3,39,C.pink) end
        txt(string.format("%02d",i),25,y+3,smallFont,on and C.pink or C.muted)
        txt(t,61,y,font,on and C.text or C.muted)
    end
    line(20,H-82,sidebar-20,H-82)
    txt("Offline mode",23,H-65,smallFont,C.pink); txt("Data stays on this PC",23,H-45,smallFont,C.muted)
end
local function collectAttachments()
    local out={}
    for _,key in ipairs({"events","projects","resources","missions"}) do
        for _,rec in ipairs(data[key] or {}) do
            for _,att in ipairs(rec.attachments or {}) do
                out[#out+1]={att=att,owner=rec.name or "Untitled",kind=key}
            end
        end
    end
    return out
end
local function currentSheet()
    if not data.spreadsheets then data.spreadsheets={} end
    if #data.spreadsheets==0 then
        data.spreadsheets[1]={name="New spreadsheet",rows={{"Item","Quantity","Notes"},{"","",""},{"","",""},{"","",""}}}
    end
    sheetIndex=math.max(1,math.min(sheetIndex,#data.spreadsheets))
    local sh=data.spreadsheets[sheetIndex]
    sh.rows=sh.rows or {{"","",""},{"","",""},{"","",""}}
    return sh
end
local function drawFilesPage()
    local x=sidebar+28; local y=110; local width=W-sidebar-56
    txt("Attachment browser",x,y,titleFont,C.blue)
    txt("Browse every file copied into this app, regardless of which section it belongs to.",x,y+36,smallFont,C.muted)
    fileEntries=collectAttachments()
    rect(x,184,width,38,C.palePink,C.line)
    txt(tostring(#fileEntries).." stored files",x+14,195,font,C.text)
    if #fileEntries==0 then
        rect(x,235,width,90,C.white,C.line)
        txt("No attachments yet.",x+16,254,font,C.text)
        txt("Open a project, event, resource or mission and use Add attachment.",x+16,280,smallFont,C.muted)
    else
        local maxVisible=math.floor((H-250)/58)
        for i=1,math.min(#fileEntries,maxVisible) do
            local entry=fileEntries[i]; local a=entry.att; local yy=235+(i-1)*58
            rect(x,yy,width,50,C.white,C.line)
            local img=imageFor(a)
            if img then
                local iw,ih=img:getDimensions(); local sc=math.min(36/iw,36/ih)
                love.graphics.setColor(1,1,1); love.graphics.draw(img,x+9,yy+7,0,sc,sc)
            else
                rect(x+9,yy+7,36,36,C.paleBlue,C.line); txt("FILE",x+12,yy+19,tinyFont,C.blue)
            end
            txt(short(a.label or a.filename or "Attachment",42),x+56,yy+7,font,C.text)
            txt(entry.kind.."  /  "..short(entry.owner,35).."  /  "..(a.filename or ""),x+56,yy+29,tinyFont,C.muted)
            addButton("Open",W-155,yy+10,76,30,function() openAttachment(a) end,"blue")
        end
    end
end
local function drawSheetsPage()
    local x=sidebar+28; local y=108; local width=W-sidebar-56
    local sh=currentSheet()
    txt("Editable spreadsheets",x,y,titleFont,C.blue)
    txt("Simple local tables. Click a cell, type to edit, and use the arrow keys to move.",x,y+34,smallFont,C.muted)
    addButton("+ New sheet",W-170,y,112,30,function()
        data.spreadsheets[#data.spreadsheets+1]={name="Spreadsheet "..(#data.spreadsheets+1),rows={{"Column 1","Column 2","Column 3"},{"","",""},{"","",""}}}
        sheetIndex=#data.spreadsheets; sheetRow=1; sheetCol=1; saveData()
    end,"primary")
    addButton("Add row",x,y+66,82,28,function()
        local n=#(sh.rows[1] or {}); local r={}; for c=1,n do r[c]="" end
        sh.rows[#sh.rows+1]=r; saveData()
    end,"blue")
    addButton("Add column",x+91,y+66,96,28,function()
        for _,r in ipairs(sh.rows) do r[#r+1]="" end; saveData()
    end,"blue")
    addButton("Prev sheet",x+198,y+66,88,28,function() sheetIndex=math.max(1,sheetIndex-1); sheetRow=1; sheetCol=1 end,"blue")
    addButton("Next sheet",x+294,y+66,88,28,function() sheetIndex=math.min(#data.spreadsheets,sheetIndex+1); sheetRow=1; sheetCol=1 end,"blue")
    txt(sh.name or "Spreadsheet",x+400,y+72,font,C.text)
    local gx=x; local gy=y+112; local cw=math.min(160,math.floor(width/5)); local ch=34
    local rows=math.min(#sh.rows,math.floor((H-gy-28)/ch)); local cols=math.min(#(sh.rows[1] or {}),math.floor(width/cw))
    for r=1,rows do
        for c=1,cols do
            local xx=gx+(c-1)*cw; local yy=gy+(r-1)*ch
            local chosen=(sheetRow==r and sheetCol==c)
            rect(xx,yy,cw,ch,chosen and C.palePink or (r==1 and C.paleBlue or C.white),C.line)
            local val=((sh.rows[r] or {})[c] or "")
            txt(short(val,math.max(5,math.floor(cw/7))),xx+7,yy+10,smallFont,C.text)
        end
    end
    txt("Tip: spreadsheet data is saved locally with your clan data. CSV import/export can be added next.",x,gy+rows*ch+12,tinyFont,C.muted)
end
local function drawDashboard()
    local x=sidebar+28; local y=110; local gap=14; local cw=(W-sidebar-70-gap*2)/3
    local cards={{"Members",#data.members,C.pink},{"Events",#data.events,C.blue},{"Projects",#data.projects,C.peach}}
    for i,c in ipairs(cards) do local xx=x+(i-1)*(cw+gap); rect(xx,y,cw,100,C.white,C.line); txt(c[1],xx+16,y+15,smallFont,C.muted); txt(c[2],xx+16,y+39,titleFont,c[3]) end
    local py=y+124; rect(x,py,W-sidebar-56,215,C.white,C.line); txt("Upcoming events",x+18,py+16,titleFont,C.blue)
    if #data.events==0 then txt("No events yet. Add an event to start planning.",x+18,py+66,font,C.muted)
    else for i=1,math.min(4,#data.events) do local e=data.events[i]; txt("•  "..short(e.name,42),x+20,py+58+(i-1)*32,font,C.text); txt(e.date or "No date",W-250,py+60+(i-1)*32,smallFont,C.muted) end end
    local by=py+235; rect(x,by,W-sidebar-56,130,C.white,C.line); txt("Clan leader's notes",x+18,by+15,titleFont,C.blue)
    txt("Use Projects for detailed plans, Events for attendance and prep,",x+18,by+60,smallFont,C.muted)
    txt("and Resources for quantities, files and supply spreadsheets.",x+18,by+82,smallFont,C.muted)
end
local function drawListPage(k)
    local x=sidebar+28; local y=110; local width=W-sidebar-56
    local titles={events="Events",members="Member directory",projects="Clan projects",resources="Resource tracker",missions="Missions"}
    local desc={events="Schedule clan activities, track attendance and keep event notes.",members="Your private roster, including up to three free-text server fields per player.",projects="Open a project to manage notes, tasks, images and supporting files.",resources="Track stock and requirements, with spreadsheets and supporting files.",missions="Keep objectives, rewards and notes for clan assignments."}
    txt(titles[k],x,y,titleFont,C.blue); txt(desc[k],x,y+36,smallFont,C.muted)
    addButton("+ Add new",W-170,108,112,34,function() openModal(k:sub(1,-2)) end,"primary")
    local listY=202; local items=data[k]
    if #items==0 then rect(x,listY,width,90,C.white,C.line); txt("Nothing here yet.",x+18,listY+20,font,C.text); txt("Use + Add new to create your first entry.",x+18,listY+47,smallFont,C.muted)
    else
        local maxVisible=math.floor((H-listY-25)/72)
        for i=1,math.min(#items,maxVisible) do
            local item=items[i]; local yy=listY+(i-1)*72
            local label=short(item.name,55); local detail=""
            if k=="events" then detail=(item.date or "No date").."  |  "..(item.leader or "No event leader")
            elseif k=="members" then detail=(item.role or "No role").."  |  Servers: "..table.concat(item.servers or {}," / ")
            elseif k=="projects" then detail=(item.date or "No target date").."  |  "..tostring(#(item.tasks or {})).." tasks  |  "..tostring(#(item.attachments or {})).." files"
            elseif k=="resources" then detail="Current: "..tostring(item.quantity or 0).."  |  Needed: "..tostring(item.needed or 0).."  |  "..tostring(#(item.attachments or {})).." files"
            else detail=(item.objective or "").."  |  Reward: "..(item.reward or "—") end
            rect(x,yy,width,62,C.white,C.line); txt(label,x+14,yy+8,font,C.blue); txt(short(detail,105),x+14,yy+34,smallFont,C.muted)
            addButton("Open",W-150,yy+14,72,32,function() openDetail(k,i) end,"blue")
        end
    end
end
local function drawDetail(k, rec)
    local x=sidebar+28; local y=108; local width=W-sidebar-56
    addButton("← Back",x,y,82,32,function() selected=nil; selectedKey=nil end,"blue")
    addButton("Edit",W-250,y,76,32,function() openModal(k:sub(1,-2),rec) end,"blue")
    addButton("Delete",W-164,y,82,32,deleteSelected,"peach")
    txt(rec.name or "Details",x,y+48,titleFont,C.blue)
    local top=y+90
    local leftW=math.floor(width*0.56)
    rect(x,top,leftW,120,C.white,C.line)
    local subtitle=""
    if k=="events" then subtitle="Date: "..(rec.date or "Not set").."     Leader: "..(rec.leader or "Not assigned")
    elseif k=="members" then subtitle="Role: "..(rec.role or "Not set")
    elseif k=="projects" then subtitle="Target date: "..(rec.date or "Not set")
    elseif k=="resources" then subtitle="Current: "..tostring(rec.quantity or 0).."     Needed: "..tostring(rec.needed or 0)
    else subtitle="Reward: "..(rec.reward or "Not set") end
    txt(subtitle,x+14,top+13,smallFont,C.muted)
    local desc=rec.description or rec.objective or rec.category or rec.notes or "No description added yet."
    wrapped(desc,x+14,top+40,leftW-28,smallFont,C.text,17,4)
    local rightX=x+leftW+14; local rightW=width-leftW-14
    rect(rightX,top,rightW,120,C.paleBlue,C.line); txt("Quick actions",rightX+12,top+12,smallFont,C.blue)
    if k=="members" then
        txt("Server 1: "..((rec.servers or {})[1] or "—"),rightX+12,top+38,smallFont,C.text)
        txt("Server 2: "..((rec.servers or {})[2] or "—"),rightX+12,top+59,smallFont,C.text)
        txt("Server 3: "..((rec.servers or {})[3] or "—"),rightX+12,top+80,smallFont,C.text)
    else
        addButton("Edit notes",rightX+12,top+37,rightW-24,29,function() openModal("note",rec) end,"blue")
        addButton("Add attachment",rightX+12,top+74,rightW-24,29,function() openModal("attachment",rec) end,"peach")
    end
    local sectionY=top+138
    if k=="projects" or k=="events" or k=="missions" then
        rect(x,sectionY,leftW,190,C.white,C.line); txt(k=="projects" and "Project checklist" or (k=="events" and "Event preparation" or "Mission checklist"),x+14,sectionY+12,font,C.blue)
        addButton("+ Add task",x+leftW-105,sectionY+8,91,28,function() openModal("task",rec) end,"blue")
        local tasks=rec.tasks or {}
        if #tasks==0 then txt("No tasks added yet.",x+14,sectionY+55,smallFont,C.muted)
        else for i=1,math.min(#tasks,6) do local t=tasks[i]; local yy=sectionY+49+(i-1)*22; local mark=t.done and "[x]" or "[ ]"; txt(mark.."  "..short(t.text,52),x+15,yy,smallFont,t.done and C.green or C.text); addButton(t.done and "Undo" or "Done",x+leftW-67,yy-3,53,20,function() t.done=not t.done; saveData() end,"blue") end end
    elseif k=="resources" then
        rect(x,sectionY,leftW,190,C.white,C.line); txt("Stock overview",x+14,sectionY+12,font,C.blue)
        local qty=tonumber(rec.quantity) or 0; local need=tonumber(rec.needed) or 0
        txt("Current quantity",x+14,sectionY+54,smallFont,C.muted); txt(qty,x+14,sectionY+74,titleFont,C.blue)
        txt("Target quantity",x+leftW/2,sectionY+54,smallFont,C.muted); txt(need,x+leftW/2,sectionY+74,titleFont,C.pink)
        txt("Still needed: "..math.max(0,need-qty),x+14,sectionY+126,font,C.text)
    elseif k=="members" then
        rect(x,sectionY,leftW,190,C.white,C.line); txt("Member notes",x+14,sectionY+12,font,C.blue); wrapped(rec.notes or "No notes added.",x+14,sectionY+46,leftW-28,smallFont,C.text,17,7)
    end
    local filesX=rightX; local filesW=rightW
    rect(filesX,sectionY,filesW,190,C.white,C.line); txt("Attachments",filesX+12,sectionY+12,font,C.blue)
    if k=="members" then txt("Member profiles do not need file attachments.",filesX+12,sectionY+48,smallFont,C.muted)
    else
        local at=rec.attachments or {}
        if #at==0 then txt("No files attached.",filesX+12,sectionY+48,smallFont,C.muted) end
        for i=1,math.min(#at,4) do
            local a=at[i]; local yy=sectionY+44+(i-1)*34
            local img=imageFor(a)
            if img then
                local iw,ih=img:getDimensions(); local scale=math.min(28/iw,28/ih); love.graphics.setColor(1,1,1); love.graphics.draw(img,filesX+12,yy,0,scale,scale)
            else rect(filesX+12,yy,28,26,C.paleBlue,C.line); txt("FILE",filesX+14,yy+8,tinyFont,C.blue) end
            txt(short(a.label or a.filename,math.max(10,math.floor((filesW-105)/7))),filesX+48,yy+5,smallFont,C.text)
            addButton("Open",filesX+filesW-58,yy,48,25,function() openAttachment(a) end,"blue")
        end
        if #at>4 then txt("+ "..(#at-4).." more files",filesX+12,sectionY+174,tinyFont,C.muted) end
    end
    if k=="events" then
        addButton("Edit attendees",x,sectionY+198,120,29,function() openModal("attendee",rec) end,"blue")
        txt("Attending: "..(rec.attendees or "Not recorded"),x+132,sectionY+205,smallFont,C.muted)
    end
end
local function drawModal()
    if not modal then return end
    set({0.30,0.32,0.34,0.28}); love.graphics.rectangle("fill",0,0,W,H)
    local maxFieldH=0; for _,f in ipairs(modal.fields) do maxFieldH=maxFieldH+(f.multiline and 82 or 59) end
    local mw=560; local mh=90+maxFieldH; if mh>H-50 then mh=H-50 end
    local x=(W-mw)/2; local y=(H-mh)/2
    rect(x,y,mw,mh,C.white,C.line); txt((modal.record and "Edit " or "Add ")..modal.kind,titleFont and x+22 or x+22,y+17,titleFont,C.blue)
    local fy=y+58
    for i,f in ipairs(modal.fields) do
        txt(f.label,x+22,fy,smallFont,C.muted)
        local h=f.multiline and 56 or 31
        rect(x+22,fy+18,mw-44,h,C.bg,modal.focus==i and C.pink or C.line)
        local value=f.value or ""
        if f.multiline then
            local lines={}; for ln in (value.."\n"):gmatch("(.-)\n") do lines[#lines+1]=ln end
            for j=math.max(1,#lines-2),#lines do txt(lines[j],x+31,fy+23+(j-math.max(1,#lines-2))*15,smallFont,C.text) end
        else txt(value..(modal.focus==i and "_" or ""),x+31,fy+25,font,C.text) end
        fy=fy+(f.multiline and 82 or 59)
    end
    local by=y+mh-43
    addButton("Save",x+22,by,105,30,addRecord,"primary")
    addButton("Cancel",x+139,by,105,30,function() modal=nil end,"blue")
    txt("Tab: next field  |  Enter: save  |  Esc: cancel",x+265,by+8,tinyFont,C.muted)
end

function love.draw()
    W,H=love.graphics.getDimensions(); set(C.bg); love.graphics.rectangle("fill",0,0,W,H); buttons={}
    drawSidebar(); drawHeader()
    if active=="Dashboard" then drawDashboard()
    elseif active=="Files" then drawFilesPage()
    elseif active=="Sheets" then drawSheetsPage()
    else
        local k=keyForTab()
        if selected and selectedKey==k and data[k][selected] then drawDetail(k,data[k][selected]) else selected=nil; selectedKey=nil; drawListPage(k) end
    end
    if noticeTimer>0 then rect(W-250,H-48,220,30,C.palePink,C.line); txt(notice,W-238,H-40,smallFont,C.text) end
    drawModal()
end
function love.mousepressed(x,y,b)
    if b~=1 then return end
    if modal then
        -- Modal buttons are drawn last; test their current geometry.
        local maxFieldH=0; for _,f in ipairs(modal.fields) do maxFieldH=maxFieldH+(f.multiline and 82 or 59) end
        local mw=560; local mh=math.min(90+maxFieldH,H-50); local mx=(W-mw)/2; local my=(H-mh)/2; local by=my+mh-43
        if x>=mx+22 and x<=mx+127 and y>=by and y<=by+30 then addRecord(); return end
        if x>=mx+139 and x<=mx+244 and y>=by and y<=by+30 then modal=nil; return end
        local fy=my+58
        for i,f in ipairs(modal.fields) do
            local h=f.multiline and 56 or 31
            if x>=mx+22 and x<=mx+mw-22 and y>=fy+18 and y<=fy+18+h then modal.focus=i; return end
            fy=fy+(f.multiline and 82 or 59)
        end
        return
    end
    if x<sidebar then
        for i,t in ipairs(tabs) do local yy=108+(i-1)*43; if y>=yy-7 and y<=yy+32 then active=t; selected=nil; selectedKey=nil; return end end
    end
    if active=="Sheets" and not modal then
        local x0=sidebar+28; local gy=108+112; local cw=math.min(160,math.floor((W-sidebar-56)/5)); local ch=34
        local sh=currentSheet()
        local r=math.floor((y-gy)/ch)+1; local c=math.floor((x-x0)/cw)+1
        if y>=gy and r<=#sh.rows and x>=x0 and c<=#(sh.rows[1] or {}) then
            sheetRow=r; sheetCol=c; sheetTyping=true; return
        end
    end
    for i=#buttons,1,-1 do local binfo=buttons[i]; if x>=binfo.x and x<=binfo.x+binfo.w and y>=binfo.y and y<=binfo.y+binfo.h then if binfo.fn then binfo.fn() end; return end end
end
function love.filedropped(file)
    if not selectedKey or not selected or not data[selectedKey] or not data[selectedKey][selected] then
        notify("Open an entry first, then drop a file onto it")
        return
    end
    local rec=data[selectedKey][selected]
    local name=file:getFilename() or "dropped_file"
    local safe=name:gsub("[^%w%._%-]","_")
    local folder="attachments"; love.filesystem.createDirectory(folder)
    local stored=folder.."/"..tostring(os.time()).."_"..safe
    local ok=love.filesystem.write(stored,file:getString())
    if not ok then notify("Could not save dropped file"); return end
    rec.attachments=rec.attachments or {}
    rec.attachments[#rec.attachments+1]={label=name,filename=name,file=stored}
    saveData()
    notify("Attachment added: "..name)
end
function love.textinput(t)
    if modal then local f=modal.fields[modal.focus]; if f then f.value=(f.value or "")..t end
    elseif active=="Sheets" and sheetTyping then
        local sh=currentSheet(); sh.rows[sheetRow]=sh.rows[sheetRow] or {}
        local old=sh.rows[sheetRow][sheetCol] or ""
        sh.rows[sheetRow][sheetCol]=old..t
    end
end
function love.keypressed(key)
    if not modal and active=="Sheets" and sheetTyping then
        local sh=currentSheet()
        if key=="backspace" then local v=sh.rows[sheetRow][sheetCol] or ""; sh.rows[sheetRow][sheetCol]=removeLastUtf8Char(v); return
        elseif key=="return" or key=="kpenter" or key=="down" then sheetRow=math.min(#sh.rows,sheetRow+1); return
        elseif key=="up" then sheetRow=math.max(1,sheetRow-1); return
        elseif key=="left" then sheetCol=math.max(1,sheetCol-1); return
        elseif key=="right" or key=="tab" then sheetCol=math.min(#(sh.rows[1] or {}),sheetCol+1); return
        elseif key=="escape" then sheetTyping=false; saveData(); return end
    end
    if modal then
        local f=modal.fields[modal.focus]
        if key=="escape" then modal=nil
        elseif key=="tab" then modal.focus=modal.focus%#modal.fields+1
        elseif key=="backspace" and f then f.value=removeLastUtf8Char(f.value)
        elseif key=="return" or key=="kpenter" then
            if f and f.multiline and love.keyboard.isDown("lshift","rshift") then f.value=(f.value or "").."\n" else addRecord() end
        end
    elseif key=="escape" then if selected then selected=nil; selectedKey=nil else active="Dashboard" end end
end
function love.update(dt) if noticeTimer>0 then noticeTimer=noticeTimer-dt end end
function love.quit() saveData() end
