--[[
----------------------------------------------------------
GPT.lua - ChatGPT Interface for Computercraft Computers
----------------------------------------------------------

Author: Connor J. Swislow
License: Unlicense (public domain dedication)

Description:
GPT.lua is a Lua script designed for Computercraft computers, providing an interface to interact with the OpenAI ChatGPT API. It allows users to have interactive conversations with the language model using a simple chat-based system.

Requirements:
- OpenAI API key: To use this program, you need to have an OpenAI API key. Make sure to obtain one before running the script.
- Computercraft: This script is designed to run within the Computercraft mod for Minecraft. Ensure that you have Computercraft installed and running on your Minecraft server or local game.

Installation:
1. Open a Computercraft computer in your Minecraft world.
2. Run the following command to download the GPT.lua script from Pastebin:
   pastebin get Zry5i7qh startup
3. Restart the Computercraft computer to initialize the program.

Usage:
1. After the program has been installed and the computer has restarted, it will prompt you to enter your OpenAI API key.
2. Paste your API key when prompted. This step is required to authenticate your access to the OpenAI ChatGPT API.
3. Once the API key is set, the program will display a randomly chosen title for the chatbot.
4. Type your messages to have a conversation with the chatbot. Type 'exit' to exit the program.
5. The chatbot will respond to your messages based on the conversation history and the underlying language model.
6. Enjoy interacting with the ChatGPT-powered chatbot!

Note:
- This script is dependent on an internet connection to communicate with the OpenAI ChatGPT API.
- Use the GPT-3.5 Turbo model for generating responses. Adjust the 'model' variable in the script if you want to use a different model.

Credits:
This program is based on the OpenAI GPT-3.5 language model and was created by Connor J. Swislow.

Website:
https://github.com/ConnorSwis/GPT.lua

----------------------------------------------------------
--]]

-- Define utility functions for common operations
Utility = {
    -- Splits a string into a table by a specified separator
    split = function(inputstr, sep)
        sep = sep or '%s' -- Default separator is whitespace
        local t = {}
        for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
            table.insert(t, field)
            if s == "" then return t end
        end
    end,

    -- Converts a string to a table of byte values
    toByteString = function(s)
        local byteString = {}
        for i = 1, #s do
            byteString[i] = string.byte(s, i)
        end
        return byteString
    end,
}

