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

var questActive = false
var questAccept = false
var sackSearched = false
var keyFound = false

var introText = "You stand over some footprints in the ground."
var deathText = "The three goblins lie dead on the ground. Behind them is a burlap sack, something is inside."

@export var npcAttackDial = []

var actionMap = {
	"stab": stabAction,
	"slash": slashAction,
	
	"talk": talkAction,
	
	"sneak": sneakAction,
	"stalk": sneakAction,
	"creep": sneakAction,
	"hide": sneakAction,
	
	"look": lookAction,
	"spy": lookAction,
	"watch": lookAction,
	"examine": lookAction,
	"sack": lookAction,
	"search": lookAction,
	
	"quest": questAction,
	"footsteps": questAction,
	"follow": questAction,
	"go": questAction,
	
	"yes": acceptAction,
	"no": acceptAction,
	
	"key": findKey,
	
	"open": openCoffer,
	"coffer": openCoffer,
	"chest": openCoffer,
	
	"take": takeGold,
	"steal": takeGold,
	"gold": takeGold,
	
	"bury": buryTrader,
	"grave": buryTrader,
	"dig": buryTrader,
	
	"leave": exitAction,
	"back": exitAction,
	"exit": exitAction,
	"return": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "goblin"
	groupName = "goblins"

func _process(delta: float) -> void:
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
	if questActive:
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
	elif not questActive:
		npcScene.playText("You thrust your sword repeatedly into the ground and ruin the footprints.")
		npcScene.playerCombat = false

func slashAction():
	if questActive:
		slashTargetFinder()
		if slashTargets.size() == 1:
			var damageText = ["You slash in a large arc, hitting one of the ", groupName, " cutting them."]
			if hPool[slashTargets[0]] - slashDmg < 0:
				takeDamage(SaveState.playerSlash)
				hPool.remove_at(slashTargets[0])
				npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
			else:
				takeDamage(SaveState.playerSlash)
				npcScene.playText("".join(damageText) + "\n\n" + "".join(takeDamageDialogue))
		elif hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg <= 0:
			takeDamage(SaveState.playerSlash)
			hPool.remove_at(slashTargets[0])
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nThey both fall to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
			takeDamage(SaveState.playerSlash)
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		elif hPool[slashTargets[0]] - slashDmg >=0:
			takeDamage(SaveState.playerSlash)
			npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))
	elif not questActive:
		npcScene.playText("You slash the rock wall beside you with your sword and carve a few scratches into it. Pretty cool.")
		npcScene.playerCombat = false

func takeDamage(damage):
	if damage == SaveState.playerStab:
		stabDmg = SaveState.playerStab + 10 * aClass[targetNum]
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		slashDmg = SaveState.playerSlash - 10 * aClass[z]
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " cutting them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg

func dealDamage():
		if not npcScene.interactFootstepsDone and questActive:
			var attackDialogue = ["The ", groupName, " attack you with their clubs"]
			if hPool.size() > 2:
				attackDialogue = ["The ", groupName, " attack you with their clubs"]
				npcTotalDamage = (npcDamage * (hPool.size()-1))
				dealDamageDialogue = ["The ", groupName, " dealt ", str(npcTotalDamage), " damage!"]
				npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
				SaveState.health -= npcTotalDamage
			elif hPool.size() <=2:
				attackDialogue = ["The ", npcName, " attacks you with its club"]
				npcTotalDamage = (npcDamage * (hPool.size()-1))
				dealDamageDialogue = ["The ", npcName, " dealt ", str(npcTotalDamage), " damage!"]
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
	if not questActive:
		if npcScene.playerCombat == false:
			npcScene.playText("Theres no one to talk to.")
	if questActive:
		if npcScene.playerCombat == false and not SaveState.goblinsKilled:
			npcScene.playText("You don't want to talk and give yourself away.")
		elif npcScene.playerCombat == false and SaveState.goblinsKilled:
			npcScene.playText("There is no one to talk to you.")
		else:
			npcScene.playText("You say hello to the goblins but they aren't interested in speaking with you.")

func questAction():
	var questText = ["You're not sure what or who the footsteps could be from. Do you want to follow them into the chasm?"]
	if not questActive:
		npcScene.playText("".join(questText))
		questAccept = true

