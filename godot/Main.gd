extends Node2D

const WORLD_SIZE := Vector2(960.0, 540.0)
const BASE_X := 125.0
const FLOOR_Y := 405.0
const MAX_BASE_HP := 100
const ENEMY_COLORS := [Color("#ef476f"), Color("#ff9f1c"), Color("#9b5de5")]

var rng := RandomNumberGenerator.new()
var enemies: Array[Dictionary] = []
var traps: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var wave := 1
var wave_spawned := 0
var wave_total := 5
var wave_timer := 0.0
var spawn_timer := 0.0
var attack_cooldown := 0.0
var titan_cooldown := 0.0
var base_hp := MAX_BASE_HP
var energy := 35
var score := 0
var selected_target := -1
var trap_mode := false
var paused := false
var game_over := false
var titan: Dictionary = {}
var status_text := "Click a toilet to fire the sewer cannon."
var status_timer := 4.0

func _ready() -> void:
	rng.randomize()
	queue_redraw()

func _process(delta: float) -> void:
	if paused or game_over:
		queue_redraw()
		return
	wave_timer += delta
	spawn_timer -= delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	titan_cooldown = maxf(0.0, titan_cooldown - delta)
	status_timer = maxf(0.0, status_timer - delta)

	if wave_spawned < wave_total and spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_timer = maxf(0.35, 1.15 - wave * 0.04)
	if wave_spawned >= wave_total and enemies.is_empty() and wave_timer > 1.0:
		wave += 1
		wave_spawned = 0
		wave_total = 4 + wave * 2
		wave_timer = 0.0
		energy += 12
		_set_status("Wave %d incoming! Alliance energy +12." % wave)

	for enemy in enemies:
		enemy.position.x -= enemy.speed * delta
		enemy.attack_timer -= delta
		if enemy.position.x <= BASE_X + 38.0:
			base_hp -= enemy.damage
			_spawn_burst(enemy.position, Color("#ff595e"))
			enemy.hp = 0
			_set_status("The base was hit! Keep the toilets away.")
		elif enemy.attack_timer <= 0.0 and enemy.position.x < BASE_X + 130.0:
			enemy.attack_timer = 1.2
			base_hp -= 1
		enemy.hit_flash = maxf(0.0, enemy.hit_flash - delta)

	for trap in traps:
		trap.life -= delta
		trap.pulse += delta
		if trap.life > 0.0:
			for enemy in enemies:
				if enemy.position.distance_to(trap.position) < trap.radius:
					enemy.hp -= 8.0 * delta
					enemy.speed = minf(enemy.speed, 18.0)
					enemy.hit_flash = 0.08
		else:
			trap.life = -1.0
	traps = traps.filter(func(t: Dictionary) -> bool: return t.life > 0.0)

	if not titan.is_empty():
		titan.cooldown -= delta
		if titan.cooldown <= 0.0:
			var victim := _nearest_enemy(titan.position, 260.0)
			if victim >= 0:
				enemies[victim].hp -= 20.0
				enemies[victim].hit_flash = 0.15
				titan.cooldown = 0.75
				_spawn_burst(enemies[victim].position, Color("#00f5d4"))

	_cleanup_dead_enemies()
	if base_hp <= 0:
		game_over = true
		_set_status("The sewer gate fell. Press R to restart.")
	_update_particles(delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		paused = not paused
		_set_status("Paused." if paused else "Back to the sewer.")
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_R and game_over:
		get_tree().reload_current_scene()
		return
	if event.is_action_pressed("trap_mode") and not paused and not game_over:
		trap_mode = not trap_mode
		_set_status("Trap placement armed: click the floor." if trap_mode else "Trap placement cancelled.")
		return
	if event.is_action_pressed("summon_titan") and not paused and not game_over:
		_summon_titan()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_click(event.position)

func _handle_click(point: Vector2) -> void:
	if paused or game_over:
		return
	if trap_mode:
		if point.y > 205.0 and point.y < FLOOR_Y + 22.0 and energy >= 10:
			traps.append({"position": point, "life": 8.0, "pulse": 0.0, "radius": 72.0})
			energy -= 10
			trap_mode = false
			_set_status("Electro-plunger trap deployed.")
		else:
			_set_status("Traps must be placed on the sewer floor.")
		return
	var target := _nearest_enemy(point, 58.0)
	if target >= 0:
		selected_target = target
		if attack_cooldown <= 0.0:
			enemies[target].hp -= 25.0
			enemies[target].hit_flash = 0.18
			attack_cooldown = 0.18
			energy += 1
			_spawn_burst(enemies[target].position, Color("#ffd166"))
			_set_status("Sewer cannon hit! +1 energy.")
	else:
		_set_status("Aim at a toilet within the glowing ring.")

func _spawn_enemy() -> void:
	var kind := rng.randi_range(0, 2)
	var hp := 35.0 + wave * 7.0 + kind * 20.0
	var speed := 24.0 + wave * 2.0 - kind * 3.0
	enemies.append({
		"position": Vector2(875.0 + rng.randf_range(-20.0, 20.0), FLOOR_Y - 30.0 + rng.randf_range(-10.0, 4.0)),
		"hp": hp, "max_hp": hp, "speed": speed, "damage": 5 + kind * 2,
		"attack_timer": 1.0, "kind": kind, "hit_flash": 0.0
	})
	wave_spawned += 1

func _summon_titan() -> void:
	if not titan.is_empty():
		_set_status("Titan Drillman is already in the sewer.")
	elif titan_cooldown > 0.0:
		_set_status("Alliance reinforcements ready in %.1fs." % titan_cooldown)
	elif energy < 25:
		_set_status("Need 25 energy to summon Titan Drillman.")
	else:
		energy -= 25
		titan = {"position": Vector2(245.0, FLOOR_Y - 50.0), "cooldown": 0.1}
		titan_cooldown = 18.0
		_set_status("Titan Drillman joined the alliance!")

func _nearest_enemy(point: Vector2, radius: float) -> int:
	var best := -1
	var best_distance := radius
	for i in enemies.size():
		var distance := point.distance_to(enemies[i].position)
		if distance < best_distance:
			best = i
			best_distance = distance
	return best

func _cleanup_dead_enemies() -> void:
	var survivors: Array[Dictionary] = []
	for enemy in enemies:
		if enemy.hp <= 0.0:
			score += 10 + enemy.kind * 5
			energy += 2
			_spawn_burst(enemy.position, Color("#06d6a0"))
		else:
			survivors.append(enemy)
	enemies = survivors

func _spawn_burst(at: Vector2, color: Color) -> void:
	for i in 6:
		particles.append({"position": at, "velocity": Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(25.0, 70.0), "life": 0.45, "color": color})

func _update_particles(delta: float) -> void:
	for particle in particles:
		particle.position += particle.velocity * delta
		particle.velocity *= 0.92
		particle.life -= delta
	particles = particles.filter(func(p: Dictionary) -> bool: return p.life > 0.0)

func _set_status(message: String) -> void:
	status_text = message
	status_timer = 3.0

func _draw() -> void:
	_draw_background()
	_draw_base()
	_draw_traps()
	_draw_titan()
	for i in enemies.size():
		_draw_enemy(enemies[i], i)
	for particle in particles:
		draw_circle(particle.position, 3.0, particle.color)
	_draw_hud()

func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#101827"))
	draw_rect(Rect2(0, 155, 960, 250), Color("#173042"))
	draw_rect(Rect2(0, FLOOR_Y, 960, 135), Color("#0c1a27"))
	for y in range(180, 400, 38):
		draw_line(Vector2(0, y), Vector2(960, y), Color("#1f4554"), 2.0)
	for x in range(20, 960, 80):
		draw_line(Vector2(x, 155), Vector2(x - 20, 405), Color("#153748"), 2.0)
	draw_line(Vector2(BASE_X + 35, 165), Vector2(BASE_X + 35, FLOOR_Y), Color("#ffd166"), 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(BASE_X + 42, 190), "BREACH LINE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffd166"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 190), "SEWER SECTOR 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8ecae6"))

