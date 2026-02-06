function Song:onCreate()
    if getBoyfriend().id == "pico-playable" then
        weeks:preloadIcon(icon.imagePath("tankman-bloody"))
    end
end
