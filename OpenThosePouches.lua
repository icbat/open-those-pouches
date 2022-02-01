local LibProcessable = LibStub("LibProcessable")

local isOpening_lock = false -- semaphor to keep us from recursively checking
local delayBetweenSearches = 0.75 -- seconds (not MS) to wait between bag opens

-- TODO does this work w/ autoloot turned off?

local function IsPouch(container, slot)
    local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(container, slot)
    if itemLink == nil then
        return false
    end

    if lootable == false then
        return false
    end

    local itemId = GetContainerItemID(container, slot)
    for lockedItemId, _lockpickingSkillRequired in pairs(LibProcessable.containers) do
        if lockedItemId == itemId then
            return false
        end
    end

    return true
end

local function OpenNextPouch()
    print("Looking for pouches")

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(container) do
            if IsPouch(container, slot) == true then
                print("Opening ", itemLink)
                UseContainerItem(container, slot)
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
    print("scheduling")
    C_Timer.After(delayBetweenSearches, OpenNextPouch)
end

-- invisible frame for hooking events
local f = CreateFrame("frame")
f:SetScript("OnEvent", OpenAllPouchesEventually)
f:RegisterEvent("ITEM_PUSH")
