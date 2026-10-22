extends Control

@export var npcScene : Node2D
@export var player : Control

@export var npcName = ""
@export var groupName = ""
@export var hPool = [0,0,0,0,0]
@export var aClass = [1,1,1,1,1]

var foundRiddle = false
var solvedRiddle = false

var introText = "You walk up to the stone."
var deathText = "Why would you try that?"

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
	"talk": talkAction,
	
	"reminisce": recallAction,
	"recall": recallAction,
	"remember": recallAction,
	"view": recallAction,
	"scene": recallAction,
	
	"sneak": sneakAction,
	"stalk": sneakAction,
	"creep": sneakAction,
	"hide": sneakAction,
	
	"look": lookAction,
	"spy": lookAction,
	"watch": lookAction,
	"examine": lookAction,
	"search": lookAction,
	
	"quest": questAction,
	"read": questAction,
	"etching": questAction,
	"etchings": questAction,
	
	"friend": riddleAnswer,
	"friends": riddleAnswer,
	"friendship": riddleAnswer,
	"friendships": riddleAnswer,
	
	"take": takeSword,
	"sword": takeSword,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "The Cairn"
	groupName = ""

func actionHandler(playerChoice):
	var action = playerChoice
	
	if not actionMap.has(action):
		npcScene.playText("You can't do that.")
		return

	actionMap[action].call()

func stabAction():
	npcScene.playText("You thrust forward with all your strength and stab your sword into the rock, nothing happens.")

func slashAction():
	npcScene.playText("You slash your sword on the rock, nothing happens.")

func talkAction():
	var talkText = ["You can't talk to a rock.", "You tell the rock about all your adventures this far. What happened in The Valley, "]
	var talked = 1
	talked += 1
	if talked == 1:
		npcScene.playText(talkText[0])
	elif talked >= 3:
		npcScene.playText(talkText[1])

func recallAction():
	var recallText = ["Looking out at the view, you recall what happend here nearly a year ago. You, ", SaveState.friendTwo, ", ", SaveState.friendThree, ", and ", SaveState.friendOne,
	" were all sitting at the Cairn.\n\nYou had just set out from your hometown weeks before, where the four of you began your quest.",
	" All of you looked out at The Valley ahead of you and the small towns of the rolling hills behind you.",
	" We knew we had a long way to go, and were ready for the adventures to come."]
	if SaveState.playerJoy <= 50:
		npcScene.playText("".join(recallText) + "\n\nWho knew the adventure would become such a lonely one.")
	elif SaveState.playerJoy > 50:
		npcScene.playText("".join(recallText) + "\n\nLooking back, none of you would have regret a thing. Including you.")
		SaveState.playerJoy += 10

func sneakAction():
	var sneakText = ["You tip-toe around The Cairn, no one is around to interrupt your sneaking here."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["You take a walk around The Cairn. While walking around, you spot some etchings in the rocks. Some words are carved into the backside of The Cairn."]
	npcScene.playText("".join(lookText))

func questAction():
	var questText = ["You take a closer look at the letters carved into the stone, but some moss covers what they say. You clean it off and reveal what is written.",
	"\n\n\"I stand by rain or shine,\nreflect your love in mine\nand I'm always there when you say \'hi\'\"",
	"\n\nSpeak my name and enter."]
	foundRiddle = true
	npcScene.playText("".join(questText))

func riddleAnswer():
	var swordFound = ["After saying the answer the ground beneath you begins to shake and a tall slit in the stone monolith begins to appear.\n\nThe rock parts to reveal a sword lying on a stone table."]
	if foundRiddle:
		npcScene.playText(swordFound[0])
		solvedRiddle = true
	elif not foundRiddle:
		npcScene.playText("You can't do that.")

func takeSword():
	var takeSword = ["You approach the sword and take it from the stone table.\n\nThe sword shines bright blue in the sunlight, it doesn't look like anything smithed this millenia even. The sword still feels sharp to the touch despite its age.",
	"\n\nYou put the sword in your sheath"]
	if solvedRiddle:
		SaveState.playerStab = 70
		SaveState.playerSlash = 100
		if SaveState.playerJoy >= 40:
			npcScene.playText("".join(takeSword) + " and vow to use it in the name of helping others.")
			SaveState.playerJoy += 10
			SaveState.updateMood()
		elif SaveState.playerJoy < 40:
			npcScene.playText("".join(takeSword) + ", it hardly feels earned, but you can't just leave it lying around.")
	else:
		npcScene.playText("You can't do that.")

func exitAction():
	var leaveText = ["You step away from The Cairn."]
	npcScene.playText("".join(leaveText))
	npcScene.interactCairnDone = true
	npcScene.interactOver(1)

func doNothing():
	pass
