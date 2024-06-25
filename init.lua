-- Hammerspoon Configuration for displaying current temperature

local apiKey = OPENWEATHERMAP_KEY  -- Replace with your OpenWeatherMap API key
local city = "Seoul"  -- Replace with your city
local units = "metric"  -- Use "imperial" for Fahrenheit

-- Create menubar item
local menubar = hs.menubar.new(true)
local weatherUrl = "http://api.openweathermap.org/data/2.5/weather?q=" .. city .. "&units=" .. units .. "&appid=" .. apiKey

-- Function to create an icon canvas
local function createIconCanvas(temp)
    local canvas = hs.canvas.new({ x = 0, y = 0, w = 34, h = 20 })
    canvas[1] = {
        type = "text",
        text = "TEMP",
        textSize = 6.4,
        textColor = { hex = "#FFFFFF" },
        frame = { x = "0%", y = "0%", w = "100%", h = "30%" },
        textAlignment = "left"
    }
    canvas[2] = {
        type = "text",
        text = temp or "N/A",
        textSize = 12,
        textColor = { hex = "#FFFFFF" },
        frame = { x = "0%", y = "30%", w = "100%", h = "70%" },
        textAlignment = "left"
    }
    return canvas
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function updateWeather()
    hs.http.asyncGet(weatherUrl, nil, function(status, body, headers)
        local tempText
        if status == 200 then
            local json = hs.json.decode(body)
            if json and json.main and json.main.temp then
                local temperature = round(json.main.temp, 0)  -- Change to integer
                tempText = temperature .. "°"
            else
                tempText = "N/A"
            end
        else
            tempText = "N/A"
        end
        
        local iconCanvas = createIconCanvas(tempText)
        menubar:setIcon(iconCanvas:imageFromCanvas())
    end)
end

-- Update weather every 10 minutes
local weatherTimer = hs.timer.doEvery(600, updateWeather)

-- Initial weather update
updateWeather()

hs.alert.show("Hammerspoon weather config loaded")






-- ////////////////////////////////////////////////////////////////////////////////////////////////////



-- Hammerspoon Configuration for displaying Bitcoin and Ethereum prices

local btcMenu = hs.menubar.new(true)
local ethMenu = hs.menubar.new(true)

-- Function to create an icon canvas for a coin
local function createIconCanvasCoin(ticker, price)
    local canvas = hs.canvas.new({ x = 0, y = 0, w = 40, h = 20 })
    canvas[1] = {
        type = "text",
        text = ticker,
        textSize = 6.4,
        textColor = { hex = "#FFFFFF" },
        frame = { x = "0%", y = "0%", w = "100%", h = "30%" },
        textAlignment = "left"
    }
    canvas[2] = {
        type = "text",
        text = price or "N/A",
        textSize = 12,
        textColor = { hex = "#FFFFFF" },
        frame = { x = "0%", y = "30%", w = "100%", h = "70%" },
        textAlignment = "left"
    }
    return canvas
end

-- Round a number and return it as an integer
local function roundCoin(num)
    return math.floor(num + 0.5)
end

-- 가격 갱신 함수
local function updatePrices()
    local btcUrl = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    local ethUrl = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
    
    -- Price update functions - BTC
    hs.http.asyncGet(btcUrl, nil, function(status, body, headers)
        local btcPrice
        if status == 200 then
            local json = hs.json.decode(body)
            btcPrice = tostring(roundCoin(json.bitcoin.usd))
        else
            btcPrice = "N/A"
        end
        
        local btcCanvas = createIconCanvasCoin("BTC", btcPrice)
        btcMenu:setIcon(btcCanvas:imageFromCanvas())
    end)

    -- Price update functions - ETH
    hs.http.asyncGet(ethUrl, nil, function(status, body, headers)
        local ethPrice
        if status == 200 then
            local json = hs.json.decode(body)
            ethPrice = tostring(roundCoin(json.ethereum.usd))
        else
            ethPrice = "N/A"
        end
        
        local ethCanvas = createIconCanvasCoin("ETH", ethPrice)
        ethMenu:setIcon(ethCanvas:imageFromCanvas())
    end)
end

-- Setting the price renewal frequency
local updateInterval = 10 * 60
updatePrices()
hs.timer.doEvery(updateInterval, updatePrices)

-- Initial menu bar settings
local btcLoadingCanvas = createIconCanvasCoin("BTC", "Loading...")
btcMenu:setIcon(btcLoadingCanvas:imageFromCanvas())

local ethLoadingCanvas = createIconCanvasCoin("ETH", "Loading...")
ethMenu:setIcon(ethLoadingCanvas:imageFromCanvas())









