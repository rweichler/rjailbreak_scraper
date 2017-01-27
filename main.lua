local json = require 'dkjson'

local output_filename = '/home/freebsd/www/rjailbreak.html'
local existing_contents

function main()
    existing_contents = readAll(output_filename)

    local url = "'https://www.reddit.com/r/jailbreak/new.json'"
    local jsonstr = os.capture('curl '..url..' -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36"')
    local listing, pos, err = json.decode(jsonstr, 1)

    if err then
        print(err)
        return
    end

    local posts = listing.data.children

    for i,v in ipairs(posts) do
        process_post(v.data.title, v.data.url, v.data.created)
    end

    local f = io.open(output_filename, 'w')
    f:write(existing_contents)
    f:close()
end

local good_words = {
    '%[release%]',
    '%[upcoming%]',
    '%[news%]',
    '%[update%]',
    '%[beta%]',
}

function process_post(title, url, time)
    local lower = string.lower(title)
    local found = false
    for i,v in ipairs(good_words) do
        if string.find(lower, v) then
            found = true
            break
        end
    end
    if not found then
        print('BAD '..title)
    elseif string.find(existing_contents, url) then
        print('IGNORING '..title)
    else
        print('APPENDING '..title)
        local date = os.date('%B %d, %Y (%I:%M %p)', time)
        existing_contents = date..' <a href="'..url..'">'..title..'</a><br/>\n'..existing_contents
    end
end

function os.capture(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return s
end

function readAll(file)
    local f = io.open(file, "rb")
    if not f then return '' end
    local content = f:read("*all")
    f:close()
    return content
end

main()