func _draw_base() -> void:
	draw_rect(Rect2(43, 315, 100, 88), Color("#354f52"), true)
	draw_rect(Rect2(53, 327, 80, 65), Color("#52796f"), true)
	draw_circle(Vector2(93, 324), 30, Color("#cad2c5"))
	draw_circle(Vector2(93, 324), 20, Color("#2f3e46"))
	draw_line(Vector2(143, 346), Vector2(143, 405), Color("#ffd166"), 6.0)
	draw_string(ThemeDB.fallback_font, Vector2(50, 430), "ALLIANCE GATE", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#cad2c5"))

func _draw_enemy(enemy: Dictionary, index: int) -> void:
	var pos: Vector2 = enemy.position
	var color: Color = ENEMY_COLORS[enemy.kind]
	if enemy.hit_flash > 0.0:
		color = Color.WHITE
	draw_circle(pos + Vector2(0, -18), 24, color)
	draw_rect(Rect2(pos.x - 25, pos.y - 18, 50, 32), color, true)
	draw_rect(Rect2(pos.x - 18, pos.y - 3, 36, 20), Color("#f8f9fa"), true)
	draw_circle(pos + Vector2(-9, 5), 4, Color("#111827"))
	draw_circle(pos + Vector2(9, 5), 4, Color("#111827"))
	draw_rect(Rect2(pos.x - 28, pos.y - 52, 56, 6), Color("#2b2d42"), true)
	draw_rect(Rect2(pos.x - 28, pos.y - 52, 56 * clampf(enemy.hp / enemy.max_hp, 0.0, 1.0), 6), Color("#06d6a0"), true)
	if index == selected_target:
		draw_arc(pos, 39.0, 0.0, TAU, 32, Color("#ffd166"), 2.0)

func _draw_traps() -> void:
	for trap in traps:
		var pulse: float = 68.0 + sin(trap.pulse * 8.0) * 5.0
		draw_circle(trap.position, pulse, Color(0.0, 0.95, 0.83, 0.08))
		draw_arc(trap.position, 25.0, 0.0, TAU, 20, Color("#00f5d4"), 4.0)
		draw_line(trap.position - Vector2(14, 0), trap.position + Vector2(14, 0), Color("#00f5d4"), 3.0)

func _draw_titan() -> void:
	if titan.is_empty():
		return
	var pos: Vector2 = titan.position
	draw_circle(pos, 35.0, Color("#00f5d4"))
	draw_rect(Rect2(pos.x - 25, pos.y - 25, 50, 60), Color("#118ab2"), true)
	draw_circle(pos + Vector2(0, -35), 22, Color("#073b4c"))
	draw_line(pos + Vector2(20, -5), pos + Vector2(53, -35), Color("#ffd166"), 9.0)
	draw_string(ThemeDB.fallback_font, pos + Vector2(-48, 55), "TITAN", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#00f5d4"))

func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, 960, 112), Color("#08111c"), true)
	draw_string(ThemeDB.fallback_font, Vector2(28, 35), "SKIBIDI TOILET DEFENSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#f1faee"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 65), "WAVE %d  |  TOILETS %d/%d" % [wave, wave_spawned, wave_total], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#8ecae6"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 91), "ENERGY %d   SCORE %d" % [energy, score], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#ffd166"))
	draw_string(ThemeDB.fallback_font, Vector2(680, 35), "GATE HP", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#cad2c5"))
	draw_rect(Rect2(680, 48, 220, 18), Color("#2b2d42"), true)
	draw_rect(Rect2(680, 48, 220 * clampf(float(base_hp) / MAX_BASE_HP, 0.0, 1.0), 18), Color("#06d6a0"), true)
	draw_string(ThemeDB.fallback_font, Vector2(680, 84), "T: TRAP (10)   H: TITAN (25)   P: PAUSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#adb5bd"))
	if status_timer > 0.0:
		draw_string(ThemeDB.fallback_font, Vector2(260, 505), status_text, HORIZONTAL_ALIGNMENT_LEFT, 450, 16, Color("#f1faee"))
	if trap_mode:
		draw_string(ThemeDB.fallback_font, Vector2(350, 135), "TRAP MODE: click sewer floor", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#00f5d4"))
	if paused:
		draw_rect(Rect2(315, 220, 330, 90), Color("#08111cdd"), true)
		draw_string(ThemeDB.fallback_font, Vector2(425, 275), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#ffd166"))
	if game_over:
		draw_rect(Rect2(245, 205, 470, 130), Color("#08111cee"), true)
		draw_string(ThemeDB.fallback_font, Vector2(350, 255), "GATE OVERRUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#ff595e"))
		draw_string(ThemeDB.fallback_font, Vector2(335, 290), "Press R to restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f1faee"))
