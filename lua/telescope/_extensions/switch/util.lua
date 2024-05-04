local util = {}

util.build_picker_opts = function(opt)
    local theme_conf = {
        layout_strategy = opt.layout_strategy,
        layout_config = opt.layout_config,
    }
    if opt.preview then
        theme_conf.previewer = require('telescope.previewers').vim_buffer_cat.new({})
    end
    return theme_conf
    -- if opt.theme == 'ivy' then
    --     return require("telescope.themes").get_ivy(theme_conf)
    -- elseif opt.theme == 'cursor' then
    --     return require("telescope.themes").get_cursor(theme_conf)
    -- else
    --     return require("telescope.themes").get_dropdown(theme_conf)
    -- end
end

util.remove_common_parent_path = function(a, b)
    local path_separator = "/"

    -- 将路径分割成段
    local a_segments = {}
    for segment in a:gmatch("[^" .. path_separator .. "]+") do
        table.insert(a_segments, segment)
    end

    local b_segments = {}
    for segment in b:gmatch("[^" .. path_separator .. "]+") do
        table.insert(b_segments, segment)
    end

    local min_length = math.min(#a_segments, #b_segments)
    local i = 1
    while i <= min_length and a_segments[i] == b_segments[i] do
        i = i + 1
    end

    -- 如果 i = 1，表示没有共同父路径，直接返回 b
    if i == 1 then
        return b
    else
        local result_segments = {}
        for j = i, #b_segments do
            table.insert(result_segments, b_segments[j])
        end
        return table.concat(result_segments, path_separator)
    end
end

util.list_files = function(pattern)
    local command = string.format("ls %s", pattern)
    local handle = io.popen(command .. " 2>/dev/null")
    if handle == nil then
        return nil
    end
    local result = {}
    for file in handle:lines() do
        table.insert(result, file)
    end
    handle:close()
    return result
end

util.find_files = function(path)
    local command = string.format("find %s -type f", path)
    local handle = io.popen(command .. " 2>/dev/null")
    if handle == nil then
        return nil
    end
    local result = {}
    for file in handle:lines() do
        table.insert(result, file)
    end
    handle:close()
    return result
end

return util
