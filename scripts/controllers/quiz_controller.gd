extends Node

@export var quiz: QuizTheme
@export var success_color: Color
@export var failed_color: Color

@onready var question = $Container/QuizBox/QuestionBox/VContainer/Question
@onready var continue_button = $Container/QuizBox/ContinueButton

var buttons: Array[Button]
var index: int
var correct: int
var points: int

var current_quiz: QuizQuestion:
	get:
		return quiz.theme[index]

func _ready():
	points = 0
	
	continue_button.hide()
	continue_button.button_down.connect(on_continue)
	
	for button in $Container/QuizBox/QuestionBox/VContainer/Options.get_children():
		buttons.append(button)
	
	quiz.theme.shuffle() 
	load_quiz()

func load_quiz() -> void:
	if index >= quiz.theme.size():
		game_over()
		return
	question.text = current_quiz.question_statement
	
	var options = current_quiz.options
	options.shuffle()
	for i in buttons.size():
		buttons[i].text = options[i]
		buttons[i].disabled = false
		buttons[i].pressed.connect(_on_answer.bind(buttons[i]))

func _on_answer(button: Button) -> void:
	disable_buttons()
	if current_quiz.correct_answer == button.text:
		button.modulate = success_color
		points += 1
	else:
		button.modulate = failed_color
	
	next_question()

func disable_buttons() -> void:
	for bt in buttons:
		bt.disabled = true

func next_question() -> void:
	await get_tree().create_timer(2).timeout
	
	for button in buttons:
		button.modulate = Color.WHITE
		button.pressed.disconnect(_on_answer)
	
	index += 1
	load_quiz()

func game_over() -> void:
	$Container/QuizBox.hide()
	$Container/EndedQuiz/Points.text = str("Pontuação: ", points, "/", quiz.theme.size())
	$Container/EndedQuiz.show()

func on_continue() -> void:
	index += 1
	load_quiz()
