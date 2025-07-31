extends Node
class_name fx_manager

@onready var success_particle: CPUParticles2D = $Success
@onready var failure_particle: CPUParticles2D = $Failure

var card_size: Vector2 = Vector2(400,699)/2
var card_pos: Vector2 = Vector2(124,153) + (card_size/2)

func _ready():
	Events.particle.connect(emit_particle)

func emit_particle(particle: ID.ParticleType) -> void:
	match particle:
		ID.ParticleType.SUCCESS:
			emit_success()
		ID.ParticleType.FAILURE:
			emit_failure()

func emit_success() -> void:
	set_particle_bounds(success_particle, card_pos, card_size*1.1)
	success_particle.emitting = true

func emit_failure() -> void:
	set_particle_bounds(failure_particle, card_pos, card_size*1.1)
	failure_particle.emitting = true

func set_particle_bounds(particle: CPUParticles2D, pos: Vector2, size: Vector2) -> void:
	particle.position = pos
	particle.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE if size.x > 0 or size.y > 0 else CPUParticles2D.EMISSION_SHAPE_POINT
	particle.emission_rect_extents = size