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
var questActive = false
var questAccept = false

var introText = ["You enter the Guard House and three guards are at a table talking over a map. You overhear part of their conversation.\"Are you sure... We really can't spare any men now.\" \"I agree, our focus should be in the city.\" ",
"One guard glances towards the door and sees you.\n\n\"", SaveState.playerName,
 "? We never thought we'd see you again. Did you see any boys on your way here? Y'know they are taking about building statues for you and your friends in the town square.\"\n",]
var afterQuestText = ["The guards are gathered around the map talking about the city."]
var deathText = "The two orcs lie dead on the ground. The job is finished and the city is safer for it."

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
	
	"boys": boysQ,
	"gates": boysQ,
	"scavengers": boysQ,
	"bandits": boysQ,
	"boy": boysQ,
	"gate": boysQ,
	"scavenger": boysQ,
	"bandit": boysQ,
	"dad": boysQ,
	
	"quest": questAction,
	"work": questAction,
	"map": questAction,
	"help": questAction,
	
	"trade": tradeAction,
	"armor": tradeAction,
	
	"yes": acceptAction,
	"no": acceptAction,
	
	"leave": exitAction,
	"back": exitAction,
	"exit": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	npcName = "guard"
	groupName = "guards"

func _process(delta: float) -> void:
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
		npcScene.playText("These guards are holdings swords as tall as you and as wide as your face. You put your sword down.")
		npcScene.playerCombat = false

func slashAction():
	if questActive:
		slashTargetFinder()
		print(slashTargets)
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
			print(hPool)
		elif (hPool[slashTargets[0]] - slashDmg >= 0 and hPool[slashTargets[1]] - slashDmg <= 0) or (hPool[slashTargets[0]] - slashDmg <= 0 and hPool[slashTargets[1]] - slashDmg >= 0):
			takeDamage(SaveState.playerSlash)
			hPool.remove_at(slashTargets[0])
			npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue) + "\n\nOne falls to the ground, dead.\n\n" + "There are " + str(hPool.size() - 1) + " " + groupName + " left.")
		elif hPool[slashTargets[0]] - slashDmg >=0:
			takeDamage(SaveState.playerSlash)
			npcScene.playText("".join(dealDamageDialogue) + "\n\n" + "".join(takeDamageDialogue))
	elif not questActive:
		npcScene.playText("These guards are holdings swords as tall as you and as wide as your face. You put your sword down.")
		npcScene.playerCombat = false

func takeDamage(damage):
	if damage == SaveState.playerStab:
		stabDmg = SaveState.playerStab + 10 * aClass[targetNum]
		dealDamageDialogue = ["You stab the ", targetName[targetNum], npcName, " piercing straight through it's armor."]
		takeDamageDialogue = ["The ", targetName[targetNum], npcName, " took ", str(stabDmg), " damage!"]
		hPool[targetNum] -= stabDmg
	if damage == SaveState.playerSlash:
		slashDmg = SaveState.playerSlash - 10 * aClass[z]
		dealDamageDialogue = ["You slash in a large arc, hitting two of the ", groupName, " injuring them both."]
		takeDamageDialogue = ["The ", groupName, " took ", str(slashDmg), " damage!"]
		for z in slashTargets:
			hPool[z] -= slashDmg

func dealDamage():
		if not npcScene.interactGuardsDone and questActive:
			var attackDialogue = ["The ", groupName, " slash you with their scimtars."]
			if hPool.size() > 2:
				attackDialogue = ["The ", groupName, " slash you with their scimtars."]
				npcTotalDamage = (npcDamage * (hPool.size()-1))
				dealDamageDialogue = ["The ", groupName, " dealt ", str(npcTotalDamage), " damage!"]
				npcScene.playText("".join(attackDialogue) + "\n\n" +"".join(dealDamageDialogue))
				SaveState.health -= npcTotalDamage
			elif hPool.size() <=2:
				attackDialogue = ["The ", npcName, " slashes you with its scimtar."]
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
			var talkText = ["You give news to the guards about the slain Dragon and the fate of the army. \"Wow, I can't believe they're all gone... I'm just thankful you killed the dragon at last.\"",
			"You give news to the guards about the slain Dragon and the fate of the army and your friends. You avoid all topics about the boys you killed at the gates."]
			if not SaveState.boysKilled:
				npcScene.playText(talkText[0])
			elif SaveState.boysKilled:
				npcScene.playText(talkText[1])
		else:
			npcScene.playText("It's too late to speak with the guards now.")
			player.playerJoy -= 10
			player.updateMood()
	if questActive:
		if npcScene.playerCombat == false:
			npcScene.playText("The orcs don't even speak the same language.")
		else:
			npcScene.playText("It's far too late to try talking with them.")

func questAction():
	var questText = ["You ask the Guards about what has happend and glance at the map.",
	"\"There's been a report that some Orcs are camping by the road leading into town and killing the townspeople. We were just deciding whether we should investigate.\"",
	"\n\nDo you want to offer your help?"]
	var questDone = ["\"",SaveState.playerName, "! you're back!\"",
	" You tell the guards about the orcs you killed. They thank you, and give you two health potions for your help.",
	"\n\nYour adventure may be over, but helping people is in your blood."]
	if not questActive:
		npcScene.playText("".join(questText))
		questAccept = true
	elif questActive and SaveState.orcsKilled:
		questActive = false
		npcScene.playText("".join(questDone))
		SaveState.healthPotion += 2
		SaveState.playerJoy += 10
	elif questActive and not SaveState.orcsKilled:
		questActive = false
		npcScene.playText("You tell the Guards you found where the orcs camped but didn't deal with them. They're, still happy for your help and send you on your way.")
		SaveState.playerJoy -= 10

