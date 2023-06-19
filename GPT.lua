--[[
    Program Name: OpenAI Chatbot
    Version: 1.0
    Description: This program demonstrates a chatbot that interacts with the OpenAI API using the GPT-3.5 Turbo model. It allows users to have conversations with the chatbot by sending user messages and receiving model-generated responses.

    Author: Connor J. Swislow
    Created: 6/18/2023
    Last Modified: 6/18/2023
    License: This program is released under the Unlicense (http://unlicense.org). You can use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, free of charge, without any restrictions or requirements.

    Credits: 
    - This program utilizes the OpenAI API for chat completions. (https://openai.com)
    - The Lua code structure and conventions were inspired by Lua programming best practices.

    Additional Comments:
    - Make sure to replace [YOUR OPENAI TOKEN] with your actual OpenAI API key in the 'apiKey' variable.
    - Ensure you have an active internet connection on your ComputerCraft computer to communicate with the OpenAI API.

    Notes:
    - This program requires an active internet connection and the 'http' and 'textutils' Lua libraries.
    - Make sure you have installed and set up the ComputerCraft mod and have a working in-game computer.
    - To run this program on a ComputerCraft computer, follow these steps:
        1. Craft a ComputerCraft computer and place it in the game world.
        2. Right-click on the computer to open its interface
        3. Copy and paste the following command and press Enter to download the program:
           pastebin get DLXQR13m startup
        4. Modify the 'apiKey' variable with your actual OpenAI API key. Edit the 'startup' file using the 'edit' command.
        5. Press Ctrl and save the changes and then press Ctrl and exit the editor.
        6. Restart the ComputerCraft computer to run the program automatically on startup.
    - The program will now automatically start whenever the ComputerCraft computer is powered on and will prompt you for input and generate responses using the OpenAI API.

    Example Usage:
    - After following the installation and setup instructions, you can start a conversation with the chatbot:

    Feel free to have a conversation with the chatbot by entering messages one by one on the ComputerCraft computer.
]] --
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
local title = titles[math.random(1, #titles)]
-- OpenAI API key for authentication
local apiKey = "[YOUR OPENAI TOKEN]"

-- API endpoint for chat completions
local endpoint = "https://api.openai.com/v1/chat/completions"

-- Maximum number of tokens in the generated response
local maxTokens = 100

-- Pre-trained model to use for generating responses
local model = "gpt-3.5-turbo"

-- Headers for the HTTP request
local headers = {
    ["Authorization"] = "Bearer " .. apiKey,
    ["Content-Type"] = "application/json"
}

-- Function to print a string with a specified color
local function print_with_color(data, color)
    assert(type(data) == "string")
    term.setTextColor(color)
    io.write(data)
    term.setTextColor(colors.white)
end

-- Function to print each character of a string in random colors
local function print_with_random_colors(data)
    assert(type(data) == "string")
    for char in data:gmatch(".") do
        print_with_color(char, 2 ^ (math.random(0, 14)))
    end
end

-- Print a random title in random colors
print_with_random_colors(title)
print("\nType 'exit' to exit.\n")

-- Array to store the conversation messages
local messages = {}

-- Start an infinite loop for user input and model responses
while true do
    print_with_color("[Me]: ", colors.magenta)
    local prompt = io.read()

    if prompt == "exit" then
        exit()
    end
    -- Add the user's message to the conversation messages array
    table.insert(messages, {
        role = "user",
        content = prompt
    })

    -- Prepare the payload JSON to send to the API
    local payloadJson = textutils.serializeJSON({
        ["model"] = model,
        ["max_tokens"] = maxTokens,
        ["messages"] = messages
    })

    -- Send the HTTP request to the OpenAI API
    local requesting = true
    http.request(endpoint, payloadJson, headers)

    -- Wait for the HTTP response event
    while requesting do
        local event, url, sourceText = os.pullEvent()

        -- Handle successful HTTP response
        if event == "http_success" then
            local responseBody = sourceText.readAll()
            sourceText.close()
            local responseJson = textutils.unserializeJSON(responseBody)

            -- Check if a valid response was received
            if responseJson and responseJson.choices and responseJson.choices[1] then
                local generatedText = responseJson.choices[1].message.content

                -- Add the model's generated response to the conversation messages array
                table.insert(messages, {
                    role = "system",
                    content = generatedText
                })

                -- Print the generated response from the model
                print_with_color("[GPT]: ", colors.lime)
                print(generatedText)
            else
                print("Error: Failed to get a valid response.")
            end
            requesting = false

            -- Handle failed HTTP response
        elseif event == "http_failure" then
            print("Server didn't respond.")
            requesting = false
        end
    end
end
