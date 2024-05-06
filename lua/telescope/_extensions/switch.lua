local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local builtin_matchers = require('telescope._extensions.switch.matcher')
local builtin_util = require('telescope._extensions.switch.util')

local global_config = {
    matchers = {
        builtin_matchers.go_impl,
        builtin_matchers.go_test,
    },
    picker = {
        seperator = "⇒",
        layout_strategy = 'horizontal',
        layout_config = {
            width = 0.5,
            height = 0.4,
            preview_width = 0.6,
        },
        preview = true,
    }
}

local find_switch_files = function(file_abs)
    local switch_files = {}
    for _, matcher in ipairs(global_config.matchers) do
        local from = matcher.from
        local to = matcher.to
        local search = matcher.search
        local files = nil
        if search == nil then -- use match
            local switch_file, ok = file_abs:gsub(from, to)
            if ok == 1 then
                files = builtin_util.list_files(switch_file)
                if not files or #files == 0 then
                    files = { switch_file }
                end
            end
        elseif file_abs:match(from) then -- use search
            local search_path = vim.fn.getcwd() .. search
            files = builtin_util.find_files(search_path)
        end
        if files then
            for _, file in ipairs(files) do
                table.insert(switch_files, {
                    file_abs = file,
                    alias = builtin_util.remove_common_parent_path(file_abs, file),
                    name = "(" .. matcher.name .. ")",
                })
            end
        end
    end
    return switch_files
end

local main = function(_)
    local file_abs = vim.fn.expand("%:p")

    local switch_files = find_switch_files(file_abs)
    if #switch_files == 0 then
        vim.api.nvim_err_writeln("No switch files found")
        return
    end

    -- fill spaces for name
    local max_name_len = 0
    for _, switch_file in ipairs(switch_files) do
        max_name_len = math.max(max_name_len, #switch_file.name)
    end
    for _, switch_file in ipairs(switch_files) do
        switch_file.name = string.format("%-" .. max_name_len .. "s", switch_file.name)
    end

    local picker_opt = builtin_util.build_picker_opts(global_config.picker)
    pickers.new(picker_opt, {
        prompt_title = "Switch",
        finder = finders.new_table {
            results = switch_files,
            entry_maker = function(entry)
                local result = {
                    display = string.format("%s %s %s", entry.name, global_config.picker.seperator, entry.alias),
                    ordinal = entry.file_abs,
                    path = entry.file_abs,
                }
                if vim.fn.filereadable(entry.file_abs) == 0 then
                    result.display = "+ " .. result.display
                else
                    result.display = "• " .. result.display
                end
                return result
            end,
        },
        sorter = conf.generic_sorter(picker_opt),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                vim.api.nvim_command(string.format(":e %s", selection.ordinal))
            end)
            return true
        end,
    }):find()
end

-- sometimes setup will be called twice(idk why...), so we need to avoid it
local setup_done = 0
return require("telescope").register_extension({
    setup = function(ext_config)
        if setup_done == 1 then
            return
        end
        ext_config = ext_config or {}
        if ext_config.picker then
            global_config.picker = vim.tbl_extend("force", global_config.picker, ext_config.picker)
        end
        for _, matcher in ipairs(ext_config.matchers or {}) do
            local existed = false
            for _, builtin_matcher in ipairs(global_config.matchers) do
                if matcher.from == builtin_matcher.from and
                    matcher.to == builtin_matcher.to and
                    matcher.search == builtin_matcher.search then
                    existed = true
                    break
                end
            end
            if not existed then
                table.insert(global_config.matchers, matcher)
            end
        end
        setup_done = 1
    end,
    exports = {
        switch = main
    },
})