func acceptAction():
	var questAcceptText = ["You decide to check out the reports for the guards and leave the city while the sun is still setting",
	" By the time you are nearby, it's late at night. Through the trees you can see the light of a campfire and hear some muffled voices.",
	" As you approach you see two orcs standing by the fire clad in heavy armor.\n\nThey look like soldiers that ran during the siege."]
	if not questActive and questAccept:
		if SaveState.prevInput == "yes":
			npcScene.playText("".join(questAcceptText))
			hPool[0] = 0
			hPool[1] = 100
			hPool.append(100)
			aClass[1] = 3
			aClass[2] = 3
			print(aClass[1])
			npcDamage = 40
			groupName = "orcs"
			npcName = "orc"
			questActive = true
		if SaveState.prevInput == "no":
			npcScene.playText("You wish the guards the best of luck. That life of fighting is behind you.")
			questAccept = false
	else:
		doNothing()

## do This
func recallAction():
	var recallText = ["You recall the moments after you killed the orc commander.\n\nYou stood in the guard house with your friends and the armies commanders. After the bloody siege you all knew there was only one way to end this war for sure, to kill the ",
	 SaveState.bossSlain, " at last.\n\nThen you began planning the siege of The Gates with the other commanders."]
	npcScene.playText(recallText)

func sneakAction():
	var sneakText = ["You're not sure why but you decide to crawl under the map table in the center of the room. The guards all silently watch as you crawl under.\n\n\"",
	SaveState.playerName, "? what are you doing...\"\n\nBoom, one of your classic pranks. (The guards are all shocked and in tears)",
	"You decide to sneak up on the orcs. Creeping up through the bushes, you grab one of the orcs from behind and stab your sword through his back. He falls to the ground lifeless.\n\nThe other jumps up in response ready to avenge his friend."]
	if not questActive:
		npcScene.playText(sneakText[0]+sneakText[1]+sneakText[2])
	elif questActive and not npcScene.playerCombat:
		npcScene.playText(sneakText[3])
		hPool.remove_at(1)

func lookAction():
	var lookText = ["The three guards are standing beside a map table. On the map there is a large red X in the forest you traveled through to enter the city.",
	 "Two orcs stand by a fire speaking in tongues to eachother. It sounds like they might be having an argument."]
	if not questActive:
		npcScene.playText(lookText[0])
	if questActive:
		npcScene.playText(lookText[1])

func drinkAction():
	var drinkText = ["\"Go to the taven to drink.\"", "\"We have important business to do.\"", "\"You are an alchoholic\""]
	if not questActive:
		drinks += 1
		if drinks == 1:
			npcScene.playText(drinkText[0])
		elif drinks >= 2:
			npcScene.playText(drinkText[1])
		elif drinks >= 3:
			npcScene.playText(drinkText[2])
	else:
		doNothing()

func eatAction():
	var eatText = ["\"Go to the taven if your hungry.\"", "\"We have important business to do.\"", "\"I think you're fat.\""]
	if not questActive:
		food += 1
		if food == 1:
			npcScene.playText(eatText[0])
		elif food == 2:
			npcScene.playText(eatText[1])
		elif food >= 3:
			npcScene.playText(eatText[2])
	else:
		doNothing()

func boysQ():
	SaveState.boysKilled = true
	if not SaveState.boysKilled and SaveState.boysTalked:
		npcScene.playText("You tell the guards about the boys you met at the gates.\n\n\"Oh! Those boys from the east side, eh? Thank god their safe, thanks for looking out for our next generation of adventurers.\"")
		SaveState.playerJoy += 10
		player.updateMood()
	elif SaveState.boysKilled:
		npcScene.playText("You confess to killing the three boys who were at the gates.\n\n\"You killed those boys... They were just looking for their Dad after the battle, there was no need for violence. Just get out " + SaveState.playerName + ". Leave Eden.\"\n\nAshamed, you turn around and leave. You are in the town square.")
		SaveState.playerJoy -= 10
		player.updateMood()
		npcScene.interactGuardsDone = true
	elif not SaveState.boysTalked:
		npcScene.playText("You tell the guards about some suspected looters you saw at the gates. \"Looters? that might be the boys from the east side, they told us they would go out looking for their dad. We had no way to stop them from going, glad they're okay out there.\"\n\nYou're relieved you didn't resort to violence.")

func tradeAction():
	if not questActive:
		var tradeText = ["Maybe go talk to the smith, he might have something for you."]
		if SaveState.health > 100:
			npcScene.playText("They guards gather around you to admire the mail shirt you recieved.\n\n\"Is that... an admantium mail shirt... with golden rivets and diamond crusted collar... It's beautiful.\"\n\nThey are salivating.")
		elif SaveState.health <= 100:
			npcScene.playText("".join(tradeText))
	elif questActive:
		npcScene.playText("This is no time to be saying nonsense.")

func exitAction():
	if not questActive:
		var leaveText = ["You say goodbye to the guards and wish them well. You are back in the town square."]
		npcScene.playText("".join(leaveText))
		npcScene.interactGuardsDone = true
		npcScene.interactOver(3)
	elif questActive and SaveState.orcsKilled:
		npcScene.introText(4)
	elif questActive:
		npcScene.playText("You duck behind a tree and decide to turn back to the city. You're not built for this kind of battle anymore. The Guards are sure to be dissapointed.")
		SaveState.playerJoy -= 10
		player.updateMood()

func doNothing():
	pass

func death():
	if questActive:
		if hPool.size() == 1:
			npcScene.playerTurn = true
			npcScene.playerCombat = false
			npcScene.playText(deathText)
			SaveState.playerJoy += 10
			SaveState.orcsKilled = true
			player.updateMood()
