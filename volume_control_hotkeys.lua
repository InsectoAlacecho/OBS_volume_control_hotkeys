obs = obslua

source_name = "PLACEHOLDER1"            -- Name of the source
filter_name = "PLACEHOLDER2"    -- Name of the Gain filter
step_size = 2.0                  -- Step size in dB

hotkey_id_up = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_down = obs.OBS_INVALID_HOTKEY_ID
hotkey_id_reset = obs.OBS_INVALID_HOTKEY_ID

function script_description()
    return "Increase, decrease and reset the volume of a filter on a specific source in 2 dB steps (adjustable)."
end

function script_load(settings)
    hotkey_id_up = obs.obs_hotkey_register_frontend("volume_increase", "Increase Volume", on_increase_pressed)
    hotkey_id_down = obs.obs_hotkey_register_frontend("volume_decrease", "Decrease Volume", on_decrease_pressed)
    hotkey_id_reset = obs.obs_hotkey_register_frontend("volume_reset", "Reset Volume to 0 dB", on_reset_pressed)

    local hotkey_up_save_array = obs.obs_data_get_array(settings, "volume_increase")
    obs.obs_hotkey_load(hotkey_id_up, hotkey_up_save_array)
    obs.obs_data_array_release(hotkey_up_save_array)

    local hotkey_down_save_array = obs.obs_data_get_array(settings, "volume_decrease")
    obs.obs_hotkey_load(hotkey_id_down, hotkey_down_save_array)
    obs.obs_data_array_release(hotkey_down_save_array)

    local hotkey_reset_save_array = obs.obs_data_get_array(settings, "volume_reset")
    obs.obs_hotkey_load(hotkey_id_reset, hotkey_reset_save_array)
    obs.obs_data_array_release(hotkey_reset_save_array)
end

function script_save(settings)
    local hotkey_up_save_array = obs.obs_hotkey_save(hotkey_id_up)
    obs.obs_data_set_array(settings, "volume_increase", hotkey_up_save_array)
    obs.obs_data_array_release(hotkey_up_save_array)

    local hotkey_down_save_array = obs.obs_hotkey_save(hotkey_id_down)
    obs.obs_data_set_array(settings, "volume_decrease", hotkey_down_save_array)
    obs.obs_data_array_release(hotkey_down_save_array)

    local hotkey_reset_save_array = obs.obs_hotkey_save(hotkey_id_reset)
    obs.obs_data_set_array(settings, "volume_reset", hotkey_reset_save_array)
    obs.obs_data_array_release(hotkey_reset_save_array)
end

function change_volume(delta)
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local filter = obs.obs_source_get_filter_by_name(source, filter_name)
        if filter ~= nil then
            local settings = obs.obs_source_get_settings(filter)
            local current_db = obs.obs_data_get_double(settings, "db")
            obs.obs_data_set_double(settings, "db", current_db + delta)
            obs.obs_source_update(filter, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(filter)
        end
        obs.obs_source_release(source)
    end
end

function reset_volume()
    local source = obs.obs_get_source_by_name(source_name)
    if source ~= nil then
        local filter = obs.obs_source_get_filter_by_name(source, filter_name)
        if filter ~= nil then
            local settings = obs.obs_source_get_settings(filter)
            obs.obs_data_set_double(settings, "db", 0.00)
            obs.obs_source_update(filter, settings)
            obs.obs_data_release(settings)
            obs.obs_source_release(filter)
        end
        obs.obs_source_release(source)
    end
end

function on_increase_pressed(pressed)
    if pressed then
        change_volume(step_size)
    end
end

function on_decrease_pressed(pressed)
    if pressed then
        change_volume(-step_size)
    end
end

function on_reset_pressed(pressed)
    if pressed then
        reset_volume()
    end
end
