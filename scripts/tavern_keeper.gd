extends Control

@export var npcScene : Node2D
@export var player : Control

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

var introText = "You enter the tavern and see a mostly empty room with a few people having a drink in the corner and talking amongst themselves. \n\nThe tavern keeper is behind the bar counter, she is cleaning some glasses when you approach her."
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
	var findAction = findTargetStab(playerChoice)
	var action = findAction["action"]
	targetNum = findAction["target"]
	
	if not actionMap.has(action):
		npcScene.playText("You can't do that.")
		return

	actionMap[action].call()

func stabAction():
	if targetNum == 0:
		npcScene.playText("You thrust forwards stabbing, but no one is there...")
		return
	if targetNum < 0 or targetNum >= hPool.size():
		npcScene.playText("There's no target there.")
		return
	if hPool[targetNum] <= 0:
		npcScene.playText("That target is dead!")
		return

	if hPool[targetNum] - stabDmg <= 0:
		takeDamage(SaveState.playerStab)
		hPool.remove_at(targetNum)
		print(hPool.size() -1)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		print(hPool)
	elif hPool[targetNum] - stabDmg >= 0:
		takeDamage(SaveState.playerStab)
		print(hPool)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func slashAction():
	slashTargetFinder()
	print(slashTargets)
	if slashTargets.size() == 1:
		var damageText = ["You slash in a large arc, hitting one of the ", groupName, " cutting them."]
		if hPool[slashTargets[0]] - slashDmg < 0:
			takeDamage(SaveState.playerSlash)
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
			print(hPool)
		else:
			takeDamage(SaveState.playerSlash)
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue))
			print(hPool)
	elif hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg <= 0:
		takeDamage(SaveState.playerSlash)
		hPool.remove_at(slashTargets[0])
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey both fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		print(hPool)
	elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
		takeDamage(SaveState.playerSlash)
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
	elif hPool[slashTargets[0]] - slashDmg >=0:
		takeDamage(SaveState.playerSlash)
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func takeDamage(damage):
	if damage == SaveState.playerStab:
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " cutting them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg
			print(hPool)

func dealDamage():
	if not npcScene.interactTavernDone:
		var attackDialogue = ["The tavern keeper calls the guards in and they stab you with their swords."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = ["The guards dealt ", str(npcTotalDamage), " damage!"]
		npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
		SaveState.health -= npcTotalDamage
	else:
		pass

func findTargetStab(playerChoice : String) -> Dictionary:
	var x = 0
	while x < len(playerChoice) and not playerChoice[x].is_valid_int():
		x += 1
	var action = playerChoice.substr(0, x)
	var targetStr = playerChoice.substr(x)
	var target = targetStr.to_int() if targetStr.is_valid_int() else -1
	return {"action": action, "target": target}

func slashTargetFinder():
	slashTargets = []
	var y = 1
	if hPool.size() >= 2:
		while y < 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = ["\"" + SaveState.playerName + 
		", its you!\" she says after noticing you. Her eyes dart towards the door anxiously.\nNo one enters.\n\nYou explain everything that happened after you successfully repelled the siege at Eden." +
		" \"I'm just glad someone is okay\" she's holding back tears. \"Just think of everyone you saved here. My daughter and I will always be grateful.\" The words echo in your mind and you can't help but think of your friends. You all promised to come back here together and share a drink when this was all over." ]
		npcScene.playText("".join(talkText))
	else:
		npcScene.playText("I think it's too late for talking now. Why would you attack the innocent tavern keeper?")
		player.playerJoy -= 10
		player.updateMood()

func recallAction():
	var recallText = ["Your mind starts to doze off while you sit at the counter to the night you killed the Orc Commander.\n" +
	"You, " + SaveState.friendTwo + ", " + SaveState.friendThree + ", and " + SaveState.friendOne + 
	" sat down in the tavern and shared a few drinks. You told stories of the siege and the memories of the fallen soldiers. " +
	"When you all first arrived in the city you were just another group of adventurers who came through the mountain pass, but after the siege the people of Eden came to regard you as heroes. "]
	if SaveState.playerJoy <= 15:
		npcScene.playText("".join(recallText) + "\n\nNow you feel that couldn't be further from the truth. The real heroes are already gone.")
	elif SaveState.playerJoy > 15:
		npcScene.playText("".join(recallText) + "\n\nNow, regardless of a title, you long for home and the friends you miss dearly. They were the real heroes.")
		SaveState.playerJoy += 10

func sneakAction():
	var sneakText = ["You duck behind some stools and begin crouching around the tavern floor.\n\n\"" + SaveState.playerName + "? what are you doing...\"\n\nYou stand back up."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["The taven looks exactly as you left it months ago. The table you all shared a final drink at before marching to the valley is even still there. Things look a little cleaner now though."]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = ["You ask the tavern keeper for a drink. \"Don't you worry, this one is on me.\" she says, slamming a large mug of ale fit for a person thrice your size on the bar counter. After drinking, you feel a little nostalgic.",
	"You tap the counter again, requesting another ale. \"Here you are sir.\" she looks a little suprised after you finished the last mug so quickly...",
	"You tap the counter again, requesting another ale. \"Here you are sir.\" she is starting to look concerned.",
	"There is nothing else here you are probably an alcholic."]
	drinks += 1
	if drinks == 1:
		npcScene.playText(drinkText[0])
		SaveState.playerJoy += 5
		player.updateMood()
	elif drinks == 2:
		npcScene.playText(drinkText[1])
	elif drinks == 3:
		npcScene.playText(drinkText[2])
	elif drinks >= 4:
		npcScene.playText(drinkText[3])

func eatAction():
	var eatText = ["You ask the tavern keeper for some food and she brings out some ", SaveState.playerFood, " for you. \"Don't worry its on me.\" she says. You happily accept and begin eating.",
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
