extends CharacterBody3D

# --- CONFIGURACIÓN ---
const VELOCIDAD_CAMINAR = 2.0
const GRAVEDAD = 9.8

# Referencias a las ARTICULACIONES (Los Node3D, no los MeshInstance)
# Asegúrate de que los nombres coinciden con tu escena
@onready var hombro_izq = $Torso/HombroIzq
@onready var hombro_der = $Torso/HombroDch
@onready var cadera_izq = $Torso/CaderaIzq
@onready var cadera_der = $Torso/CaderaDch

# Variables para la IA (Caminar aleatorio)
var direccion_destino = Vector3.FORWARD
var tiempo_cambio_rumbo = 0.0

func _physics_process(delta):
	# 1. APLICAR GRAVEDAD
	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta

	# 2. IA BÁSICA (CEREBRO)
	# Restamos tiempo al temporizador
	tiempo_cambio_rumbo -= delta
	
	# Si se acaba el tiempo o chocamos contra un muro, cambiamos de rumbo
	if tiempo_cambio_rumbo <= 0 or is_on_wall():
		elegir_nuevo_rumbo()
	
	# 3. MOVERSE
	# Calculamos la velocidad hacia donde estamos mirando (Basis.z es "adelante")
	var direccion = transform.basis.z
	velocity.x = direccion.x * VELOCIDAD_CAMINAR
	velocity.z = direccion.z * VELOCIDAD_CAMINAR
	
	move_and_slide()
	
	# 4. ANIMACIÓN JERÁRQUICA (BRAZOS Y PIERNAS)
	animar_esqueleto()

func elegir_nuevo_rumbo():
	# Giramos el cuerpo entero una cantidad aleatoria (entre 0 y 360 grados)
	rotation.y = randf_range(0, TAU)
	
	# Reiniciamos el temporizador (caminará en esa dirección entre 3 y 8 segundos)
	tiempo_cambio_rumbo = randf_range(3.0, 8.0)

func animar_esqueleto():
	# Usamos el tiempo global para generar ondas senoidales
	# Dividimos por 200 para controlar la velocidad de la animación
	var tiempo = Time.get_ticks_msec() / 200.0
	
	# --- PIERNAS ---
	# Usamos el Seno (sin). Una pierna va normal y la otra inversa (+ PI)
	cadera_izq.rotation.x = sin(tiempo) * 0.8  # 0.8 es la amplitud (zancada)
	cadera_der.rotation.x = sin(tiempo + PI) * 0.8
	
	# --- BRAZOS ---
	# Los brazos van contrarios a las piernas para equilibrio natural.
	# Brazo Izquierdo va con Pierna Derecha
	hombro_izq.rotation.x = sin(tiempo + PI) * 0.5 # 0.5 es amplitud de brazo
	hombro_der.rotation.x = sin(tiempo) * 0.5
