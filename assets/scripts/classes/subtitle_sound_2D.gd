class_name AudioSubtitlable2D
extends AudioStreamPlayer2D

@export var subtitle = ""

func subtitle_play(time_from = 0.0) -> void:
	play(time_from)
	showSubtitles()

func showSubtitles():
	if (subtitle != "" 
	and (int(SaveSystem.optionsData.audio_subtitles) == 3 
	or (int(SaveSystem.optionsData.audio_subtitles) == 2) and bus == "SFX"
	or (int(SaveSystem.optionsData.audio_subtitles) == 1 and bus == "Voicelines"))): Subtitles.addSubtitle(subtitle)
