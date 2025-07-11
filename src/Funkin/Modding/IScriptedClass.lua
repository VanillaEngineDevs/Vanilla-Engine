IScriptedClass = Class:extend()
function IScriptedClass.init() IScriptedClass.__modules = {} end
function IScriptedClass:onScriptEvent()end
function IScriptedClass:onCreate()end
function IScriptedClass:onUpdate()end
function IScriptedClass:onDestroy()end
function IScriptedClass:listScriptClasses() return IScriptedClass.__modules end
IScriptedClass.init()

IEventHandler = Class:extend()
function IEventHandler.init() IEventHandler.__modules = {} end
function IEventHandler:dispatchEvent(event)end
IEventHandler.init()

IStateChangingScriptedClass = IScriptedClass:extend()
function IStateChangingScriptedClass.init() IStateChangingScriptedClass.__modules = {} end
function IStateChangingScriptedClass:onStateChangeBegin(event)end
function IStateChangingScriptedClass:onStateChangeEnd(event)end

function IStateChangingScriptedClass:onSubStateOpenBegin(event)end
function IStateChangingScriptedClass:onSubStateOpenEnd(event)end
function IStateChangingScriptedClass:onSubStateCloseBegin(event)end
function IStateChangingScriptedClass:onSubStateCloseEnd(event)end

function IStateChangingScriptedClass:onFocusLost(event)end
function IStateChangingScriptedClass:onFocusGained(event)end
function IStateChangingScriptedClass:listScriptClasses() return IScriptedClass.__modules end
IStateChangingScriptedClass.init()

IStateStageProp = IScriptedClass:extend()
function IStateStageProp.init() IStateStageProp.__modules = {} end
function IStateStageProp:onAdd(event)end
function IStateStageProp:listScriptClasses() return IScriptedClass.__modules end
IStateStageProp.init()

INoteScriptedClass = IScriptedClass:extend()
function INoteScriptedClass.init() INoteScriptedClass.__modules = {} end
function INoteScriptedClass:onNoteIncoming(event) end
function INoteScriptedClass:onNoteHit(event) end
function INoteScriptedClass:onNoteMiss(event) end
function INoteScriptedClass:onNoteHoldDrop(event) end
function INoteScriptedClass:listScriptClasses() return IScriptedClass.__modules end
INoteScriptedClass.init()

IBPMSyncedScriptedClass = IScriptedClass:extend()
function IBPMSyncedScriptedClass.init() IBPMSyncedScriptedClass.__modules = {} end
function IBPMSyncedScriptedClass:onStepHit(event) end
function IBPMSyncedScriptedClass:onBeatHit(event) end
function IBPMSyncedScriptedClass:listScriptClasses() return IScriptedClass.__modules end
IBPMSyncedScriptedClass.init()

IPlayStateScriptedClass = IScriptedClass:extend()
function IPlayStateScriptedClass.init() IPlayStateScriptedClass.__modules = {} end
function IPlayStateScriptedClass:onPause(event) end
function IPlayStateScriptedClass:onResume(event) end
function IPlayStateScriptedClass:onSongLoaded(event) end
function IPlayStateScriptedClass:onSongStart(event) end
function IPlayStateScriptedClass:onSongEnd(event) end
function IPlayStateScriptedClass:onGameOver(event) end
function IPlayStateScriptedClass:onSongRetry(event) end
function IPlayStateScriptedClass:onNoteGhostMiss(event) end
function IPlayStateScriptedClass:onSongEvent(event) end
function IPlayStateScriptedClass:onCountdownStart(event) end
function IPlayStateScriptedClass:onCountdownStep(event) end
function IPlayStateScriptedClass:onCountdownEnd(event) end
function IPlayStateScriptedClass:listScriptClasses() return IScriptedClass.__modules end
IPlayStateScriptedClass.init()

IDialogueScriptedClass = IScriptedClass:extend()
function IDialogueScriptedClass.init() IDialogueScriptedClass.__modules = {} end
function IDialogueScriptedClass:onDialogueStart(event) end
function IDialogueScriptedClass:onDialogueCompleteLine(event) end
function IDialogueScriptedClass:onDialogueLine(event) end
function IDialogueScriptedClass:onDialogueSkip(event) end
function IDialogueScriptedClass:onDialogueEnd(event) end
function IDialogueScriptedClass:listScriptClasses() return IScriptedClass.__modules end
IDialogueScriptedClass.init()