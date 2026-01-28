extends StaticBody3D

# Referencias a los nodos de tu jerarquía [cite: 913-918]
@onready var cabeza = $Molino/NodoCabeza
@onready var aspas = $Molino/NodoCabeza/NodoAspas

# Variables de velocidad y estado
@export var velocidad_aspas := 50.0
@export var rapidez_vaiven := 0.2122
var girar_aspas := true   # Controlado por tecla 1
var mover_cabeza := true  # Controlado por tecla 2
var tiempo := 0.0

func _process(delta):

	
	# Tecla 1: Alternar giro de Aspas
	if Input.is_key_pressed(KEY_1):
		girar_aspas = !girar_aspas
		print("Aspas: ", "Activadas" if girar_aspas else "Paradas")

	# Tecla 2: Alternar vaivén de Cabeza
	if Input.is_key_pressed(KEY_2):
		mover_cabeza = !mover_cabeza
		print("Cabeza: ", "Activada" if mover_cabeza else "Parada")

	
	
	if girar_aspas:

		aspas.rotate_x(deg_to_rad(velocidad_aspas * delta))
		
	if mover_cabeza:
		tiempo += delta
	
		var angulo_vaiven = sin(tiempo * rapidez_vaiven) * deg_to_rad(90)
		cabeza.rotation.y = angulo_vaiven
