extends Node
class_name FXManager
## Effects manager for particle systems
##
## Manages visual feedback particles like success and failure effects.
## Integrates with the EventBus system to respond to game events.

@onready var success_particle: CPUParticles2D = $Success
@onready var failure_particle: CPUParticles2D = $Failure

const CARD_SIZE: Vector2 = Vector2(GameConstants.CARD_ART_WIDTH, GameConstants.CARD_ART_HEIGHT) / 2
const PARTICLE_SIZE_MULTIPLIER: float = 1.1
const SUCCESS_DEFAULT_DURATION: float = 2.0
const FAILURE_DEFAULT_DURATION: float = 2.0
var screen_centre: Vector2:
	get:
		return get_viewport().get_visible_rect().size / 2

func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	EventBus.request_vfx.connect(_on_particle_effect_requested)

# Handle particle effect requests from event bus
func _on_particle_effect_requested(particle_type: DataStructures.VFXType, animation_duration: float = -1) -> void:
	match particle_type:
		DataStructures.VFXType.CARD_SUCCESS:
			emit_success(animation_duration)
		DataStructures.VFXType.CARD_FAILURE:
			emit_failure(animation_duration)
		_:
			push_warning(DescriptionFormatter.format_warning_message("FXManager", "Unknown particle type requested: " + str(particle_type)))

#region Particle Emission
# Emit success particle effect
func emit_success(animation_duration: float) -> void:
	if success_particle:
		_setup_particle_bounds(success_particle, screen_centre, CARD_SIZE * PARTICLE_SIZE_MULTIPLIER)
		success_particle.emitting = true
		success_particle.speed_scale = (1 / (animation_duration / SUCCESS_DEFAULT_DURATION)) if animation_duration > 0 else 1.0

# Emit failure particle effect
func emit_failure(animation_duration: float) -> void:
	if failure_particle:
		_setup_particle_bounds(failure_particle, screen_centre, CARD_SIZE * PARTICLE_SIZE_MULTIPLIER)
		failure_particle.emitting = true
		failure_particle.speed_scale = (1 / (animation_duration / FAILURE_DEFAULT_DURATION)) if animation_duration > 0 else 1.0

# Configure particle bounds and position
func _setup_particle_bounds(particle: CPUParticles2D, pos: Vector2, size: Vector2) -> void:
	if not particle:
		return
	
	particle.position = pos
	
	# Set emission shape based on size
	if size.x > 0 or size.y > 0:
		particle.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particle.emission_rect_extents = size
	else:
		particle.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
#endregion