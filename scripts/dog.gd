extends Control

@onready var audioManager: Control = $"../audioManager"

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
var leaveText = ["You turn around and walk back.\n\nYou stand at the crossroads."]

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
	"scratch": petAction,
	"rub": petAction,
	
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
	"goodbye": exitAction,
	"bye": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "dog"
	groupName = "dog"

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
		var damageText = ["You slash in a large arc, hitting the ", npcName, " cutting them."]
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
		dealDamageDialogue = ["You stab the ", npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == "slash":
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " cutting them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg

func dealDamage():
	if not npcScene.interactDone:
		audioManager.hurtSound.play()
		var attackDialogue = ["The ", npcName, " jumps forward and bites you."]
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
		SaveState.playerJoy += 5
		player.updateMood()

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
		SaveState.playerJoy += 5
		player.updateMood()

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
	var dogText = ["The dog eagerly walks behind you and begins to follow you.\n\nYou've made a new friend.",
	"You turn down the dog. You don't need anything else to die by your side.\n\nIt's best you go your seperate ways."]
	if acceptDog:
		if SaveState.prevInput == "yes":
			acceptDog = false
			SaveState.dogFriend = true
			leaveText = ["You and the dog walk back to the crossroads."]
			npcScene.playText(dogText[0])
		elif SaveState.prevInput == "no":
			acceptDog = false
			npcScene.playText(dogText[1])

func exitAction():
	npcScene.playText("".join(leaveText))
	npcScene.interactDogDone = true
	npcScene.interactOver(2)

func doNothing():
	pass

func death():
	if hPool.size() == 1:
		npcScene.playerTurn = true
		npcScene.playerCombat = false
		npcScene.playText(deathText)
		npcScene.interactDogDone = true
		SaveState.playerJoy -= 10
		player.updateMood()
