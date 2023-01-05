extends VBoxContainer

var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

func change_bus_volume(bus_index: int, value: float):
	AudioServer.set_bus_volume_db(bus_index, value)
	if value == -30:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)

func _on_SFXSlider_value_changed(value):
	change_bus_volume(sfx_bus, value)

func _on_MusicSlider_value_changed(value):
	change_bus_volume(music_bus, value)
