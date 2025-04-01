extends Button

var next_language_index = 1
var languages: Array = ["en", "cz", "ru"]

func _on_pressed() -> void:
	change_language(languages[next_language_index])
	next_language_index = (next_language_index + 1) % languages.size()

func change_language(lang: String):
	TranslationServer.set_locale(lang)
	
