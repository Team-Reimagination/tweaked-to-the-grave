extends Node
func _ready():
	DiscordRPC.app_id = 1386468400733093888 
	DiscordRPC.details = "Fighting: The Hero in the Ra's Curse"
	DiscordRPC.state = "not having a heatstroke"
	DiscordRPC.large_image = "eydoo"
	DiscordRPC.large_image_text = "Try it now!"
	DiscordRPC.small_image = "seezee"
	DiscordRPC.small_image_text = "Trying his best!"

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"

	DiscordRPC.refresh()
