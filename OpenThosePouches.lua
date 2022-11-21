local isOpening_lock = false -- semaphor to keep us from recursively checking
local isVendorDialogOpen_lock = false -- semaphor to not attempt while talking to a vendor (tries to sell the pouch)
local delayBetweenSearches = 0.75 -- seconds (not MS) to wait between bag opens

local ignoredItems = {
    190382, -- warped-pocket-dimension, I feel like this was made specifically to mess with me :)

    -- Items requiring lockpicking
    -- https://www.wowhead.com/items?filter=10:195;1:2;:0
    7209, -- Tazan's Satchel
    4632, -- Ornate Bronze Lockbox
    4633, -- Heavy Bronze Lockbox
    4634, -- Iron Lockbox
    4636, -- Strong Iron Lockbox
    4637, -- Steel Lockbox
    4638, -- Reinforced Steel Lockbox
    5758, -- Mithril Lockbox
    5759, -- Thorium Lockbox
    5760, -- Eternium Lockbox
    6354, -- Small Locked Chest
    6355, -- Sturdy Locked Chest
    12033, -- Thaurissan Family Jewels
    13875, -- Ironbound Locked Chest
    13918, -- Reinforced Locked Chest
    16882, -- Battered Junkbox
    16883, -- Worn Junkbox
    16884, -- Sturdy Junkbox
    16885, -- Heavy Junk    box
    106895, -- Iron-Bound Junkbox
    29569, -- Strong Junkbox
    31952, -- Khorium Lockbox
    43575, -- Reinforced Junkbox
    43622, -- Froststeel Lockbox
    43624, -- Titanium Lockbox
    45986, -- Tiny Titanium Lockbox
    63349, -- Flame-Scarred Junkbox
    68729, -- Elementium Lockbox
    88165, -- Vine-Cracked Junkbox
    88567, -- Ghost Iron Lockbox
    116920, -- True Steel Lockbox
    121331, -- Leystone Lockbox
    169475, -- Barnacled Lockbox
    179311, -- Synvir Lockbox
    180522, -- Phaedrum Lockbox
    180532, -- Oxxein Lockbox
    180533, -- Solenium Lockbox
    186161, -- Stygian Lockbox
    186160, -- Locked Artifact Case
    188787 -- Locked Broker Luggage
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

    return true
end

local function OpenNextPouch()
    -- print("Looking for pouches")

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(container) do
            if IsPouch(container, slot) == true then
                if isVendorDialogOpen_lock == false then
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
