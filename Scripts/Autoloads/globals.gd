extends Node

const PINK: Color = Color(1, 0.027, 0.753, 1); 
const CYAN: Color = Color(0.051, 0.996, 0.973, 1);
const WHITE: Color = Color.WHITE;

var is_look_inverted: bool = false;
var is_visualizer_disabled: bool = false;
var camera_sensitivity_setting: float = 0.45;
var is_game_started: bool = false;

## Function that 'stops' time for a very brief moment.
## Timescale is how slow you want the game to run (0.5 for half speed etc)
## Duration is how long you want it to remain that way
## Note that timescale must be > 0, as time will never resume if the engine has stopped counting
func freeze_frame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale;
	await get_tree().create_timer(duration * timescale).timeout;
	Engine.time_scale = 1.0;

## Plug into a physics process to change desired values based on the beat.
## delta: Pass the delta variable from the process method.
## variable_to_sync: The top level variable itself.
## property_to_sync: String representation of the property. If nested use :, ie "property:nested_property".
## min_threshold: The minimum or base value of the property. If above, lerp towards this min value.
## max_threshold: The maximum value the property should be at before we start to increase the power.
## min_power: Lowest energy value of the property.
## max_power: Highest energy value of the property.
func visualizer(delta: float, variable_to_sync: Variant, property_to_sync: String, \
				min_threshold: float, max_threshold: float, \
				min_power: float, max_power: float) -> void:
	if is_visualizer_disabled: return
	
	var spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(1,0);
	var volume = spectrum.get_magnitude_for_frequency_range(100, 250).length();
	var bg_energy: float = variable_to_sync.get_indexed(property_to_sync);
	
	if bg_energy > min_threshold:
		bg_energy -= delta*2;
	elif bg_energy < max_threshold and volume > 0.3:
		bg_energy = 5 * volume;
	
	variable_to_sync.set_indexed( property_to_sync, clampf(bg_energy, min_power, max_power) );
