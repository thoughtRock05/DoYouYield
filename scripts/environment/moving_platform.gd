@tool
extends AnimatableBody2D

@export var rel_x: float = 0.0:
	set(value):
		rel_x = value
		queue_redraw()
@export var rel_y: float = 0.0:
	set(value):
		rel_y = value
		queue_redraw()
@export var duration: float = 1.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var start_pos = position
	var end_pos = start_pos + Vector2(rel_x, rel_y)
	
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position", end_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _draw() -> void:
	if Engine.is_editor_hint():
		var destination = Vector2(rel_x, rel_y)
		if destination == Vector2.ZERO:
			return
		
		draw_dashed_line(Vector2.ZERO, destination, Color(0.278, 0.549, 0.749, 1.0), 2.0, 5.0)
		draw_circle(destination, 10.0, Color(0.278, 0.549, 0.749, 1.0))
