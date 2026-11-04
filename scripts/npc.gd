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

var introText = "You approach the scavengers."
var deathText = "You finish off the last scavenger, your sword glistening with blood. Standing over their corpses you get a better look at one of their faces. \n\nThese were no bandits, just some young boys, and now they have joined the corpses that litter the ground. You continue your journey, thinking about what you've done."

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	"talk": talkAction,
	
	"sneak": sneakAction,
	"stalk": sneakAction,
	"creep": sneakAction,
	
	"look": lookAction,
	"spy": lookAction,
	"watch": lookAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "scavenger"
	groupName = "scavengers"

func _process(_delta: float) -> void:
	if hPool.size() == 2:
		enemiesLeft = ["There is one ", npcName, " left."]
	elif hPool.size() >=2:
		enemiesLeft = ["There are ", str(hPool.size() - 1)," ", groupName, " left."]

func actionHandler(playerChoice):
	var action = playerChoice
	player.instructText.text = "[color=white]What will you do?[/color]"
	
	if not SaveState.scavengersDone:
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
	if not SaveState.scavengersDone:
		audioManager.hurtSound.play()
		var attackDialogue = ["The ", groupName, " lunge at you with their knives. Some of their blades slip past your armor."]
		npcTotalDamage = (npcDamage * (hPool.size()-1))
		dealDamageDialogue = ["The ", groupName, " dealt ", str(npcTotalDamage), " damage!"]
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
		var talkText = ["You talk to the scavengers.",
		 " The \"scavengers\" are just some young boys from the city, Eden.",
		 " You ask why they came to The Gates and the oldest boy replies.", "\n\n\"Are you ", SaveState.playerName, "? The city watch said we might see you here.",
		 " Where is the army? We were just looking for our Dad...\"", " You tell them what happend in the battle.",
		 "\n\nThe guilt of the soldiers' deaths weighs heavy on your mind, but you're glad you didn't kill the boys when you saw them searching the bodies.",
		 " After talking, the boys decide to continue searching and give their Dad a proper burial. You continue your journey home."]
		npcScene.playText("".join(talkText))
		SaveState.playerJoy += 10
		SaveState.boysTalked = true
		player.updateMood()
		SaveState.scavengersDone = true
	else:
		npcScene.playText("You try to talk to the scavengers and lock eyes with one. These aren't some dangerous \"bandits\", they are just some boys from the city! Now they're no longer willing to listen to you. \n\nNow they're fighting for their lives.")
		groupName = "boys"
		npcName = "boy"
		deathText = "You finish off the last boy, your sword glistening with blood. Standing over their corpses you get a better look at one of their faces. \n\nThese boys didn't deserve to die and now they have joined the corpses that litter the ground.\n\nYou continue your journey, thinking about what you've done."

func sneakAction():
	var sneakText = ["You wait while watching the scavengers until the sun sets behind you.",
"\n\nEventually, they walk into the northern watchtower to camp for the night.",
" Once the moon reaches midnight you sneak towards the gates."]
	npcScene.playText("".join(sneakText))
	SaveState.scavengersDone = true

func lookAction():
	var lookText = ["Staying hidden behind the top of a hill, you watch the scavengers. One of them lowers his hood for just a moment, he's just a young boy, not a dangerous bandit",
	" \n\nYou retreat behind the hill and think about what you should do."]
	npcScene.playText("".join(lookText))

func doNothing():
	pass

func death():
	if hPool.size() == 1:
		npcScene.playerTurn = true
		npcScene.playerCombat = false
		npcScene.playText(deathText)
		SaveState.scavengersDone = true
		SaveState.playerJoy -= 10
		SaveState.boysKilled = true
		player.updateMood()
