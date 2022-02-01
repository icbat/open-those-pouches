local isOpening_lock = false
local delayBetweenSearches = 0.75 -- seconds, not MS

-- TODO does this work w/ autoloot turned off?
-- TODO does it need an ignore list? stuff like the anniversary pouches are kinda weird to open
-- TODO is it worth refactoring to make it faster/less spammy? either only check if we know we looted a satchel, or at least re-start at last-known good?

local function OpenIfPouch(container, slot)
    local texture, count, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(container, slot)
    if itemLink == nil then
        return false
    end

    if lootable == false then
        return false
    end

    if locked == true then
        print("lootable but locked!") -- todo lockpicking?
        return false
    end

    print("Opening ", itemLink)
    UseContainerItem(container, slot)

    return true
end

local function OpenNextPouch()
    print("Looking for pouches")

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(container) do
            local successfullyOpenedSomething = OpenIfPouch(container, slot)
            if successfullyOpenedSomething == true then
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

-- invisible frame for updating/hooking events
local f = CreateFrame("frame")
f:SetScript("OnEvent", OpenAllPouchesEventually)
f:RegisterEvent("ITEM_PUSH")
