extends Node

const textspeed = .035

#player stats
var health = 100
var healthPotion = 5
var playerStatus = "Empty"
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
var daveDeath = false
var boysKilled = false
var boysTalked = false
var orcsKilled = false
var goblinsKilled = false
var cofferOpen = false
var goldTaken = false
var traderBuried = false
var toldMom = false
var dogTreats = false
var recalledMeeting = false
var dogFriend = false

func savePlayerStart():
	null
