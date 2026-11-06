extends Control

@onready var audioManager: Control = $"../audioManager"

@export var npcScene : Node2D
@export var player : Control

@export var npcName = SaveState.friendOne + "'s mom"
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
var talked = false
var recalled = false

var introText = "You knock on the door of the house. After hearing a few pots fall on the ground and some footsteps approaching the door, " + npcName + " opens the door and invites you in.\n\n\"" + SaveState.playerName + "!\" she says excitedly. \"Where is " + SaveState.friendOne + "?\""
var deathText = [npcName, " lies dead on the floor, blood pools up under her. What have you done?"]
var leaveText = ["You turn around and leave the house.\n\nYou stand at the crossroads."]

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
	
	"hungry": eatAction,
	"food": eatAction,
	"treat": eatAction,
	
	"dog": dogAction,
	
	"quest": questAction,
	"work": questAction,
	"help": questAction,
	
	"give": goldAction,
	"gold": goldAction,
	"money": goldAction,
	
	"leave": exitAction,
	"goodbye": exitAction,
	"bye": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = SaveState.friendOne + "'s mom"
	groupName = ""

func _process(_delta: float) -> void:
	enemiesLeft = [npcName + " is still alive."]

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
		var damageText = ["You slash in a large arc, hitting ", npcName, " cutting them."]
		if hPool[slashTargets[0]] - slashDmg < 0:
			takeDamage("slash")
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		else:
			takeDamage("slash")
			npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue))
	elif hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg <= 0:
		takeDamage("slash")
		hPool.remove_at(slashTargets[0])
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey both fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		print(hPool)
	elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
		takeDamage("slash")
		hPool.remove_at(slashTargets[0])
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
	elif hPool[slashTargets[0]] - slashDmg >=0:
		takeDamage("slash")
		npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))

