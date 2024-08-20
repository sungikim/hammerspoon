-- Hammerspoon Configuration for displaying current temperature

local city = "Seoul"  -- 도시 이름
local units = "metric"  -- "imperial"을 사용하여 화씨로 변경 가능

-- 메뉴바 아이템 생성
local menubar = hs.menubar.new(true)  -- true로 설정하여 오른쪽에 배치
local weatherUrl = "http://api.openweathermap.org/data/2.5/weather?q=" .. city .. "&units=" .. units .. "&appid=" .. apiKey

-- 단일 아이콘 캔버스 생성
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
    text = "N/A",
    textSize = 12,
    textColor = { hex = "#FFFFFF" },
    frame = { x = "0%", y = "30%", w = "100%", h = "70%" },
    textAlignment = "left"
}
menubar:setIcon(canvas:imageFromCanvas())

-- 숫자를 반올림하여 소수점 이하 자릿수 조정
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- 로그 출력 시 현재 시각 추가
local function logWithTime(message)
    hs.console.printStyledtext(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message)
end

-- 날씨 정보 갱신 함수
local function updateWeather()
    logWithTime("Updating weather...")  -- 로그 추가
    hs.http.asyncGet(weatherUrl, nil, function(status, body, headers)
        logWithTime("Weather API call status: " .. tostring(status))
        local tempText
        if status == 200 then
            local json = hs.json.decode(body)
            logWithTime("Weather API response: " .. hs.inspect(json))
            if json and json.main and json.main.temp then
                local temperature = round(json.main.temp, 0)  -- 정수로 반올림
                tempText = temperature .. "°"
            else
                tempText = "N/A"
            end
        else
            tempText = "N/A"
        end
        
        -- 캔버스 텍스트 갱신
        canvas[2].text = tempText
        menubar:setIcon(canvas:imageFromCanvas())
        logWithTime("Updated weather canvas: " .. hs.inspect(canvas))
    end)
end

updateWeather()





-- ////////////////////////////////////////////////////////////////////////////////////////////////////



-- Hammerspoon Configuration for displaying Bitcoin and Ethereum prices

local btcMenu = hs.menubar.new(true)  -- true to place it on the right side
local ethMenu = hs.menubar.new(true)  -- true to place it on the right side

-- Create a single icon canvas for BTC and ETH
local btcCanvas = hs.canvas.new({ x = 0, y = 0, w = 40, h = 20 })
btcCanvas[1] = {
    type = "text",
    text = "BTC",
    textSize = 6.4,
    textColor = { hex = "#FFFFFF" },
    frame = { x = "0%", y = "0%", w = "100%", h = "30%" },
    textAlignment = "left"
}
btcCanvas[2] = {
    type = "text",
    text = "Loading...",
    textSize = 12,
    textColor = { hex = "#FFFFFF" },
    frame = { x = "0%", y = "30%", w = "100%", h = "70%" },
    textAlignment = "left"
}
btcMenu:setIcon(btcCanvas:imageFromCanvas())

local ethCanvas = hs.canvas.new({ x = 0, y = 0, w = 40, h = 20 })
ethCanvas[1] = {
    type = "text",
    text = "ETH",
    textSize = 6.4,
    textColor = { hex = "#FFFFFF" },
    frame = { x = "0%", y = "0%", w = "100%", h = "30%" },
    textAlignment = "left"
}
ethCanvas[2] = {
    type = "text",
    text = "Loading...",
    textSize = 12,
    textColor = { hex = "#FFFFFF" },
    frame = { x = "0%", y = "30%", w = "100%", h = "70%" },
    textAlignment = "left"
}
ethMenu:setIcon(ethCanvas:imageFromCanvas())

-- 숫자를 반올림하여 정수로 반환
local function roundCoin(num)
    return math.floor(num + 0.5)
end

-- 가격 갱신 함수
local function updatePrices()
    local btcUrl = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    local ethUrl = "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd"
    
    -- 비트코인 가격 가져오기
    hs.http.asyncGet(btcUrl, nil, function(status, body, headers)
        hs.console.printStyledtext("BTC API call status: " .. tostring(status))
        local btcPrice
        if status == 200 then
            local json = hs.json.decode(body)
            hs.console.printStyledtext("BTC API response: " .. hs.inspect(json))
            btcPrice = tostring(roundCoin(json.bitcoin.usd))
        else
            btcPrice = "N/A"
        end
        
        -- Update the text of btcCanvas[2]
        btcCanvas[2].text = btcPrice
        btcMenu:setIcon(btcCanvas:imageFromCanvas())
    end)

    -- 이더리움 가격 가져오기
    hs.http.asyncGet(ethUrl, nil, function(status, body, headers)
        hs.console.printStyledtext("ETH API call status: " .. tostring(status))
        local ethPrice
        if status == 200 then
            local json = hs.json.decode(body)
            hs.console.printStyledtext("ETH API response: " .. hs.inspect(json))
            ethPrice = tostring(roundCoin(json.ethereum.usd))
        else
            ethPrice = "N/A"
        end
        
        -- Update the text of ethCanvas[2]
        ethCanvas[2].text = ethPrice
        ethMenu:setIcon(ethCanvas:imageFromCanvas())
    end)
end

updatePrices()


-- ////////////////////////////////////////////////////////////////////////////////////////////////////


-- Automatic updates every 10 minutes
tm = hs.timer.doEvery(600, function()
    print("updating")
    updateWeather()
    updatePrices()
end)









