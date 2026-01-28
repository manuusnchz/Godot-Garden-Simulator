extends CharacterBody3D

# --- VARIABLES ---
@export var escena_arbol : PackedScene
@export var escena_roca : PackedScene
@export var escena_molino : PackedScene

@export var cartel_alerta: Label

# Esta variable cambia según el botón que pulses
@export var objeto_a_construir : PackedScene 

@onready var mensaje_molino = %MensajeMolino
@onready var timer_mensaje = %TimerMensaje

@onready var pala = %Pala

# --- VARIABLES DE ANIMACIÓN BRAZOS ---
@onready var contenedor_brazos = $Ojos/Brazos
const FRECUENCIA_BALANCEO = 2.0 # Qué tan rápido se mueven
const AMPLITUD_BALANCEO = 0.08  # Cuánto se mueven (distancia)
var tiempo_balanceo = 0.0
var modo_borrado : bool = false
var electrocutado = false

# Referencias a nodos
@onready var raycast = $Ojos/RayCast3D 
@onready var camera = $Ojos
# Variables de movimiento
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	raycast.add_exception(self) # Para no dispararte al pie
	
	# OPCIONAL: Empezar con el árbol seleccionado por defecto para que no de error
	if escena_arbol:
		objeto_a_construir = escena_arbol

# --- LÓGICA DE LOS BOTONES (¡AQUÍ ESTABA EL FALLO!) ---
# Estas son las funciones que Godot conecta automáticamente.
# Tienen que tener el código dentro, no estar vacías.

func _on_boton_borrar_pressed():
	modo_borrado = true
	objeto_a_construir = null # Limpiamos selección de construcción
	print("--> MODO: ¡Eliminación activada!")
	
	if pala != null:
		pala.visible = true
		


func _on_boton_arbol_pressed():
	modo_borrado = false
	objeto_a_construir = escena_arbol
	print("--> CAMBIO: ¡Has seleccionado el Árbol!")
	
	if pala != null:
		pala.visible = false

func _on_boton_roca_pressed():
	modo_borrado = false
	objeto_a_construir = escena_roca
	print("--> CAMBIO: ¡Has seleccionado la Roca!")
	
	if pala != null:
		pala.visible = false
	
	
func _on_boton_molino_pressed():
	modo_borrado = false
	objeto_a_construir = escena_molino
	print("--> MODO: Construir Molino Articulado")
	
	if pala != null:
		pala.visible = false

# --- INPUT Y MOVIMIENTO ---
func _unhandled_input(event):
	# Movimiento de cámara
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	# Salir con ESC y liberar ratón
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	# --- CLIC PARA CONSTRUIR ---
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Si el ratón se ve (estamos en menú), NO construir
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			return
		construir_objeto()

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	if electrocutado: 
		move_and_slide()
		return

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	animar_brazos(delta)
	move_and_slide()

# --- FUNCIÓN DE CONSTRUCCIÓN ---
func construir_objeto():
	if raycast.is_colliding():
		# 1. Identificamos qué objeto ha tocado el rayo
		var objeto_tocado = raycast.get_collider()
		
		if modo_borrado:
			# LÓGICA DE ELIMINACIÓN
			# Verificamos que no sea el suelo antes de borrar [cite: 1082]

			if objeto_tocado != null and objeto_tocado.name != "Suelo" :
				var objeto_completo = objeto_tocado.owner if objeto_tocado.owner else objeto_tocado
				print("Eliminando objeto completo: ", objeto_completo.name)
				objeto_completo.queue_free()
			else:
				print("No puedes borrar el suelo")
		else:
			# LÓGICA DE CONSTRUCCIÓN (Tu código original)
				if objeto_a_construir != null:
					var punto_impacto = raycast.get_collision_point()
					var nuevo_objeto = objeto_a_construir.instantiate()
					get_parent().add_child(nuevo_objeto)
					nuevo_objeto.global_position = punto_impacto
					nuevo_objeto.rotate_y(randf_range(0, 6.28))
				
				if objeto_a_construir == escena_molino:
					mensaje_molino.visible = true
					timer_mensaje.start() # Iniciamos la cuenta atrás para ocultarlo
			
			
func animar_brazos(delta):
	
	# Solo animamos si estamos en el suelo y moviéndonos
	if is_on_floor() and velocity.length() > 0:
		tiempo_balanceo += delta * velocity.length() * FRECUENCIA_BALANCEO
		
		# Matemáticas de ondas (Seno para Y, Coseno para X hace un movimiento en '8')
		var target_pos_y = sin(tiempo_balanceo) * AMPLITUD_BALANCEO
		var target_pos_x = cos(tiempo_balanceo * 0.5) * AMPLITUD_BALANCEO
		
		# Aplicamos el movimiento suavemente (Lerp)
		contenedor_brazos.position.y = lerp(contenedor_brazos.position.y, target_pos_y , 10 * delta)
		contenedor_brazos.position.x = lerp(contenedor_brazos.position.x, target_pos_x, 10 * delta)
	
	else:
		# Si estamos parados, volver a la posición de reposo suavemente
		contenedor_brazos.position.y = lerp(contenedor_brazos.position.y, 0.0, 10 * delta)
		contenedor_brazos.position.x = lerp(contenedor_brazos.position.x, 0.0, 10 * delta)


func _on_timer_mensaje_timeout() -> void:
	if mensaje_molino != null:
		mensaje_molino.visible = false
		print("Timer finalizado: Mensaje oculto.")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self and not electrocutado:
		# TRUCO: Saltamos hacia el lado OPUESTO al que nos movíamos
		# Si corríamos hacia la valla, el rebote nos lanza hacia atrás
		var direccion_rebote = -velocity.normalized()
		
		# Si por lo que sea estábamos quietos, saltamos hacia atrás por defecto
		if direccion_rebote == Vector3.ZERO:
			direccion_rebote = Vector3.BACK
			
		ejecutar_salto(direccion_rebote)


func ejecutar_salto(dir):
	electrocutado = true
	
	if cartel_alerta:
		cartel_alerta.show()
		
	# Aplicamos la fuerza de choque
	velocity.x = dir.x * 12.0
	velocity.z = dir.z * 12.0
	velocity.y = 5.0 # Un saltito hacia arriba para que no arrastre
	await get_tree().create_timer(1.0).timeout
	
	# Ocultamos el mensaje
	if cartel_alerta:
		cartel_alerta.hide()
	# Esperamos un momento para que el jugador recupere el control
	electrocutado = false
	
func dar_salto_atras():
	electrocutado = true
	
	# 1. Empujamos al personaje hacia atrás y arriba
	# 'velocity' es la variable que usa move_and_slide()
	velocity.y = 2.0    # Salto hacia arriba
	velocity.z = 15.0   # Empujón hacia atrás (ajusta según tu cámara)
	
	# 2. Esperamos un poco antes de dejar que el jugador vuelva a moverlo
	await get_tree().create_timer(0.4).timeout
	electrocutado = false