func acceptAction():
	var questAcceptText = ["You decide to follow the footsteps down into the dark chasm.\n\nAfter climbing into the chasm you begin to hear the voices of goblins. After sneaking closer you see three goblins crouched over something. They are all turned away from you."]
	if not questActive and questAccept:
		if SaveState.prevInput == "yes":
			npcScene.playText("".join(questAcceptText))
			questAccept = false
			questActive = true
		if SaveState.prevInput == "no":
			npcScene.playText("You decide to turn back and return to The Cairn.")
			questAccept = false
	else:
		doNothing()

func findKey():
	if questActive and sackSearched:
		npcScene.playText("You decide to search the man inside the sack and find a key inside his boot. The goblins must have been too dumb to search there.")
		keyFound = true
	elif questActive and SaveState.goblinsKilled:
		npcScene.playText("A key would probably open the coffer. Maybe try looking for it.")
	else:
		doNothing()

func openCoffer():
	if questActive and keyFound:
		npcScene.playText("You turn around and pick up the coffer.\n\nUsing the key you found you open the coffer and find that it is full of gold and assorted gemstones.")
		SaveState.cofferOpen = true
	elif questActive and SaveState.goblinsKilled:
		npcScene.playText("The coffer is a fairly small chest made of decorative wood. It looks like it unlocks with a key.")
	else:
		doNothing()

func takeGold():
	if SaveState.cofferOpen:
		npcScene.playText("You take the gold and put it in your backpack.\n\nThe man won't be using it anymore and you deserve it for killing the goblins anyway.")
		SaveState.goldTaken = true
		SaveState.playerJoy -= 10
	else:
		doNothing()

func buryTrader():
	if sackSearched:
		npcScene.playText("You decide to bury the dead man you found nearby. He deserves a peaceful place to rest, we all do.")
		SaveState.traderBuried = true
		SaveState.playerJoy += 10
	else:
		doNothing()

func recallAction():
	var recallText = "Nothing to recall about this location."
	npcScene.playText(recallText)

func sneakAction():
	var sneakText = ["There is nothing to sneak up on now.",
	"You decide to sneak up on the goblins while they are trying to open the coffer.\n\nWhile they are trying to open it, you quickly cut the head clean off one of the goblins. The other two turn to you with their clubs ready to fight."]
	if not questActive:
		npcScene.playText(sneakText[0])
	elif questActive and not npcScene.playerCombat:
		npcScene.playerCombat = true
		npcScene.playText(sneakText[1])
		hPool.remove_at(1)

func lookAction():
	var lookText = ["You take a closer look at the footsteps and the surroundings.\n\nThere can't be more than 3 sets of footprints and some of them are significantly deeper than the others. The footsteps lead into a rocky chasm beside the Cairn, it's fairly dark.",
	"You peek over a rock to see the three goblins looking at a small coffer. Behind them, there's someone inside a brown burlap sack, they aren't moving.",
	"You approach the burlap sack and look through the opening to see a dead man. By the looks of his clothes, he was probably a trader the goblins robbed."]
	if not questActive:
		npcScene.playText(lookText[0])
	elif questActive and not SaveState.goblinsKilled:
		npcScene.playText(lookText[1])
	elif questActive and SaveState.goblinsKilled:
		sackSearched = true
		npcScene.playText(lookText[2])

func exitAction():
	if not questActive:
		npcScene.playText("You walk back to The Cairn.")
		npcScene.interactFootstepsDone = true
		npcScene.interactOver(2)
	elif questActive and SaveState.goblinsKilled:
		npcScene.introText(3)
	elif questActive:
		SaveState.playerJoy -= 10
		player.updateMood()
		if SaveState.playerSlash > 70:
			npcScene.playText("After seeing the goblins you decide it's two dangerous and turn back. After all, who would want to lose this shiny new sword?")
		elif SaveState.playerStab <= 70:
			npcScene.playText("After seeing the goblins you decide it's two dangerous and turn back. You're not cut out for this life anymore. Whatever is stuck in the burlap sack can fend for itself.")

func doNothing():
	pass

func death():
	if questActive:
		if hPool.size() == 1:
			npcScene.playerTurn = true
			npcScene.playerCombat = false
			npcScene.playText(deathText)
			SaveState.goblinsKilled = true
