extends System

const SystemA = preload("res://addons/gecs/tests/systems/s_test_a.gd")
const SystemB = preload("res://addons/gecs/tests/systems/s_test_b.gd")
const SystemD = preload("res://addons/gecs/tests/systems/s_test_d.gd")
const C_TestA = preload("res://addons/gecs/tests/components/c_test_a.gd")
const C_TestB = preload("res://addons/gecs/tests/components/c_test_b.gd")
const C_TestC = preload("res://addons/gecs/tests/components/c_test_c.gd")
const TestA = preload("res://addons/gecs/tests/entities/e_test_a.gd")
const TestB = preload("res://addons/gecs/tests/entities/e_test_b.gd")
const TestC = preload("res://addons/gecs/tests/entities/e_test_c.gd")


func deps():
	return {
		Runs.After: [SystemB],  # Runs after SystemA
		Runs.Before: [SystemD],  # This system rubs before SystemC
	}


func query():
	return q.with_all([C_TestC])


func process(entity: Entity, delta: float):
	var a = entity.get_component(C_TestC)
	a.value += 1
	print("TestASystem: ", a.value)