-- Cryptography functions for encryption and decryption
Crypt = {
    MAGIC_STRING = "*dU2$uj)82@:>w`", -- A unique string to verify encryption
    -- XOR encryption/decryption
    xor = function(text, key)
        local textBytes = Utility.toByteString(text)
        local keyBytes = Utility.toByteString(key)
        local resultBytes = {}
        for i = 1, #textBytes do
            local keyByte = keyBytes[((i - 1) % #keyBytes) + 1]
            resultBytes[i] = bit32.bxor(textBytes[i], keyByte)
        end
        -- Convert back to string
        local result = {}
        for i, v in ipairs(resultBytes) do
            result[i] = string.char(v)
        end
        return table.concat(result)
    end,
    -- Appends magic string, then encrypts
    encrypt = function(text, key)
        text = text .. Crypt.MAGIC_STRING
        return Crypt.xor(text, key)
    end,
    -- Decrypts and verifies the magic string
    decrypt = function(encryptedText, key)
        local decryptedTextWithMagic = Crypt.xor(encryptedText, key)
        if decryptedTextWithMagic:sub(- #Crypt.MAGIC_STRING) == Crypt.MAGIC_STRING then
            return true, decryptedTextWithMagic:sub(1, - #Crypt.MAGIC_STRING - 1)
        else
            return false, nil
        end
    end
}

-- Screen utilities for terminal management
Screen = {
    -- Clears the terminal screen and resets cursor position
    clear = function()
        term.clear()
        term.setCursorPos(1, 1)
    end,
    -- Prints text in specified color then resets to white
    print_color = function(text, color)
        assert(type(text) == "string")
        term.setTextColor(color)
        write(text)
        term.setTextColor(colors.white)
    end,
    -- Parses and prints colored text based on custom tags
    print_colored_text = function(data)
        assert(type(data) == "string", "Input must be a string")

        local pattern = "(%b{})"
        local last_end = 1

        for text, color_code, rest in data:gmatch("({(.-)}(.-){/%2})") do
            local pre_text = data:sub(last_end, data:find(pattern, last_end) - 1)
            if #pre_text > 0 then
                Screen.print_color(pre_text, colors.white)
            end
            local color = colors[color_code]
            if color then
                Screen.print_color(rest, color)
            else
                Screen.print_color(rest, colors.white)
            end
            last_end = data:find(pattern, last_end) + #text
        end

        if last_end <= #data then
            Screen.print_color(data:sub(last_end), colors.white)
        end
    end,
    -- Prints each character in a random color
    print_with_random_colors = function(data)
        assert(type(data) == "string")
        for char in data:gmatch(".") do
            Screen.print_color(char, 2 ^ math.random(0, 14))
        end
    end,
    -- Prints words gradually with a delay
    gradual_print = function(data)
        assert(type(data) == "string")
        for word in data:gmatch("%S+") do
            write(word .. " ")
            sleep((math.random() / 3))
        end
        write("\n")
    end
}

-- Settings management for configuration
Settings = {
    set = function(name, value)
        name = "gpt." .. name
        settings.set(name, value)
        settings.save()
    end,
    get = function(name)
        name = "gpt." .. name
        return settings.get(name)
    end,
    init = function(name, default)
        local value = Settings.get(name)
        if value == nil then
            Settings.set(name, default)
            return default
        else
            return value
        end
    end,
    default_settings = {
        model = "gpt-3.5-turbo",
        maxTokens = 150,
        saveDir = "./saves"
    }
}

-- Controller for handling command logic
local controller = {
    help = function(...)
        if ... == nil or #... == 0 then
            local sorted_commands = {}
            for key, _ in pairs(Commands) do
                table.insert(sorted_commands, key)
            end
            table.sort(sorted_commands)
            for _, key in ipairs(sorted_commands) do
                local val = Commands[key]
                Screen.print_color("/" .. key, colors.lime)
                write(" - " .. val.brief .. "\n")
            end
        else
            local args = table.pack(...)[1]
            local command = Commands[args[1]]
            if command then
                Screen.print_colored_text(command.description .. "\n")
            else
                write("Command not found.\n")
            end
        end
    end,
    exit = function()
        error("Goodbye.", 0)
    end,
    clear = Screen.clear,
    new = function()
        Messages = {}
        Screen.clear()
        write("New conversation started.\n")
    end,
    save = function(name)
        local saveDir = Settings.get("saveDir")
        if not fs.exists(saveDir) then fs.makeDir(saveDir) end
        name = name[1] or string.sub(textutils.formatTime(os.epoch()), 1, -9)
        local fp = fs.combine(saveDir, name .. ".txt")
        local result = ""
        for i = 1, #Messages do
            result = result .. Messages[i].role ..
                ": " .. Messages[i].content .. "\n" .. "#/<#>/#\n"
        end
        local file = fs.open(fp, "w")
        file.write(result)
        file.close()
        write("Conversation saved to " .. fp .. "\n")
    end,
    load = function(...)
        local saveDir = Settings.get("saveDir")
        local files = fs.list(saveDir)
        local args = table.pack(...)[1]
        local index = args[1]
        if index == nil then
            for i, file in ipairs(files) do
                Screen.print_colored_text(
                    "[{lime}" .. tostring(i) ..
                    "{/lime}]: " .. file .. "\n"
                )
            end
            return
        end
        index = tonumber(index)
        local fp = fs.combine(saveDir, files[index])
        local file = fs.open(fp, "r")
        local lines = file.readAll()
        file.close()
        Messages = {}
        Screen.clear()
        -- Split the input string into chunks based on the delimiter
        local pattern = "(.-): ([^#]-)#/<#>/#"
        for role, content in lines:gmatch(pattern) do
            local message = {
                role = role:match("^%s*(.-)%s*$"),
                content = content:match("^%s*(.-)%s*$")
            }
            table.insert(Messages, message)
            local prefix = role == "user" and
                "{magenta}[Me]{/magenta}: " or
                "{lime}[GPT]{/lime}: "
            Screen.print_colored_text(prefix .. content .. "\n")
        end
    end,
    settings = function(...)
        local args = table.pack(...)[1]
        local subcommand
        if args[1] == nil or #args == 0 then
            subcommand = "list"
        else
            subcommand = args[1]
        end
        if Settings.default[subcommand] then
            write(subcommand .. ": " .. Settings.get(subcommand) .. "\n")
            return
        end
        if subcommand == "list" then
            for setting, _ in pairs(Settings.default) do
                write(setting .. ": " .. Settings.get(setting) .. "\n")
            end
            return
        end
        if subcommand == "set" then
            local setting = args[2]
            local value = args[3]
            if setting == nil then
                write("Please specify setting.\n")
                return
            end
            if value == nil then
                write("Please specify value.\n")
                return
            end
            if not Settings.default[setting] then
                write("Invalid setting.\n")
                return
            end
            Settings.set(setting, value)
            return
        end
        if subcommand == "reset" or
            subcommand == "clear" or
            subcommand == "default" then
            local setting = args[2]
            if setting == nil then
                write("Please specify setting.\n")
                return
            end
            if not Settings.default[setting] then
                write("Invalid setting.\n")
                return
            end
            Settings.set(setting, Settings.default[setting])
            return
        end
    end,
}

-- Command descriptions
local descriptions = {
    exit = "Stops the program.",
    clear = "Clears the screen.",
    new = "Starts a new conversation.",
    save = [[
{lime}/save{/lime} {green}[name]{/green}
- {green}[name]{/green}: Optional. Default is the current timestamp.
{blue}Description:{/blue}
- Saves current conversation to dir specified in {lightGray}saveDir{/lightGray} setting.
{blue}Examples:{/blue}
- Save the chat with a custom name:
  {lime}/save{/lime}{green} my_chat_session{/green}
- Save the chat with a timestamped name:
  {lime}/save{/lime}
]],

    load = [[
{lime}/load{/lime} {green}[index]{/green}
- {green}[index]{/green}: Optional. Index of the file to load.
{blue}Description:{/blue}
- Lists all saved conversations if no index is specified.
- Loads a conversation from a file.
{blue}Examples:{/blue}
- List all saved conversations:
  {lime}/load{/lime}
- Load a conversation from a file (e.g., index 1):
  {lime}/load{/lime} {green}1{/green}
]],

    help = [[
{lime}/help{/lime} {green}[command]{/green}
- {green}[command]{/green}: Optional. Specifies the command to display detailed help for.
{blue}Description:{/blue}
- Without arguments, lists all available commands and their brief descriptions.
- With a command name as an argument, shows detailed help for that command.
{blue}Examples:{/blue}
- Display a list of all commands:
  {lime}/help{/lime}
- Show detailed help for a specific command (e.g., {lime}save{/lime}):
  {lime}/help{/lime} {green}save{/green}
]],

    settings = [[
{lime}/settings{/lime} {green}[subcommand]{/green} {green}[setting]{/green} {green}[value]{/green}
- {green}[subcommand]{/green}: Optional. Default is {lime}list{/lime}.
- {green}[setting]{/green}: Optional. Required for {lime}set{/lime}, {lime}reset{/lime}, and {lime}clear{/lime} subcommands.
- {green}[value]{/green}: Optional. Required for {lime}set{/lime} subcommand.
{blue}Description:{/blue}
- Without arguments, lists all settings and their values.
- With a subcommand, performs the specified action.
{blue}Subcommands:{/blue}
- {lime}list{/lime}: Lists all settings and their values.
- {lime}set{/lime}: Sets a setting to a value.
- {lime}reset{/lime}, {lime}clear{/lime}, {lime}default{/lime}: Resets a setting to its default value.
{blue}Examples:{/blue}
- Display a list of all settings:
  {lime}/settings{/lime}
- Set a setting (e.g., {lightGray}model{/lightGray}):
  {lime}/settings{/lime} {lime}set{/lime} {lightGray}model{/lightGray} {green}gpt-3.5-turbo{/green}
- Reset a setting (e.g., {lightGray}model{/lightGray}):
  {lime}/settings{/lime} {lime}reset{/lime} {lightGray}model{/lightGray}
]]
}

Commands = {
    help = {
        brief = "Get commands and command info.",
        description = descriptions.help,
        dispatch = controller.help
    },
    exit = {
        brief = "Stops the program.",
        description = descriptions.exit,
        dispatch = controller.exit
    },
    clear = {
        brief = "Clears the screen.",
        description = descriptions.clear,
        dispatch = controller.clear
    },
    new = {
        brief = "Starts a new conversation.",
        description = descriptions.new,
        dispatch = controller.new
    },
    save = {
        brief = "Saves the current conversation to a file.",
        description = descriptions.save,
        dispatch = controller.save
    },
    load = {
        brief = "Loads a conversation from a file.",
        description = descriptions.load,
        dispatch = controller.load
    },
    settings = {
        brief = "Sets a setting.",
        description = descriptions.settings,
        dispatch = controller.settings
    },
}

Messages = {} -- Store user and system messages

-- Program titles
local titles = {
    "  _   _   _   _   _   _   _\n / \\ / \\ / \\ / \\ / \\ / \\ / \\\n| G | P | T | . | l | u | a |\n \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/\n",
    "  ___  ____  ____    __    _  _   __\n / __)(  _ \\(_  _)  (  )  / )( \\ / _\\\n( (_ \\ ) __/  )(  _ / (_/\\) \\/ (/    \\\n \\___/(__)   (__)(_)\\____/\\____/\\_/\\_/\n",
    "  __  ______\n / _ /__)/     /  _\n(__)/   (    .((/(/\n",
    " ___   ___   ___\n|     |   |   |       |\n| +-  |-+-    +       +         -\n|   | |       |       |   | |  | |\n ---               -  ---  --   --\n",
    " ___ ___ _____ _\n/ __| _ \\_   _| |_  _ __ _\n|(_ |  _/ | |_| | || / _` |\n\\___|_|   |_(_)_|\\_,_\\__,_|\n",
    "   __________  ______   __\n  / ____/ __ \\/_  __/  / /_  ______ _\n / / __/ /_/ / / /    / / / / / __ `/\n/ /_/ / ____/ / /  _ / / /_/ / /_/ /\n\\____/_/     /_/  (_)_/\\__,_/\\__,_/\n",
    "  ________  ______  __\n / ___/ _ \\/_  __/ / /_ _____ _\n/ (_ / ___/ / / _ / / // / _ `/\n\\___/_/    /_/ (_)_/\\_,_/\\_,_/\n",
    "  ____ ____ _____ _\n / ___|  _ \\_   _| |_   _  __ _\n| |  _| |_) || | | | | | |/ _` |\n| |_| |  __/ | |_| | |_| | (_| |\n \\____|_|    |_(_)_|\\__,_|\\__,_|\n",
    "  _____________________________  .__\n /  _____/\\______   \\__    ___/  |  |  __ _______   \n/   \\  ___ |     ___/ |    |     |  | |  |  \\__  \\  \n\\    \\_\\  \\|    |     |    |     |  |_|  |  // __ \\\n \\______  /|____|     |____|    /\\____/____/(____ /\n        \\/                      \\/              \\/\n",
    " .--. .---. .-----.  .-.\n: .--': .; :`-. .-'  : :\n: : _ :  _.'  : :    : :  .-..-. .--.\n: :; :: :     : :  _ : :_ : :; :' .; ;\n`.__.':_;     :_; :_;`.__;`.__.'`.__,_;\n",
    " /~~\\|~~\\~~|~~ |\n | __|__/  |   ||   |/~~|\n \\__/|     |  .| \\_/|\\__|\n",
    ".|'''''| '||'''|, |''||''|    '||`\n|| .      ||   ||    ||        ||\n|| |''||  ||...|'    ||        ||  '||  ||`  '''|.\n||    ||  ||         ||        ||   ||  ||  .|''||\n`|....|' .||        .||.   .. .||.  `|..'|. `|..||.\n",
    " ___ _______   _\n ))_ ))_)))    )) _    ___\n((_(((  ((  o (( ((_( ((_(\n",
    "   __   ___  _____\n ,'_/  / o |/_  _/  /7     _\n/ /_n / _,'  / /   ///7/7,'o|\n|__,'/_/    /_/() ///__/ |_,7\n",
    " ___   ___  ___    _\n/  _> | . \\|_ _|  | | _ _  ___\n| <_/\\|  _/ | | _ | || | |<_> \n`____/|_|   |_|<_>|_|`___|<___\n",
    " _______ _______ _______    __\n|   _   |   _   |       |  |  .--.--.---.-.\n|.  |___|.  1   |.|   | |__|  |  |  |  _  |\n|.  |   |.  ____`-|.  |-|__|__|_____|___._|\n|:  1   |:  |     |:  |\n|::.. . |::.|     |::.|\n`-------`---'     `---'\n",
    "____ ___  ___  _    _  _ ____\n| __ |__]  |   |    |  | |__|\n|__] |     |  .|___ |__| |  |\n",
    " __  __  ___\n[ __[__)  |     |. . _.\n[_./|     |   * |(_|(_]\n",
    " .d8888b.  8888888b. 888888888 888\nd88P  Y88b 888   Y88b   888    888\n888    888 888    888   888    888\n888        888   d88P   888    888 888  888 8888b.\n888  88888 8888888P\"    888    888 888  888    \"88b\n888    888 888          888    888 888  888.d888888\nY88b  d88P 888          888 db 888 Y88b 888888  888\n \"Y8888P88 888          888 YP 888 \"Y88888\"Y888888\n",
    "_______ ______ _______  __\n|     __|   __ \\_     _||  |.--.--.---.-.\n|    |  |    __/ |   |__|  ||  |  |  _  |\n|_______|___|    |___|__|__||_____|___._|\n",
    "  _____ _____ _______ _\n / ____|  __ \\__   __| |\n| |  __| |__) | | |  | |_   _  __ _\n| | |_ |  ___/  | |  | | | | |/ _` |\n| |__| | |      | | _| | |_| | (_| |\n \\_____|_|      |_|(_)_|\\__,_|\\__,_|\n",
    " ## ##  ###      #\n#   # #  #       #  # #  ##\n# # ##   #       #  # # # #\n# # #    #       ## ### ###\n ## #    #   #\n" }
local title = titles[math.random(1, #titles)] -- Select a random title

-- Main program function
function Main()
    -- Clear the screen at the start
    Screen.clear()

    -- Initialize settings with default values if not already set
    for setting, default in pairs(Settings.default_settings) do
        Settings.init(setting, default)
    end

    local OPENAI_KEY -- Variable to store the OpenAI API key

    -- Attempt to retrieve an encrypted API key from settings
    local encryptedKey = Settings.get("apiKey")
    if encryptedKey ~= nil then
        -- Prompt user for password to decrypt the API key
        write("Enter your password:\n> ")
        local password = read("*")
        local success, decryptedKey = Crypt.decrypt(encryptedKey, password)
        if success then
            OPENAI_KEY = decryptedKey
        else
            error("Decryption failed. Wrong password.", 0)
        end
    else
        -- No API key found, prompt user to enter it
        write(
            "No OpenAI API key found.\nYour API key will be encrypted using a password.\nThe password will not be stored.\n")
        write("Please enter your OpenAI API key:\n> ")
        local apiKey = read("*")

        -- Prompt for a password and confirm it
        local password
        repeat
            write("Enter a password:\n> ")
            password = read("*")
            write("Confirm password:\n> ")
            local confirmKey = read("*")
            if password ~= confirmKey then
                write("Passwords do not match. Please try again.\n")
            end
        until password == confirmKey

        -- Encrypt and save the API key
        Settings.set("apiKey", Crypt.encrypt(apiKey, password))
        OPENAI_KEY = apiKey
    end

    -- Display the chatbot title with random colors if not a pocket computer
    if not pocket then
        Screen.print_with_random_colors(title)
    end
    Screen.print_colored_text("{lime}/help{/lime} to see commands.\n")

    -- Main loop to process user input
    while true do
        Screen.print_colored_text("{magenta}[Me]{/magenta}: ")
        local userInput = read()

        -- Check if the input is a command
        if string.sub(userInput, 1, 1) == "/" then
            local commandParts = Utility.split(userInput:sub(2), " ")
            if commandParts and Commands[commandParts[1]] then
                -- Extract arguments and dispatch the command
                local args = { table.unpack(commandParts, 2) }
                Commands[commandParts[1]].dispatch(args)
            else
                -- If command not found, show help
                Commands["help"].dispatch()
            end
            goto continue -- Skip the rest of the loop to prompt for new input
        end

        -- Process and send user input to the OpenAI API
        -- Add user message to the history
        table.insert(Messages, { role = "user", content = userInput })

        -- Prepare and send the API request
        local payload = textutils.serializeJSON({
            model = Settings.get("model"),
            max_tokens = Settings.get("maxTokens"),
            messages = Messages
        })

        -- HTTP headers including the OpenAI API key
        local headers = {
            ["Authorization"] = "Bearer " .. OPENAI_KEY,
            ["Content-Type"] = "application/json"
        }

        -- Send the HTTP request
        http.request("https://api.openai.com/v1/chat/completions", payload, headers)

        -- Await and process the response
        local isRequesting = true
        Screen.print_colored_text("{lime}[GPT]{/lime}: ")
        while isRequesting do
            write(".")
            local event, url, handle = os.pullEvent()
            if event == "http_success" then
                local response = handle.readAll()
                handle.close()

                -- Parse and display the response
                local responseJson = textutils.unserializeJSON(response)
                if responseJson and responseJson.choices and responseJson.choices[1] then
                    local reply = responseJson.choices[1].message.content
                    table.insert(Messages, { role = "system", content = reply })

                    -- Print the response
                    local _, y = term.getCursorPos()
                    term.setCursorPos(1, y)
                    term.clearLine()
                    Screen.print_colored_text("{lime}[GPT]{/lime}: ")
                    Screen.gradual_print(reply)
                else
                    error("Error: Invalid API response.", 0)
                end
                isRequesting = false
            elseif event == "http_failure" then
                error("Server response error.", 0)
                isRequesting = false
            end
        end

        ::continue::
    end
end

Main() -- Execute the main function
