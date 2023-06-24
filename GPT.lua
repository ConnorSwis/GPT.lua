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
   pastebin get EBC4kph7 startup
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

----------------------------------------------------------
--]]

-- Set the OpenAI API key and other configurations
local OPENAI_KEY = settings.get("OPENAI_KEY") -- Retrieve the OpenAI key from the settings
local maxTokens = 100 -- Maximum number of tokens for API completion
local model = "gpt-3.5-turbo" -- Language model to use

-- If no OpenAI key is found, prompt the user to enter it
if not OPENAI_KEY then
    io.write("No OpenAI key detected.\nPlease paste your key:\n> ")
    OPENAI_KEY = io.read()
    settings.set("OPENAI_KEY", OPENAI_KEY)
    settings.save()
    term.clear()
end

-- Program titles
local titles =
    {"  _   _   _   _   _   _   _\n / \\ / \\ / \\ / \\ / \\ / \\ / \\\n| G | P | T | . | l | u | a |\n \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/\n",
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
     " ## ##  ###      #\n#   # #  #       #  # #  ##\n# # ##   #       #  # # # #\n# # #    #       ## ### ###\n ## #    #   #\n"}
local title = titles[math.random(1, #titles)] -- Select a random title

-- Set up API endpoint and headers
local endpoint = "https://api.openai.com/v1/chat/completions"
local headers = {
    ["Authorization"] = "Bearer " .. OPENAI_KEY,
    ["Content-Type"] = "application/json"
}

-- Function to print text with a specified color
local function print_with_color(data, color)
    assert(type(data) == "string")
    term.setTextColor(color)
    io.write(data)
    term.setTextColor(colors.white)
end

-- Function to print text with random colors for each character
local function print_with_random_colors(data)
    assert(type(data) == "string")
    for char in data:gmatch(".") do
        print_with_color(char, 2 ^ math.random(0, 14))
    end
end

-- Function to gradually print text word by word
local function gradual_print(data)
    assert(type(data) == "string")
    for word in data:gmatch("%S+") do
        io.write(word .. " ")
        sleep(math.random(0.05, 0.2))
    end
    io.write("\n")
end

-- Print the chatbot title with random colors
print_with_random_colors(title)
print("\nType 'exit' to exit.\n")

local messages = {} -- Store user and system messages

while true do
    print_with_color("[Me]: ", colors.magenta)
    local prompt = io.read()

    if prompt == "exit" then
        break -- Exit the loop if the user types 'exit'
    end

    -- Add user message to the messages table
    table.insert(messages, {
        role = "user",
        content = prompt
    })

    -- Prepare the payload as JSON for the API request
    local payloadJson = textutils.serializeJSON({
        ["model"] = model,
        ["max_tokens"] = maxTokens,
        ["messages"] = messages
    })

    local requesting = true
    -- Send an HTTP POST request to the OpenAI API endpoint
    http.request(endpoint, payloadJson, headers)

    while requesting do
        local event, url, sourceText = os.pullEvent()

        if event == "http_success" then
            local responseBody = sourceText.readAll()
            sourceText.close()

            -- Parse the JSON response from the API
            local responseJson = textutils.unserializeJSON(responseBody)

            if responseJson and responseJson.choices and responseJson.choices[1] then
                local generatedText = responseJson.choices[1].message.content

                -- Add system-generated message to the messages table
                table.insert(messages, {
                    role = "system",
                    content = generatedText
                })

                print_with_color("[GPT]: ", colors.lime)
                gradual_print(generatedText)
            else
                print("Error: Failed to get a valid response.")
            end

            requesting = false -- Stop the loop, response received
        elseif event == "http_failure" then
            print("Server didn't respond.")
            requesting = false -- Stop the loop, server failure
        end
    end
end