-- Small JSON encoder/decoder. No external libraries required.
local json = {}

local function escape(s)
    return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
        local map = {['"']='\\"', ['\\']='\\\\', ['\b']='\\b', ['\f']='\\f',
                     ['\n']='\\n', ['\r']='\\r', ['\t']='\\t'}
        return map[c] or string.format("\\u%04x", c:byte())
    end) .. '"'
end

local function is_array(t)
    local n = 0
    for k in pairs(t) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then return false end
        if k > n then n = k end
    end
    for i = 1, n do if t[i] == nil then return false end end
    return true, n
end

function json.encode(v)
    local kind = type(v)
    if v == nil then return "null"
    elseif kind == "boolean" or kind == "number" then return tostring(v)
    elseif kind == "string" then return escape(v)
    elseif kind == "table" then
        local arr, n = is_array(v)
        local out = {}
        if arr then
            for i=1,n do out[#out+1] = json.encode(v[i]) end
            return "[" .. table.concat(out, ",") .. "]"
        else
            for k,val in pairs(v) do
                if type(k) == "string" then
                    out[#out+1] = escape(k) .. ":" .. json.encode(val)
                end
            end
            return "{" .. table.concat(out, ",") .. "}"
        end
    end
    error("Unsupported JSON type: " .. kind)
end

function json.decode(str)
    local i, len = 1, #str
    local function ws()
        while i <= len and str:sub(i,i):match("%s") do i=i+1 end
    end
    local parse_value
    local function parse_string()
        i=i+1
        local out={}
        while i<=len do
            local c=str:sub(i,i)
            if c=='"' then i=i+1; return table.concat(out) end
            if c=="\\" then
                i=i+1
                local e=str:sub(i,i)
                local map={['"']='"',['\\']='\\',['/']='/',['b']='\b',['f']='\f',['n']='\n',['r']='\r',['t']='\t'}
                if e=="u" then
                    local hex=str:sub(i+1,i+4)
                    local cp=tonumber(hex,16)
                    if cp then
                        if cp<128 then out[#out+1]=string.char(cp)
                        elseif cp<2048 then out[#out+1]=string.char(192+math.floor(cp/64),128+cp%64)
                        else out[#out+1]=string.char(224+math.floor(cp/4096),128+math.floor(cp/64)%64,128+cp%64) end
                    end
                    i=i+4
                else out[#out+1]=map[e] or e end
            else out[#out+1]=c end
            i=i+1
        end
        error("Unterminated JSON string")
    end
    local function parse_array()
        i=i+1; ws()
        local out={}
        if str:sub(i,i)==']' then i=i+1; return out end
        while true do
            out[#out+1]=parse_value(); ws()
            local c=str:sub(i,i); i=i+1
            if c==']' then return out elseif c~=',' then error("Expected comma in array") end
            ws()
        end
    end
    local function parse_object()
        i=i+1; ws()
        local out={}
        if str:sub(i,i)=='}' then i=i+1; return out end
        while true do
            if str:sub(i,i)~='"' then error("Expected object key") end
            local key=parse_string(); ws()
            if str:sub(i,i)~=':' then error("Expected colon") end
            i=i+1; ws(); out[key]=parse_value(); ws()
            local c=str:sub(i,i); i=i+1
            if c=='}' then return out elseif c~=',' then error("Expected comma in object") end
            ws()
        end
    end
    parse_value=function()
        ws()
        local c=str:sub(i,i)
        if c=='"' then return parse_string()
        elseif c=='{' then return parse_object()
        elseif c=='[' then return parse_array()
        elseif str:sub(i,i+3)=="true" then i=i+4; return true
        elseif str:sub(i,i+4)=="false" then i=i+5; return false
        elseif str:sub(i,i+3)=="null" then i=i+4; return nil
        else
            local token=str:sub(i):match("^-?%d+%.?%d*[eE]?[+-]?%d*")
            if not token or token=="" then error("Invalid JSON value at " .. i) end
            i=i+#token; return tonumber(token)
        end
    end
    local result=parse_value(); ws()
    if i<=len then error("Trailing JSON data") end
    return result
end

return json
