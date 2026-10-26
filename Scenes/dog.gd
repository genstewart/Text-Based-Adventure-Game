extends Control

@export var npcScene : Node2D
@export var player : Control

@export var npcName = "dog"
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
@export var npcAttackDial = []

var introText = "You approach the dog.\n\nIt's wagging its tail."
var deathText = "The dog lies dead in the mud at the crossroads."
var leaveText = "You turn around and walk back.\n\nYou stand at the crossroads."

var acceptDog = false
var pets = 0
var plays = 0

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
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
	
	"pet": petAction,
	"scratch": playAction,
	
	"play": playAction,
	"fetch": playAction,
	"throw": playAction,
	"wrestle": playAction,
	"chase": playAction,
	
	"feed": eatAction,
	"food": eatAction,
	"treat": eatAction,
	"beef": eatAction,
	"jerky": eatAction,
	
	"yes": acceptAction,
	"no": acceptAction,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "dog"
	groupName = ""

func _process(delta: float) -> void:
	enemiesLeft = [npcName + " is still alive."]

func actionHandler(playerChoice):
	var findAction = findTargetStab(playerChoice)
	var action = findAction["action"]
	targetNum = findAction["target"]
	
	if not actionMap.has(action):
		npcScene.playText("The dog barks. \"Woof Woof!\"")
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
		var damageText = ["You slash in a large arc, hitting", npcName, " cutting them."]
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
		takeDamageDialogue = [npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		dealDamageDialogue = ["You slash in a large arc, hitting the ", npcName, " cutting them."]
		takeDamageDialogue = [npcName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg
			print(hPool)

func dealDamage():
	if not npcScene.interactDone:
		var attackDialogue = [npcName, " jumps forward and bites you."]
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
		while y < 2 and hPool[y] > 0:
			slashTargets.append(y)
			y += 1
		return slashTargets
	elif hPool.size() == 1:
		slashTargets = [1]

func recallAction():
	var recallText = "You can't recall anything about this dog."
	npcScene.playText(recallText)

func sneakAction():
	var sneakText = ["You tip toe around the dog.\n\nIt stares at you."]
	npcScene.playText("".join(sneakText))

func lookAction():
	var lookText = ["The dog has blond ruffled hair. It's mostly covered in must on it's feet, looks like it's waiting for you to do something."]
	npcScene.playText("".join(lookText))

func petAction():
	var petText = ["You reach your hand out and pet the dog. It looks so happy.", "You pet the dog again. It lays on its back and you rub its belly.", "You continue to rub it's belly. It can't get enough and neither can you.\n\nIt's so cute."]
	pets += 1
	if pets == 1:
		npcScene.playText(petText[0])
	elif pets == 2:
		npcScene.playText(petText[1])
	elif pets >= 3:
		npcScene.playText(petText[2])
		SaveState.playerJoy += 10

func playAction():
	var playText = ["You pick up a small stick on the ground and throw it down the road. The dog runs to retrieve the stick and brings it back to you.\n\nIt wants to play again.",
	"You jump up and chase the dog around the town of Haven. He barks and runs around the houses in circles.\n\nThe dog hasn't had a chance to play for so long.",
	"You wrestle with the dog in the grass nearby and play fight.\n\nAfter some time the dog is too tired and it lays down in your lap to nap. You sit down in the grass for an hour and breathe in the fresh air, it's nice to have some fun.
	\nAfter some time the dog wakes up and you walk back to the cross roads together."]
	plays += 1
	if plays == 1:
		npcScene.playText(playText[0])
	elif plays == 2:
		npcScene.playText(playText[1])
	elif plays >= 3:
		npcScene.playText(playText[2])
		SaveState.playerJoy += 10

func eatAction():
	var eatText = ["You give the dog the food you got from ", SaveState.friendOne, "'s mom and the dog wags its tail and eats happily.","\n\nAfterwards, he looks up at you. He wants to follow you, do you let him?",
	"You don't have any food to to give the dog.\n\nThe dog looks dissapointed."]
	if SaveState.dogTreats and SaveState.playerJoy >= 100:
		npcScene.playText(eatText[0] + eatText[1] + eatText[2] + eatText[3])
		acceptDog = true
	elif SaveState.dogTreats and SaveState.playerJoy < 100:
		npcScene.playText(eatText[0] + eatText[1] + eatText[2])
	elif not SaveState.dogTreats:
		npcScene.playText(eatText[4])

func acceptAction():
	var dogText = ["The dog eagerly walks behind you and begins to follow you.\n\nYou've made a new friend",
	"You turn down the dog. You don't need anything else to die by your side.\n\nIt's best you go your seperate ways."]
	if acceptDog:
		if SaveState.prevInput == "yes":
			acceptDog = false
			SaveState.dogFriend = true
			leaveText = "You and the dog walk back to the crossroads."
			npcScene.playText(dogText[0])
		elif SaveState.prevInput == "no":
			acceptDog = false
			npcScene.playText(dogText[1])

func exitAction():
	npcScene.playText("".join(leaveText))
	npcScene.interactHouseDone = true
	npcScene.interactOver(2)

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
