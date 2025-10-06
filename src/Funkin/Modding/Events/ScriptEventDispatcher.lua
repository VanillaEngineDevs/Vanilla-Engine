local ScriptEventDispatcher = {}

function ScriptEventDispatcher:callEvent(target, event)
    if target == nil or event == nil then
        return
    end

    if target.onScriptEvent then target:onScriptEvent(event) end
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

    if event.IStateStageProp then
        if event.type == "ADDED" then
            target:onAdd(event)
            return
        end
    end

    if event.IDialogueScriptedClass then
        if event.type == "DIALOGUE_START" then
            target:onDialogueStart(event)
            return
        elseif event.type == "DIALOGUE_LINE" then
            target:onDialogueLine(event)
            return
        elseif event.type == "DIALOGUE_COMPLETE_LINE" then
            target:onDialogueCompleteLine(event)
            return
        elseif event.type == "DIALOGUE_SKIP" then
            target:onDialogueSkip(event)
            return
        elseif event.type == "DIALOGUE_END" then
            target:onDialogueEnd(event)
            return
        end
    end

    if event.INoteScriptedClass then
        if event.type == "NOTE_INCOMING" then
            target:onNoteIncoming(event)
            return
        elseif event.type == "NOTE_HIT" and target.onNoteHit then
            target:onNoteHit(event)
            return
        elseif event.type == "NOTE_MISS" then
            target:onNoteMiss(event)
            return
        elseif event.type == "NOTE_HOLD_DROP" then
            target:onNoteHoldDrop(event)
            return
        end
    end

    if event.IBPMSyncedScriptedClass then
        if event.type == "SONG_BEAT_HIT" then
            if target.onBeatHit then target:onBeatHit(event) end
            return
        elseif event.type == "SONG_STEP_HIT" then
            if target.onStepHit then target:onStepHit(event) end
            return
        end
    end

    if event.IPlayStateScriptedClass then
        if event.type == "NOTE_GHOST_MISS" then
            target:onNoteGhostMiss(event)
            return
        elseif event.type == "SONG_START" then
            target:onSongStart(event)
            return
        elseif event.type == "SONG_END" then
            target:onSongEnd(event)
            return
        elseif event.type == "SONG_RETRY" then
            target:onSongRetry(event)
            return
        elseif event.type == "GAME_OVER" then
            target:onGameOver(event)
            return
        elseif event.type == "PAUSE" then
            target:onPause(event)
            return
        elseif event.type == "RESUME" then
            target:onResume(event)
            return
        elseif event.type == "SONG_EVENT" then
            target:onSongEvent(event)
            return
        elseif event.type == "COUNTDOWN_START" then
            target:onCountdownStart(event)
            return
        elseif event.type == "COUNTDOWN_STEP" then
            target:onCountdownStep(event)
            return
        elseif event.type == "COUNTDOWN_END" then
            target:onCountdownEnd(event)
            return
        elseif event.type == "SONG_LOADED" then
            target:onSongLoaded(event)
            return
        end
    end

    if event.IStateChangingScriptedClass then
        if event.type == "STATE_CHANGE_BEGIN" then
            target:onStateChangeBegin(event)
            return
        elseif event.type == "STATE_CHANGE_END" then
            target:onStateChangeEnd(event)
            return
        elseif event.type == "SUBSTATE_OPEN_BEGIN" then
            target:onSubStateOpenBegin(event)
            return
        elseif event.type == "SUBSTATE_OPEN_END" then
            target:onSubStateOpenEnd(event)
            return
        elseif event.type == "SUBSTATE_CLOSE_BEGIN" then
            target:onSubStateCloseBegin(event)
            return
        elseif event.type == "SUBSTATE_CLOSE_END" then
            target:onSubStateCloseEnd(event)
            return
        elseif event.type == "FOCUS_LOST" then
            target:onFocusLost(event)
            return
        elseif event.type == "FOCUS_GAINED" then
            target:onFocusGained(event)
            return
        end
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

        if not event.shouldPropogate then
            return
        end

        ::continue::
    end
end

return ScriptEventDispatcher