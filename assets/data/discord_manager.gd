extends Node

func _ready():
	DiscordRPC.app_id = 1386468400733093888 # Application ID
	DiscordRPC.details = "Tweaking to the Grave"
	DiscordRPC.state = "Tweaking"
	DiscordRPC.large_image = "Sigh" # Image key from "Art Assets"
	DiscordRPC.large_image_text = "Try it now!"

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system()) # "02:46 elapsed"
	# DiscordRPC.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00:00 remaining"

	DiscordRPC.refresh() # Always refresh after changing the values!
