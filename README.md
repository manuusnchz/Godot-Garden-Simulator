<div align="center">

  # 🌲 3D Interactive Sandbox Environment
  
  **Simulador de Construcción y Física en Tiempo Real desarrollado en Godot**
  
  ![Godot Engine](https://img.shields.io/badge/GODOT%20ENGINE-4.0+-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)
  ![GDScript](https://img.shields.io/badge/Code-GDScript-478CBF?style=for-the-badge&logo=godot-engine&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Finalizado-success?style=for-the-badge)

  <img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExM2Q1Z..." alt="Gameplay Demo" width="100%" />

</div>

---

## 📋 Descripción del Proyecto
Este proyecto es una aplicación interactiva en 3D desarrollada con el motor Godot.

El objetivo principal es la implementación de un **motor de construcción en tiempo real** donde el usuario (en primera persona) puede modificar el entorno, gestionar entidades jerárquicas y experimentar con físicas de colisión avanzadas.

## ⚙️ Características Técnicas (Engineering Highlights)

### 1. Sistema de Construcción (Raycasting) 🏗️
Implementación de lógica vectorial para la detección de superficies.
- Uso de `RayCast3D` desde la cámara ("Ojos") para calcular el punto exacto de instanciación en el mundo 3D.
- **Gestión de Estados:** Sistema lógico para alternar entre modo *Construcción* y *Borrado* (instanciación/eliminación de nodos en el árbol de escena) .

### 2. Modelado Jerárquico y Animación Procedural 🌬️
Gestión de transformaciones relativas en nodos complejos (`Parent-Child`).
- **Molino Interactivo:** Control de rotación de aspas y orientación mediante input de usuario, manipulando transformaciones locales en tiempo real.
- **Entidad Autónoma (NPC):** Agente con IA básica de navegación aleatoria y sistema de evitación de obstáculos mediante detección de colisiones (`CollisionShape3D`).

### 3. Sistema de Límites y Físicas (The "Fence" Logic) ⚡
Implementación de límites físicos interactivos mediante `StaticBody3D`.
- **Respuesta Física:** Cálculo de vectores de repulsión (`move_and_slide` inverso) para simular el impacto eléctrico al tocar los límites del mapa.
- **UI Reactiva:** Sistema de notificaciones en pantalla (`CanvasLayer`) disparado por señales (Signals) al detectar colisión con la valla.

### 4. Entorno y Renderizado ☀️
- Iluminación dinámica mediante `DirectionalLight` con sombras activadas.
- Atmósfera generada procedurally (`ProceduralSky`) dentro del `WorldEnvironment`.

---

## 🎮 Controles

| Tecla | Acción |
| :--- | :--- |
| **W, A, S, D** | Movimiento del personaje |
| **Mouse** | Cámara y orientación |
| **Click Izquierdo** | Construir / Borrar objeto |
| **ESC** | Alternar modo Ratón (Selección de UI) / Cámara |
| **1 / 2** | Activar o Desactivar animación del Molino |

---


   
