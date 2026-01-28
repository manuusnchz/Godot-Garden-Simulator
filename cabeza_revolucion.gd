extends MeshInstance3D

# Configuración de la cabeza
var radio = 0.5
var segmentos_verticales = 10  # Calidad del perfil (arco)
var segmentos_radiales = 20    # Calidad del giro (revolución)

func _ready():
	generar_cabeza_revolucion()

func generar_cabeza_revolucion():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# --- PASO 1: GENERAR VÉRTICES ---
	# Bucle exterior: Gira alrededor del eje Y (Revolución)
	for i in range(segmentos_radiales + 1):
		var theta = (float(i) / segmentos_radiales) * TAU # Ángulo de giro (0 a 360)
		
		# Bucle interior: Dibuja el perfil de abajo a arriba (Arco)
		for j in range(segmentos_verticales + 1):
			# Queremos una SEMI-esfera, así que vamos de 0 a PI/2 (90 grados)
			var phi = (float(j) / segmentos_verticales) * (PI / 2)
			
			# Matemáticas de Coordenadas Esféricas a Cartesianas
			# Esto hace la revolución matemáticamente:
			var x = radio * cos(phi) * cos(theta)
			var z = radio * cos(phi) * sin(theta)
			var y = radio * sin(phi) # Altura
			
			# Definimos normales (para la luz) y UVs (para texturas)
			var vertice = Vector3(x, y, z)
			st.set_normal(vertice.normalized())
			st.set_uv(Vector2(float(i)/segmentos_radiales, float(j)/segmentos_verticales))
			st.add_vertex(vertice)

	# --- PASO 2: CONECTAR LOS PUNTOS (TRIÁNGULOS) ---
	var verts_por_anillo = segmentos_verticales + 1
	
	for i in range(segmentos_radiales):
		for j in range(segmentos_verticales):
			# Calculamos los índices de los 4 vértices de un "cuadrado"
			var actual = i * verts_por_anillo + j
			var siguiente = (i + 1) * verts_por_anillo + j
			
			# Triángulo 1
			st.add_index(actual)
			st.add_index(siguiente)
			st.add_index(actual + 1)
			
			# Triángulo 2
			st.add_index(siguiente)
			st.add_index(siguiente + 1)
			st.add_index(actual + 1)
	
	# --- PASO 3: CREAR LA MALLA FINAL ---
	# Generamos las tangentes para que la iluminación sea correcta
	st.generate_tangents()
	
	# Asignamos la malla creada a este MeshInstance3D
	mesh = st.commit()
	
	# (Opcional) Asignar un material de piel
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.8, 0.6) # Color piel
	material_override = material
