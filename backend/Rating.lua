local Rating = Object:extend()

Rating.name = ""
Rating.image = ""
Rating.hitWindow = 0
Rating.ratingMod = 1
Rating.score = 350
Rating.noteSplash = true
Rating.hits = 0

local RatingWindows = {
    ["sick"] = 45,
    ["good"] = 90, 
    ["bad"] = 135
}

function Rating:new(name)
    self.name = name
    self.image = name
    self.hitWindow = 0

    if RatingWindows[name] then
        self.hitWindow = RatingWindows[name]
    end

    return self
end

function Rating:loadDefault()
    local ratingsData = {Rating("sick")}

    local rating = Rating("good")
    rating.ratingMod = 0.67
    rating.score = 200
    rating.noteSplash = false
    table.insert(ratingsData, rating)

    rating = Rating("bad")
    rating.ratingMod = 0.34
    rating.score = 100
    rating.noteSplash = false
    table.insert(ratingsData, rating)

    rating = Rating("shit")
    rating.mod = 0
    rating.score = 50
    rating.noteSplash = false
    table.insert(ratingsData, rating)

    return ratingsData
end

return Rating