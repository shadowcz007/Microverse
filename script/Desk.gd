extends StaticBody2D

@export var base_z_index: int = 0  # 基础Z轴顺序
@export var y_threshold: float = 32.0  # Y轴判定阈值，用于确定前后关系

func _ready():
	# 设置初始Z轴顺序
	z_index = base_z_index + 1
	
	# 添加定时器来定期更新Z轴顺序
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1  # 每0.1秒更新一次
	timer.timeout.connect(_update_z_order)
	timer.start()

func _update_z_order():
	# 获取所有角色和椅子
	var characters = get_tree().get_nodes_in_group("controllable_characters")
	var chairs = get_tree().get_nodes_in_group("chairs")  # 需要将椅子加入chairs组
	
	# 获取桌子的Y坐标
	var desk_y = global_position.y
	
	# 设置一个合理的基础 z_index，确保不会太小
	var new_z_index = base_z_index + 1
	
	# 检查与角色的关系
	for character in characters:
		if abs(character.global_position.y - desk_y) <= y_threshold:
			if character.global_position.y < desk_y:
				# 角色在桌子后面，桌子应该在角色上面
				new_z_index = max(new_z_index, character.z_index + 1)
			else:
				# 角色在桌子前面，桌子应该在角色下面
				# 但不要低于 base_z_index，确保不会变成负数
				new_z_index = min(new_z_index, max(base_z_index, character.z_index - 1))
	
	# 检查与椅子的关系
	for chair in chairs:
		if abs(chair.global_position.y - desk_y) <= y_threshold:
			if chair.global_position.y < desk_y:
				# 椅子在桌子后面
				new_z_index = max(new_z_index, chair.z_index + 1)
			else:
				# 椅子在桌子前面
				new_z_index = min(new_z_index, max(base_z_index, chair.z_index - 1))
	
	# 确保 z_index 不会太小，至少保持 base_z_index + 1
	z_index = max(new_z_index, base_z_index + 1)
