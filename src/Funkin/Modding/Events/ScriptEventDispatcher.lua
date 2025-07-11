local ScriptEventDispatcher = {}

function ScriptEventDispatcher:callEvent(target, event)
    if target == nil or event == nil then
        return
    end

    if target.OnScriptEvent then target:OnScriptEvent(event) end
    target.v = target.v or "__default_ScriptedClass"

    if not event.shouldPropogate then
        return
    end

    if event.type == "CREATE" then
        target:onCreate(event)
        return
    elseif event.type == "DESTROY" then
        target:onDestroy(event)
        return
    elseif event.type == "UPDATE" then
        target:onUpdate(event)
        return
    end
    
    if target.v == "StateStageProp" then
        if event.type == "ADDED" then
            target:onAdd(event)
            return
        end
    end

    -- DIALOGUE
    if target.v == "DialogueScripted" then
    end

    -- NOTE_SCRIPTED_CLASS
    if target.v == "NoteScriptedClass" then

    end

    if target.v == "BPMSyncedScriptedClass" then
        if event.type == "SONG_BEAT_HIT" then
            target:onBeatHit(event)
            return
        elseif event.type == "SONG_STEP_HIT" then
            target:onStepHit(event)
            return
        end
    end

    if target.v == "PlayStateScriptedClass" then
    end
end

function ScriptEventDispatcher:callEventOnAllTargets(targets, event)
    if targets == nil or event == nil then
        return
    end
    
    if type(targets) == "table" then
        if #targets == 0 then
            return
        end
    end

    for _, target in ipairs(targets) do
        if target == nil then
            goto continue
        end

        self:callEvent(target, event)

        -- If one target says to stop propagation, stop.
        if not event.shouldPropogate then
            return
        end

        ::continue::
    end
end

return ScriptEventDispatcher