extends Node

const textspeed = .035

#player stats
var maxHealth = 100
var health = 100
var healthPotion = 5
var playerStatus = "Exhausted"
var playerJoy = 0
var playerSlash = 70
var playerStab = 40

#player starting choices
var playerName = "Gen"
var playerFood = "Gyoza"
var friendOne = "Dave"
var friendTwo = "Kyle"
var friendThree = "Clara"
var bossSlain = "Griffin"

#text input for npc interaction
var prevInput = ""

#player events to effect story
#Events with a comment effect the final dialogue.
var daveDeath = false
var boysKilled = false #
var boysTalked = false #
var orcsKilled = false #
var goblinsKilled = false 
var cofferOpen = false 
var goldTaken = false #
var traderBuried = false #
var toldGuards = false
var toldMom = false #
var dogTreats = false
var recalledMeeting = false #
var dogFriend = false #

func savePlayerStart():
	daveDeath = false
	boysKilled = false
	boysTalked = false
	orcsKilled = false
	goblinsKilled = false
	cofferOpen = false
	goldTaken = false
	traderBuried = false
	toldGuards = false
	toldMom = false
	dogTreats = false
	recalledMeeting = false
	dogFriend = false

	maxHealth = 100
	health = 100
	healthPotion = 5
	playerStatus = "Exhausted"
	playerJoy = 0
	playerSlash = 70
	playerStab = 40
