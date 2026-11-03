extends Control

@export var npcScene : Node2D
@export var player : Control
@onready var audioManager: Control = $"../audioManager"

@export var npcName = ""
@export var groupName = ""
@export var hPool = [0,0,0,0,0]
@export var aClass = [1,1,1,1,1]
@export var npcDamage : int
var npcTotalDamage = (npcDamage * (hPool.size()-1))

var targetNum = 1
var slashTargets = []
var z = 1
var stabDmg = SaveState.playerStab + 10 * aClass[targetNum]
var slashDmg = SaveState.playerSlash - 10 * aClass[z]
@export var targetName = ["","first ", "second ", "third ", "fourth "]
var enemiesLeft
@export var takeDamageDialogue = []
@export var dealDamageDialogue = []

var drinks = 0
var food = 0

var introText = "You enter the tavern to see a mostly empty room with a few people having a drink in the corner, talking amongst themselves. \n\nThe tavern keeper is behind the bar counter cleaning some glasses when you approach her."
var deathText = "Why would you try that?"

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
	"talk": talkAction,
	
	"reminisce": recallAction,
	"recall": recallAction,
	"remember": recallAction,
	
	"sneak": sneakAction,
	"stalk": sneakAction,
	"creep": sneakAction,
	"hide": sneakAction,
	
	"look": lookAction,
	"spy": lookAction,
	"watch": lookAction,
	
	"drink": drinkAction,
	"thirsty": drinkAction,
	"ale": drinkAction,
	
	"eat": eatAction,
	"hungry": eatAction,
	"food": eatAction,
	SaveState.playerFood: eatAction,
	SaveState.playerFood.to_lower(): eatAction,
	
	"quest": questAction,
	"work": questAction,
	"trade": questAction,
	
	"leave": exitAction,
	"goodbye": exitAction,
	"bye": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "tavern keeper"
	groupName = "guards"

func _process(_delta: float) -> void:
	if hPool.size() == 2:
		enemiesLeft = ["There is one ", npcName, " left."]
	elif hPool.size() >=2:
		enemiesLeft = ["There are ", str(hPool.size() - 1)," ", groupName, " left."]

func actionHandler(playerChoice):
	var action = playerChoice
	player.instructText.text = "[color=white]What will you do?[/color]"
	
	if not actionMap.has(action):
		player.instructText.text = "[color=red]You can't do that action[/color]"
		return

	actionMap[action].call()

func stabAction():
	if targetNum < 0 or targetNum >= hPool.size():
		npcScene.playText("There's no one to stab.")
		return

	if hPool[targetNum] - stabDmg <= 0:
		takeDamage("stab")
		hPool.remove_at(targetNum)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")

	elif hPool[targetNum] - stabDmg >= 0:
		takeDamage("stab")
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func slashAction():
	slashTargetFinder()
	if slashTargets.size() == 1:
		var damageText = ["You slash in a large arc, hitting a ", npcName, " cutting them."]
		takeDamage("slash")
		if hPool[slashTargets[0]] - slashDmg < 0:
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		else:
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue))

	elif hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg <= 0:
		takeDamage("slash")
		hPool.remove_at(slashTargets[0])
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey both fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
	elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
		takeDamage("slash")
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
	elif hPool[slashTargets[0]] - slashDmg >=0:
		takeDamage("slash")
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func takeDamage(damage):
	stabDmg = SaveState.playerStab + 10 * aClass[targetNum]
	slashDmg = SaveState.playerSlash - 10 * aClass[z]
	if damage == "stab":
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == "slash":
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " cutting them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg

func dealDamage():
	if not npcScene.interactTavernDone:
		audioManager.hurtSound.play()
		var attackDialogue = ["The tavern keeper calls the guards in and they stab you with their swords."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = ["The guards dealt ", str(npcTotalDamage), " damage!"]
		npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
		SaveState.health -= npcTotalDamage
	else:
		pass

func findTargetStab():
	if hPool.size() >= 2:
		targetNum = 1
	elif hPool.size() < 2:
		targetNum = -1

func slashTargetFinder():
	slashTargets = []
	if hPool.size() > 2:
		slashTargets = [1, 2]
	elif hPool.size() == 2:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = ["\"" + SaveState.playerName + 
		", its you!\" she says after noticing you. Her eyes dart towards the door anxiously, waiting for someone else to enter.\n\nYou explain everything that happened after you left Eden." +
		" \"I'm just glad someone is okay.\" she's holding back tears. \"Just think of everyone you saved here. We will always be grateful.\" She says.\n\nYou can't help but think of your friends and how you all promised to return here to share a drink when this was all over." ]
		npcScene.playText("".join(talkText))
	else:
		npcScene.playText("I think it's too late for talking now. Why would you attack the innocent tavern keeper?")
		player.playerJoy -= 10
		player.updateMood()

func recallAction():
	var recallText = ["Your recall the night you killed the Orc Commander.\n" +
	"You, " + SaveState.friendTwo + ", " + SaveState.friendThree + ", and " + SaveState.friendOne + 
	" sat down in the tavern and shared a few drinks. You told stories of the siege and the memories of the fallen soldiers." +
	"\n\nWhen you first arrived in Eden you were just another group of people offering to help, but after the siege the people of Eden came to regard you as heroes."]
	if SaveState.playerJoy <= 15:
		npcScene.playText("".join(recallText) + "\n\nNow you feel that couldn't be further from the truth. The real heroes are already gone.")
	elif SaveState.playerJoy > 15:
		npcScene.playText("".join(recallText) + "\n\nHero or not, you long for home and the friends you miss dearly. They were the real heroes.")
		SaveState.playerJoy += 10

func sneakAction():
	var sneakText = ["You duck behind some stools and begin crouching around the tavern floor.\n\n\"" + SaveState.playerName + "? what are you doing...\"\n\nYou stand back up."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["The taven looks exactly as you left it months ago. The table you all shared a final drink at before marching to the valley is even still there. Things look a little cleaner now though."]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = ["You ask the tavern keeper for a drink.\n\n\"Don't you worry, this one is on me.\" she says, placing a large mug of ale fit for someone thrice your size on the bar counter.\n\nThe taste makes you recall all the drinks you had with your friends.",
	"You tap the counter again, requesting another ale.\n\n\"Here you are sir.\" she looks a little suprised after you finished the last mug so quickly...",
	"You tap the counter again, requesting another ale.\n\n\"Here you are sir.\" she is starting to look concerned.",
	"There is nothing else here you are probably an alcholic."]
	drinks += 1
	if drinks == 1:
		player.heal.play()
		npcScene.playText(drinkText[0])
		SaveState.playerJoy += 5
		player.updateMood()
	elif drinks == 2:
		player.heal.play()
		npcScene.playText(drinkText[1])
	elif drinks == 3:
		player.heal.play()
		npcScene.playText(drinkText[2])
	elif drinks >= 4:
		npcScene.playText(drinkText[3])

func eatAction():
	var eatText = ["You ask the tavern keeper for some food.\n\nShe brings out some ", SaveState.playerFood, " for you. \"Don't worry its on me.\" she says. You happily accept and begin eating.",
	"You order some more food and she brings out even more this time. \"Don't worry about it.\" she says, she looks a little concerned, but you happily accept and begin eating.",
	"You gained 10kg."]
	food += 1
	if food == 1:
		npcScene.playText(eatText[0] + eatText[1] + eatText[2])
		SaveState.playerJoy += 5
		player.updateMood()
	elif food == 2:
		npcScene.playText(eatText[3])
	elif food >= 3:
		npcScene.playText(eatText[4])

func questAction():
	var questText = ["\"Maybe try asking the others in the town, they might have something for you.\""]
	npcScene.playText("".join(questText))

func exitAction():
	var leaveText = ["You say goodbye to the tavern keeper and open the door to leave. \"Good luck, " + SaveState.playerName + "! get home safe\" \n\nYou are back in the town square."]
	npcScene.playText("".join(leaveText))
	npcScene.interactTavernDone = true
	npcScene.interactOver(1)

func doNothing():
	pass

func death():
	if hPool.size() == 1:
		npcScene.playerTurn = true
		npcScene.playerCombat = false
		npcScene.playText(deathText)
		npcScene.interactDone = true
		SaveState.playerJoy -= 10
		player.updateMood()
