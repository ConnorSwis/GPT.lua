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

    Example Usage:
    - You can start a conversation with the chatbot:
        [Me]: Hello, how are you?
        [GPT]: I'm fine, thank you. How can I assist you today?

    Feel free to have a conversation with the chatbot by entering messages one by one on the ComputerCraft computer.
    ]]
--]]
local titles = {[[  _   _   _   _   _   _   _  
 / \ / \ / \ / \ / \ / \ / \ 
| G | P | T | . | l | u | a |
 \_/ \_/ \_/ \_/ \_/ \_/ \_/
]], [[  ___  ____  ____    __    _  _   __  
 / __)(  _ \(_  _)  (  )  / )( \ / _\ 
( (_ \ ) __/  )(  _ / (_/\) \/ (/    \
 \___/(__)   (__)(_)\____/\____/\_/\_/
]], [[  __  ______         
 / _ /__)/     /  _ 
(__)/   (    .((/(/ 
]], [[ ___   ___   ___                          
|     |   |   |           |               
| +-  |-+-    +           +          -    
|   | |       |           |   | |   | |   
 ---                   -  ---  --    --   

 ]], [[  ___|  _ \__ __| |             
 |     |   |  |   | |   |  _` | 
 |   | ___/   |   | |   | (   | 
\____|_|     _|_)_|\__,_|\__,_| 

]], [[ ___ ___ _____ _           
/ __| _ \_   _| |_  _ __ _ 
|(_ |  _/ | |_| | || / _` |
\___|_|   |_(_)_|\_,_\__,_|

]], [[   __________  ______   __           
  / ____/ __ \/_  __/  / /_  ______ _
 / / __/ /_/ / / /    / / / / / __ `/
/ /_/ / ____/ / /  _ / / /_/ / /_/ / 
\____/_/     /_/  (_)_/\__,_/\__,_/  

]], [[  ________  ______  __         
 / ___/ _ \/_  __/ / /_ _____ _
/ (_ / ___/ / / _ / / // / _ `/
\___/_/    /_/ (_)_/\_,_/\_,_/ 

]], [[  ____ ____ _____ _             
 / ___|  _ \_   _| |_   _  __ _ 
| |  _| |_) || | | | | | |/ _` |
| |_| |  __/ | |_| | |_| | (_| |
 \____|_|    |_(_)_|\__,_|\__,_|

]], [[  _____________________________  .__                
 /  _____/\______   \__    ___/  |  |  __ _______   
/   \  ___ |     ___/ |    |     |  | |  |  \__  \  
\    \_\  \|    |     |    |     |  |_|  |  // __ \
 \______  /|____|     |____|    /\____/____/(____ /
       \/                       \/              \/

]], [[ .--. .---. .-----.  .-.               
: .--': .; :`-. .-'  : :               
: : _ :  _.'  : :    : :  .-..-. .--.  
: :; :: :     : :  _ : :_ : :; :' .; ; 
`.__.':_;     :_; :_;`.__;`.__.'`.__,_;

]], [[ /~~\|~~\~~|~~ |         
 | __|__/  |   ||   |/~~|
 \__/|     |  .| \_/|\__|

]], [[.|'''''| '||'''|, |''||''|    '||`                  
|| .      ||   ||    ||        ||                   
|| |''||  ||...|'    ||        ||  '||  ||`  '''|.  
||    ||  ||         ||        ||   ||  ||  .|''||  
`|....|' .||        .||.   .. .||.  `|..'|. `|..||.

]], [[ ___ _______   _           
 ))_ ))_)))    )) _    ___ 
((_(((  ((  o (( ((_( ((_(

]], [[   __   ___  _____           
 ,'_/  / o |/_  _/  /7     _ 
/ /_n / _,'  / /   ///7/7,'o|
|__,'/_/    /_/() ///__/ |_,7

]], [[ ____  ___  _____   _           
(  __)(   )(_   _) ( )          
| | _ | O  | | |   | | _ _  ___ 
( )_))( __/  ( ) _ ( )( U )( o )
/____\/_\    /_\(_)/_\/___\/_^_\

]], [[  __  ___ ___          
 / _|| o \_ _| ||   _  
( |_n|  _/| |  |||U/o\ 
 \__/|_|  |_() L|\_|_,] 
   
]], [[ ___   ___  ___    _           
/  _> | . \|_ _|  | | _ _  ___ 
| <_/\|  _/ | | _ | || | |<_> |
`____/|_|   |_|<_>|_|`___|<___|

]], [[ _______ _______ _______    __             
|   _   |   _   |       |  |  .--.--.---.-.
|.  |___|.  1   |.|   | |__|  |  |  |  _  |
|.  |   |.  ____`-|.  |-|__|__|_____|___._|
|:  1   |:  |     |:  |                    
|::.. . |::.|     |::.|                    
`-------`---'     `---'  

]], [[____ ___  ___  _    _  _ ____ 
| __ |__]  |   |    |  | |__| 
|__] |     |  .|___ |__| |  | 

]], [[ __  __  ___           
[ __[__)  |     |. . _.
[_./|     |   * |(_|(_]

]], [[ .d8888b.  8888888b. 888888888 888      
d88P  Y88b 888   Y88b   888    888                 
888    888 888    888   888    888                 
888        888   d88P   888    888 888  888 8888b.  
888  88888 8888888P"    888    888 888  888    "88b
888    888 888          888    888 888  888.d888888
Y88b  d88P 888          888 db 888 Y88b 888888  888
 "Y8888P88 888          888 YP 888 "Y88888"Y888888 
 
 ]], [[_______ ______ _______  __              
|     __|   __ \_     _||  |.--.--.---.-.
|    |  |    __/ |   |__|  ||  |  |  _  |
|_______|___|    |___|__|__||_____|___._|
 
]], [[  _____ _____ _______ _             
 / ____|  __ \__   __| |            
| |  __| |__) | | |  | |_   _  __ _ 
| | |_ |  ___/  | |  | | | | |/ _` |
| |__| | |      | | _| | |_| | (_| |
 \_____|_|      |_|(_)_|\__,_|\__,_|

]], [[ ## ##  ###      #          
#   # #  #       #  # #  ## 
# # ##   #       #  # # # # 
# # #    #       ## ### ### 
 ## #    #   #

]]}

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

-- Array to store the conversation messages
local messages = {}

-- Print a random title in random colors
print_with_random_colors(titles[math.random(1, #titles)])

-- Start an infinite loop for user input and model responses
while true do
    print_with_color("[Me]: ", colors.magenta)
    local prompt = io.read()

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
