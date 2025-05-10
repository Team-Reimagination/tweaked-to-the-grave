class_name AudioSubtitlable3D
extends AudioStreamPlayer3D

@export var subtitle = ""

func subtitle_play(time_from = 0.0) -> void:
	play(time_from)
	showSubtitles()

func showSubtitles():
	if (subtitle != "" 
	and (int(SaveSystem.optionsData.get("audio_subtitles", 0)) == 3 
	or (int(SaveSystem.optionsData.get("audio_subtitles", 0)) == 2) and bus == "SFX"
	or (int(SaveSystem.optionsData.get("audio_subtitles", 0)) == 1 and bus == "Voicelines"))): Subtitles.addSubtitle(subtitle)
