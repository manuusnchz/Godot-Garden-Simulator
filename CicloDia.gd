extends DirectionalLight3D

# Velocidad: Cuanto más alto, más rápido pasa el día.
# Prueba con 10.0 para verlo rápido, o 1.0 para que sea lento.
var velocidad_rotacion = 10.0 

func _process(delta):
	# Rotamos la luz en el eje X un poquito cada fotograma.
	# Esto simula que el sol sale por un lado y se pone por el otro.
	rotate_x(deg_to_rad(velocidad_rotacion) * delta)
