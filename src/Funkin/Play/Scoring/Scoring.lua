local Scoring = {}

function Scoring:scoreNote(msTiming, scoringSystem)
    scoringSystem = scoringSystem or "PBOT1"

    if scoringSystem == "PBOT1" then self:scoreNotePBOT1(msTiming)
    elseif scoringSystem == "WEEK7" then self:scoreNoteWEEK7(msTiming)
    elseif scoringSystem == "LEGACY" then self:scoreNoteLEGACY(msTiming)
    else error("Unknown scoring system: " .. tostring(scoringSystem))
    end
end

function Scoring:judgeNote(msTiming, scoringSystem)
    scoringSystem = scoringSystem or "PBOT1"

    if scoringSystem == "PBOT1" then return self:judgeNotePBOT1(msTiming)
    elseif scoringSystem == "WEEK7" then return self:judgeNoteWEEK7(msTiming)
    elseif scoringSystem == "LEGACY" then return self:judgeNoteLEGACY(msTiming)
    else error("Unknown scoring system: " .. tostring(scoringSystem))
    end
end

function Scoring:getMissScore(scoringSystem)
    scoringSystem = scoringSystem or "PBOT1"

    if scoringSystem == "PBOT1" then return self.PBOT1_MISS_SCORE
    elseif scoringSystem == "WEEK7" then return self.WEEK7_MISS_SCORE
    elseif scoringSystem == "LEGACY" then return self.LEGACY_MISS_SCORE
    else error("Unknown scoring system: " .. tostring(scoringSystem))
    end
end

Scoring.PBOT1_MAX_SCORE = 500
Scoring.SCORING_OFFSET = 54.99
Scoring.SCORING_SLOPE = 0.080
Scoring.PBOT1_MIN_SCORE = 9
Scoring.PBOT1_MISS_SCORE = -100

Scoring.PBOT1_PERFECT_THRESHOLD = 5.0
Scoring.PBOT1_MISS_THRESHOLD = 160

Scoring.PBOT1_KILLER_THRESHOLD = 12.5;
Scoring.PBOT1_SICK_THRESHOLD = 45.0;
Scoring.PBOT1_GOOD_THRESHOLD = 90.0;
Scoring.PBOT1_BAD_THRESHOLD = 135.0;
Scoring.PBOT1_SHIT_THRESHOLD = 160.0;

function Scoring:scoreNotePBOT1(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming > Scoring.PBOT1_MISS_THRESHOLD then
        return Scoring.PBOT1_MISS_SCORE
    elseif absTiming < Scoring.PBOT1_PERFECT_THRESHOLD then
        return Scoring.PBOT1_MAX_SCORE
    else
        local factor = 1.0 - (1.0 / (1.0 + math.exp(-Scoring.SCORING_SLOPE * (absTiming - Scoring.SCORING_OFFSET))))
        local score = math.floor(Scoring.PBOT1_MAX_SCORE * factor + Scoring.PBOT1_MIN_SCORE)
        return score
    end
end

function Scoring:judgeNotePBOT1(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming < Scoring.PBOT1_KILLER_THRESHOLD then
        return 'killer'
    elseif absTiming < Scoring.PBOT1_SICK_THRESHOLD then
        return 'sick'
    elseif absTiming < Scoring.PBOT1_GOOD_THRESHOLD then
        return 'good'
    elseif absTiming < Scoring.PBOT1_BAD_THRESHOLD then
        return 'bad'
    elseif absTiming < Scoring.PBOT1_SHIT_THRESHOLD then
        return 'shit'
    else
        return 'miss'
    end
end

Scoring.LEGACY_HIT_WINDOW = (10 / 60) * 1000; 
Scoring.LEGACY_SICK_THRESHOLD = Scoring.LEGACY_HIT_WINDOW * 0.2;
Scoring.LEGACY_GOOD_THRESHOLD = Scoring.LEGACY_HIT_WINDOW * 0.75;
Scoring.LEGACY_BAD_THRESHOLD = Scoring.LEGACY_HIT_WINDOW * 0.9;
Scoring.LEGACY_SHIT_THRESHOLD = Scoring.LEGACY_HIT_WINDOW * 1.0;

Scoring.LEGACY_SICK_SCORE = 350;
Scoring.LEGACY_GOOD_SCORE = 200;
Scoring.LEGACY_BAD_SCORE = 100;
Scoring.LEGACY_SHIT_SCORE = 50;
Scoring.LEGACY_MISS_SCORE = -10;

function Scoring:scoreNoteLEGACY(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_SICK_THRESHOLD then
        return Scoring.LEGACY_SICK_SCORE
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_GOOD_THRESHOLD then
        return Scoring.LEGACY_GOOD_SCORE
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_BAD_THRESHOLD then
        return Scoring.LEGACY_BAD_SCORE
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_SHIT_THRESHOLD then
        return Scoring.LEGACY_SHIT_SCORE
    else
        return Scoring.LEGACY_MISS_SCORE
    end
end

function Scoring:judgeNoteLEGACY(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_SICK_THRESHOLD then
        return 'sick'
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_GOOD_THRESHOLD then
        return 'good'
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_BAD_THRESHOLD then
        return 'bad'
    elseif absTiming < Scoring.LEGACY_HIT_WINDOW * Scoring.LEGACY_SHIT_THRESHOLD then
        return 'shit'
    else
        return 'miss'
    end
end

Scoring.WEEK7_HIT_WINDOW = Scoring.LEGACY_HIT_WINDOW;

Scoring.WEEK7_BAD_THRESHOLD = 0.8;
Scoring.WEEK7_GOOD_THRESHOLD = 0.55;
Scoring.WEEK7_SICK_THRESHOLD = 0.2;
Scoring.WEEK7_MISS_SCORE = -10;
Scoring.WEEK7_SHIT_SCORE = 50;
Scoring.WEEK7_BAD_SCORE = 100;
Scoring.WEEK7_GOOD_SCORE = 200;
Scoring.WEEK7_SICK_SCORE = 350;

function Scoring:scoreNoteWEEK7(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_SICK_THRESHOLD then
        return Scoring.WEEK7_SICK_SCORE
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_GOOD_THRESHOLD then
        return Scoring.WEEK7_GOOD_SCORE
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_BAD_THRESHOLD then
        return Scoring.WEEK7_BAD_SCORE
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW then
        return Scoring.WEEK7_SHIT_SCORE
    else
        return Scoring.WEEK7_MISS_SCORE
    end
end

function Scoring:judgeNoteWEEK7(msTiming)
    local absTiming = math.abs(msTiming)

    if absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_SICK_THRESHOLD then
        return 'sick'
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_GOOD_THRESHOLD then
        return 'good'
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW * Scoring.WEEK7_BAD_THRESHOLD then
        return 'bad'
    elseif absTiming < Scoring.WEEK7_HIT_WINDOW then
        return 'shit'
    else
        return 'miss'
    end
end

return Scoring