func takeDamage(damage : String):
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
	if not npcScene.interactDone:
		audioManager.hurtSound.play()
		var attackDialogue = [npcName, " lunges forward with a kitchen knife."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = [npcName, " dealt ", str(npcTotalDamage), " damage!"]
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
		var talkText = ["You explain to her how ", SaveState.friendOne, " died at the siege of The Gates." ]
		if SaveState.daveDeath:
			if not talked:
				if SaveState.playerJoy >= 70:
					SaveState.playerJoy += 10
				elif SaveState.playerJoy < 70:
					SaveState.playerJoy -= 10
				player.updateMood()

			if SaveState.playerJoy >= 70:
				npcScene.playText("".join(talkText) + "\n\nThey died a hero, and the world is safer for it.\n\n" + npcName + " pauses for a moment and thanks you for coming all this way to tell her. She's glad " + SaveState.friendOne + " died for the greater good of everybody.")
				SaveState.toldMom = true
			elif SaveState.playerJoy < 70:
				npcScene.playText("".join(talkText) + "\n\nThey died in vain, anybody could have gone in to open the gate. You should have never put your friend at risk.\n\n" + npcName + " breaks down into tears, and curses you for not going with your friend.")
				leaveText = ["Ashamed, you turn around and walk out of the house. " + SaveState.friendOne + " was your friend.\n\nHow can you call yourself a hero, if you can't even save those closest to you?\n\nYou stand at the crossroads in Haven."]
				npcScene.interactHouseDone = true
				SaveState.toldMom = true
		else:
			npcScene.playText("You can't recall how " + SaveState.friendOne + " died.\n\n" + npcName + " bursts into tears and curses you for forgetting about her child.")
			leaveText = ["Ashamed, you leave the house and think about your friends who died for you nearly a year ago now. How could you forget about their sacrafice?\n\nYou stand at the crossroads in Haven."]
			SaveState.playerJoy -= 10
			player.updateMood()
			npcScene.interactHouseDone = true
	else:
		npcScene.playText("I think it's too late for talking now. Why would you attack her?")
		player.playerJoy -= 10
		player.updateMood()

func recallAction():
	var recallText = ["You recall the day you decided to embark on this quest.\n\nYou and your friends just finished defending Haven from a small group of goblins and orcs. You all sat quietly inside the house afterwards. After seeing the destruction and aftermath, the four of you decided to travel to Eden and join the defence there."]
	
	if not recalled:
		recalled = true
		if SaveState.playerJoy >= 85:
			SaveState.playerJoy += 10
			player.updateMood()

	if SaveState.playerJoy < 85:
		npcScene.playText("".join(recallText) + "\n\nStanding here now, you're not sure if you ever should have gone. The people here needed you too. They needed their family too.")
	elif SaveState.playerJoy >= 85:
		npcScene.playText("".join(recallText) + "\n\nNow you know that if you didn't go you would have never been there to save Eden. And the siege at The Gates would have failed without "
		 + SaveState.friendOne + "'s sacrifice. And if " + SaveState.friendTwo + " and " + SaveState.friendThree + " never went, no one would have survived to kill the " + SaveState.bossSlain + " and end the war.")

func recallMeeting():
	var recallMeetingText = ["You recall the day you and your friends met. The four of you came from the surrounding towns and met in Haven.\n\n",
	 SaveState.friendOne, " from Haven, ", SaveState.friendTwo, " and ", SaveState.friendThree,
	 " both came from a town to the west. After hearing news of a group of goblins and orcs heading to Haven, you all gathered to aid in the defence of the town."]
	npcScene.playText("".join(recallMeetingText))
	SaveState.recalledMeeting = true

func sneakAction():
	var sneakText = ["You duck behind the kitchen counter. \"", SaveState.playerName, ", what are you up to...?\" She looks concerned for you."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["The house is old and shabby. The paint is chipping off the walls and mostly empty since ", npcName, " lives alone.\n\nDespite the appearance of things this house is a comforting home."]
	npcScene.playText("".join(lookText))

func drinkAction():
	var drinkText = ["You ask for something to drink.\n\nShe brings you a nice hot cup of tea to drink. The taste is comforting and reminds you of home.",
	 "You ask for another cup of tea. She gives it to you but seems to be running out of things to talk to you about.",
	"I think it's about time to leave"]
	drinks += 1
	if drinks == 1:
		player.heal.play()
		npcScene.playText(drinkText[0])
		SaveState.playerJoy += 5
		player.updateMood()
	elif drinks == 2:
		player.heal.play()
		npcScene.playText(drinkText[1])
	elif drinks >= 3:
		npcScene.playText(drinkText[2])

func eatAction():
	var eatText = ["You ask her if she has any food.\n\n\"Here you are.\" She hands you some smoked beef jerky with visible grains of salt on it.", "You don't want to take all her food."]
	food += 1
	if food == 1:
		npcScene.playText(eatText[0])
		SaveState.dogTreats = true
	elif food >= 2:
		npcScene.playText(eatText[1])

func dogAction():
	var dogText = ["You ask her about the dog sitting outside.\"I could use some help with that dog. He won't leave me alone after I gave him some food last week.\""]
	npcScene.playText("".join(dogText))

func questAction():
	var questText = ["You ask her if she needs any help around the house.\n\n\"Oh no don't bother, I am doing just fine by myself. I could use some help with that dog however. He won't leave me alone after I gave him some food last week.\""]
	npcScene.playText("".join(questText))

func goldAction():
	var goldText = ["You try and give ", npcName, " the gold you found at The Cairn.\n\n\"", SaveState.playerName, "! where did you get all of this? I don't need any of this, you can keep it for yourself.\"
	\nShe looks suspicious as to how you acquired so much gold and if you came by it honestly."]
	if SaveState.goldTaken:
		npcScene.playText("".join(goldText))
	else:
		player.instructText.text = "[color=red]You can't do that action[/color]"

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
		npcScene.playText("".join(deathText))
		npcScene.interactHouseDone = true
		SaveState.evil = true
		SaveState.playerJoy -= 10
		player.updateMood()
