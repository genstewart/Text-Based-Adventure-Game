extends Control

@export var npcScene : Node2D
@export var player : Control

var introText = "You open the door to enter your home. Here it is, the place where your quest began nearly one year ago.\n\nNow you can finally rest."

var restText = ["You sit down to finally rest after the long journey. You were one of the heros who helped save so many people.\n\n", merciful, generous, selfless, honest, friend, remembered]

var mercifulText = ["But after you killed the ", SaveState.bossSlain ," you lost your way.", "Even after you finished your quest, you were an inspiration to others."]
var merciful = ""
var generousText = [" You let the past control you, and stopped helping others.", " You stayed true to your values and helped others in need."]
var generous = ""
var selflessText = [" Greed controlled your actions, and you let it corrupt you.", " You were selfless even when no one was watching."]
var selfless = ""
var honestText = [" When you spoke to others, you stayed silent about the events that effected you most.", " You were honest about the past and gave others hope about the future."]
var honest = ""
var friendText = [" In the end, you slowly let go of the memories of your friends, and died a lonely person.", " In the end, you kept the memories of your friends close and carried that memory until you died."]
var friend = ""

var remembered = ""

var leaveText = ["You journey is over. Now it's time to rest."]

var actionMap = {
	"rest": restAction,
	
	"look": lookAction,
	
	"credits": creditsAction,
	
	"gen": easterEgg,
	"Gen": easterEgg,
	"allan": easterEgg,
	"Allan": easterEgg,
	
	"leave": exitAction,
	
	"": doNothing,
}

func _ready() -> void:
	if SaveState.dogFriend:
		introText = "You open the door to enter your home with your dog. Here it is, the place where your quest began nearly one year ago.\n\nNow you can finally rest."
	elif not SaveState.dogFriend:
		introText = "You open the door to enter your home. Here it is, the place where your quest began nearly one year ago.\n\nNow you can finally rest."

	if SaveState.boysTalked:
		merciful = mercifulText[3]
	else:
		merciful = mercifulText[0] + mercifulText[1] + mercifulText[2]

	if SaveState.orcsKilled:
		generous = generousText[1]
	else:
		generous = generousText[0]

	if SaveState.traderBuried:
		selfless = selflessText[1]
	elif SaveState.goldTaken:
		selfless = selflessText[0]
	else:
		selfless = ""

	if SaveState.toldMom or SaveState.toldGuards:
		honest = honestText[1]
	else:
		honest = honestText[0]
	
	if SaveState.recalledMeeting or SaveState.dogFriend:
		friend = friendText[1]
	else:
		friend = friendText[0]

	if SaveState.playerJoy <= 40:
		remembered = "\n\nYou weren't remembered by many, and your story slowly stopped being [hint=type \"credits\"]told.[/hint]"
	elif SaveState.playerJoy <= 90 and SaveState.playerJoy > 40:
		remembered = "\n\nThose you personally knew will remember you, but your story will end with [hint=type \"credits\"]them.[/hint]"
	elif SaveState.playerJoy <= 130 and SaveState.playerJoy > 90:
		remembered = "\n\nThose you personally knew will remember you, and you live in their memories [hint=type \"credits\"]forever.[/hint]"
	elif SaveState.playerJoy > 130:
		remembered = "\n\nYou will go down in history as not only the hero to save the world but a truly kind and admirable person. You will be an inspiration for many people to [hint=type \"credits\"]come.[/hint]"

	restText = ["You sit down to rest after the long journey. You were one of the heros who saved so many.\n\n", merciful, generous, selfless, honest, friend, remembered]


func actionHandler(playerChoice):
	var action = playerChoice
	
	if not actionMap.has(action):
		doNothing()
		return

	actionMap[action].call()

func restAction():
	npcScene.playText("".join(restText))

func lookAction():
	npcScene.playText("Nothing to see here but home sweet home. It's the perfect place to rest.")

func creditsAction():
	npcScene.playText("[color=orange]Thank you for playing!\n\nThis game was made entirely by Gen over the course of one month-ish, special thanks to Yukie for helping play-test it. If you enjoyed the game please send a screenshot of your ending text to Gen!\n\nType \"rest\" to see it again.[/color]")

func easterEgg():
	npcScene.playText("[color=orange]I just wanted a command in the game that was my name lol[/color]")

func exitAction():
	npcScene.playText("".join(leaveText))
	npcScene.interactHouseDone = true
	npcScene.interactOver(1)

func doNothing():
	pass
