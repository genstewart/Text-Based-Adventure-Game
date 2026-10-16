extends Node

const textspeed = .035

#player stats
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
var bossName = "Gary"
var bossSlain = "Griffin"

#text input for npc interaction
var prevInput = ""

#player events to effect story
var boysKilled = false
var boysTalked = false
var orcsKilled = false


func savePlayerStart():
	null
