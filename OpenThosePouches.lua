local isOpening_lock = false -- semaphor to keep us from recursively checking
local isVendorDialogOpen_lock = false -- semaphor to not attempt while talking to a vendor (tries to sell the pouch)
local delayBetweenSearches = 0.75 -- seconds (not MS) to wait between bag opens

local ignoredItems = {
    -- warped-pocket-dimension, I feel like this was made specifically to mess with me :)
    190382, 

    -- Encaged souls from the Zapthrottle Soul Inhaler
    200931,
    200932,
    200934,
    200936,

    -- Items requiring lockpicking
    -- Last updated for 11.0
    -- https://www.wowhead.com/items?filter=10:195;1:2;:0
    -- use the Copy icon for ID
    16885, 
    63349, 
    68729, 
    203743, 
    198657, 
    186161, 
    180532, 
    190954, 
    179311, 
    5760, 
    43575, 
    16884, 
    4636, 
    180522, 
    29569, 
    31952, 
    180533, 
    88165, 
    4634, 
    16882, 
    43624, 
    12033, 
    16883, 
    88567, 
    5758, 
    43622, 
    121331, 
    4638, 
    5759, 
    4637, 
    169475, 
    7209, 
    6354, 
    45986, 
    4632, 
    13918, 
    116920, 
    4633, 
    188787, 
    6355, 
    194037, 
    13875, 
    186160, 
    204307, 
    220376, 
    106895, 
    191296
}

local function IsPouch(container, slot)
    local itemInfo = C_Container.GetContainerItemInfo(container, slot)
    if itemInfo == nil then
        return false
    end

    if itemInfo["hasLoot"] == false then
        return false
    end

    for _i, lockedItemId in ipairs(ignoredItems) do
        if lockedItemId == itemInfo["itemID"] then
            return false
        end
    end

    local link = C_Container.GetContainerItemLink(container, slot)
    local _, _, _, _, itemMinLevel = C_Item.GetItemInfo(link)
    if itemMinLevel ~= nil and itemMinLevel > UnitLevel("player") then
        return false
    end

    return true
end

local function OpenNextPouch()
    -- print("Looking for pouches")

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(container) do
            if IsPouch(container, slot) == true then
                local isNotCasting = UnitCastingInfo("player") == nil
                if isVendorDialogOpen_lock == false and isNotCasting and not InCombatLockdown() then
                    C_Container.UseContainerItem(container, slot)
                end
                C_Timer.After(delayBetweenSearches, OpenNextPouch)
                return
            end
        end
    end

    isOpening_lock = false
end

local function OpenAllPouchesEventually()

    if isOpening_lock == true then
        return
    end
    isOpening_lock = true
    -- print("scheduling")
    C_Timer.After(delayBetweenSearches, OpenNextPouch)
end

-- invisible frame for hooking events
local f = CreateFrame("frame")
f:SetScript("OnEvent", OpenAllPouchesEventually)
f:RegisterEvent("ITEM_PUSH")

local function ToggleVendorLock(_, event_name)
    if event_name == "MERCHANT_SHOW" then
        isVendorDialogOpen_lock = true
    end

    if event_name == "MERCHANT_CLOSED" then
        isVendorDialogOpen_lock = false
    end
end

local g = CreateFrame("frame")
g:SetScript("OnEvent", ToggleVendorLock)
g:RegisterEvent("MERCHANT_SHOW")
g:RegisterEvent("MERCHANT_CLOSED")
