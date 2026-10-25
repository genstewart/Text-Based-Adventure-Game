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

var introText = "You knock on the door of the house. After hearing a few pots fall on the ground and some footsteps approaching the door, " + npcName + " opens the door and invites you in.\n\n\"" + SaveState.playerName + "!\" she says excitedly. \"Where is " + SaveState.friendOne + "?\""
var deathText = npcName + " lies dead on the floor, blood pooling up under her. Now she doesn't have to deal with "
var leaveText = ["You turn around and leave the house.\n\nYou stand at the cross roads."]

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
	"talk": talkAction,
	SaveState.friendOne: talkAction,
	SaveState.friendOne.to_lower(): talkAction,
	
	SaveState.friendTwo: recallMeeting,
	SaveState.friendTwo.to_lower(): recallMeeting,
	SaveState.friendThree: recallMeeting,
	SaveState.friendThree.to_lower(): recallMeeting,
	"friends": recallMeeting,
	"friend": recallMeeting,
	
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
	
	"eat": eatAction,
	"hungry": eatAction,
	"food": eatAction,
	"dog": eatAction,
	
	"quest": questAction,
	"work": questAction,
	"help": questAction,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = SaveState.friendOne + "'s mom"
	groupName = ""

func _process(delta: float) -> void:
	enemiesLeft = [npcName + " is still alive."]

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
		dealDamageDialogue = ["You stab ",  npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		dealDamageDialogue = ["You slash in a large arc, hitting ", npcName, " cutting them."]
		takeDamageDialogue = ["The ", npcName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg
			print(hPool)

func dealDamage():
	if not npcScene.interactDone:
		var attackDialogue = [npcName, " lunges forward with a kitchen knife."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = [npcName, " dealt ", str(npcTotalDamage), " damage!"]
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
		while y <= 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func talkAction():
	if npcScene.playerCombat == false:
		var talkText = ["You explain to her how ", SaveState.friendOne, " died at the siege of The Gates." ]
		if SaveState.daveDeath:
			if SaveState.playerJoy >= 70:
				npcScene.playText("".join(talkText) + "\n\nHe died a hero, and the world is safer for it.\n\n" + npcName + " pauses for a moment and thanks you for coming all this way to tell her. She's glad " + SaveState.friendOne + " died for the greater good of everybody.")
				SaveState.playerJoy += 10
				player.updateMood()
			elif SaveState.playerJoy < 70:
				npcScene.playText("".join(talkText) + "\n\nHe died in vain, anybody could have gone in to open the gate. You should have never put your friend at risk.\n\n" + npcName + " breaks down into tears, and curses you for not going with your friend.")
				SaveState.playerJoy -= 10
				player.updateMood()
				leaveText = ["Ashamed, you turn around and walk out of the house. " + SaveState.friendOne + " was your friend.\n\nHow can you call yourself a hero, if you can't even save those closest to you?\n\nYou stand at the crossroads in Haven."]
				npcScene.interactHouseDone = true
		else:
			npcScene.playText("You can't recall how " + SaveState.friendOne + " died.\n\n" + npcName + " bursts into tears and curses you for forgetting about her child.")
			leaveText = ["Ashamed, you leave the house and think about your friends who died for you nearly a year ago now. How could you forget about their sacrafice?.\n\nYou stand at the crossroads in Haven."]
			SaveState.playerJoy -= 10
			player.updateMood()
			npcScene.interactHouseDone = true
	else:
		npcScene.playText("I think it's too late for talking now. Why would you attack her?")
		player.playerJoy -= 10
		player.updateMood()

func recallAction():
	var recallText = ["You recall the day you decided to embark on this quest. You and your friends just finished defending Haven from a small group of goblins and orcs. You all sat quietly inside the house after the brutal raid. After seeing the destruction and aftermath, the four of you chose to travel to Eden and join the defence there."]
	if SaveState.playerJoy < 85:
		npcScene.playText("".join(recallText) + "\n\nStanding here now, you're not sure if you ever should have gone. The people here needed you too. They needed their family too.")
	elif SaveState.playerJoy >= 85:
		npcScene.playText("".join(recallText) + "\n\nYou know now that if you hadn't gone to Eden you would have never been there to end the siege. Even if they had, the siege at The Gates may have failed without "
		 + SaveState.friendOne + ". Without " + SaveState.friendTwo + " and " + SaveState.friendThree + ", no one may have survived to kill the " + SaveState.bossSlain + " and end this war.")
		SaveState.playerJoy += 10
		player.updateMoood()

func recallMeeting():
	pass

func sneakAction():
	var sneakText = [""]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = [""]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = [""]
	drinks += 1
	if drinks == 1:
		npcScene.playText(drinkText[0])
		SaveState.playerJoy += 10
		player.updateMood()
	elif drinks == 2:
		npcScene.playText(drinkText[1])
	elif drinks == 3:
		npcScene.playText(drinkText[2])
	elif drinks >= 4:
		npcScene.playText(drinkText[3])

func eatAction():
	var eatText = [""]
	food += 1
	if food == 1:
		npcScene.playText(eatText[0] + eatText[1] + eatText[2])
		SaveState.playerJoy += 10
		player.updateMood()
	elif food == 2:
		npcScene.playText(eatText[3])
	elif food >= 3:
		npcScene.playText(eatText[4])

func questAction():
	var questText = ["\"\""]
	npcScene.playText("".join(questText))

func exitAction():
	npcScene.playText("".join(leaveText))
	npcScene.interactHouseDone = true
	npcScene.interactOver(1)

func doNothing():
	pass

func death():
	if hPool.size() == 1:
		npcScene.playerTurn = true
		npcScene.playerCombat = false
		npcScene.playText(deathText)
		npcScene.interactHouseDone = true
		SaveState.playerJoy -= 10
		player.updateMood()
