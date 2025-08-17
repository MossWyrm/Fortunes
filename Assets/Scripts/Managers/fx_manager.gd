extends Node
class_name FXManager
## Effects manager for particle systems
##
## Manages visual feedback particles like success and failure effects.
## Integrates with the EventBus system to respond to game events.

#region Node References
@onready var success_particle: CPUParticles2D = $Success
@onready var failure_particle: CPUParticles2D = $Failure
#endregion

#region Constants
const CARD_SIZE: Vector2 = Vector2(GameConstants.CARD_ART_WIDTH, GameConstants.CARD_ART_HEIGHT) / 2
const CARD_POSITION: Vector2 = Vector2(124, 153) + (CARD_SIZE / 2)
const PARTICLE_SIZE_MULTIPLIER: float = 1.1
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect to event bus signals
func _connect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(GameManager.game_state.event_bus.particle_effect_requested, _on_particle_effect_requested, "FXManager particle effects")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(GameManager.game_state.event_bus.particle_effect_requested, _on_particle_effect_requested, "FXManager particle effects")
#endregion

#region Event Handlers
# Handle particle effect requests from event bus
func _on_particle_effect_requested(particle_type: DataStructures.ParticleType) -> void:
	match particle_type:
		DataStructures.ParticleType.SUCCESS:
			emit_success()
		DataStructures.ParticleType.FAILURE:
			emit_failure()
		_:
			push_warning(DescriptionFormatter.format_warning_message("FXManager", "Unknown particle type requested: " + str(particle_type)))
#endregion

#region Particle Emission
# Emit success particle effect
func emit_success() -> void:
	if success_particle:
		_setup_particle_bounds(success_particle, CARD_POSITION, CARD_SIZE * PARTICLE_SIZE_MULTIPLIER)
		success_particle.emitting = true

# Emit failure particle effect
func emit_failure() -> void:
	if failure_particle:
		_setup_particle_bounds(failure_particle, CARD_POSITION, CARD_SIZE * PARTICLE_SIZE_MULTIPLIER)
		failure_particle.emitting = true

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