-- Extend Page

Partner_API = SMODS.current_mod

Partner_API.Partner = SMODS.Center:extend{
    unlocked = true,
    discovered = false,
    no_quips = false,
    individual_quips = false,
    config = {},
    set = "Partner",
    class_prefix = "pnr",
    required_params = {"key", "atlas", "pos"},
    pre_inject_class = function(self)
        G.P_CENTER_POOLS[self.set] = {}
    end,
    set_card_type_badge = function(self, card, badges)
        badges[#badges+1] = create_badge(localize("k_partner"), G.C.DARK_EDITION, G.C.WHITE)
    end,
    generate_ui = function(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        SMODS.Center.generate_ui(self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
        if self.config.extra.related_card then
            if type(self.config.extra.related_card) == "table" then
                for k, v in pairs(self.config.extra.related_card) do
                    if next(SMODS.find_card(v)) then
                        info_queue[#info_queue+1] = {key = "partner_benefits", set = "Other"}
                        break
                    end
                end
                for k, v in pairs(self.config.extra.related_card) do
                    if next(SMODS.find_card(v)) then
                        local main_end = {{n=G.UIT.C, config={align = "bm"}, nodes={
                            {n=G.UIT.O, config={object = DynaText({string = {"<"..localize{type = "name_text", set = G.P_CENTERS[v].set, key = v}.." "..localize("k_benefit")..">"}, colours = {G.C.DARK_EDITION}, float = true, scale = 0.3})}},
                        }}}
                        desc_nodes[#desc_nodes+1] = main_end
                    end
                end
            else
                if next(SMODS.find_card(self.config.extra.related_card)) then
                    info_queue[#info_queue+1] = {key = "partner_benefits", set = "Other"}
                    local main_end = {{n=G.UIT.C, config={align = "bm"}, nodes={
                        {n=G.UIT.O, config={object = DynaText({string = {"<"..localize{type = "name_text", set = G.P_CENTERS[self.config.extra.related_card].set, key = self.config.extra.related_card}.." "..localize("k_benefit")..">"}, colours = {G.C.DARK_EDITION}, float = true, scale = 0.3})}},
                    }}}
                    desc_nodes[#desc_nodes+1] = main_end
                end
            end
        end
    end
}

-- Collection Page

Partner_API.custom_collection_tabs = function()
    local tally = 0
    for _, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v:is_unlocked() then
            tally = tally + 1
        end
    end
    return {UIBox_button({button = "your_collection_partners", label = {localize("b_partners")}, count = {tally = tally, of = #G.P_CENTER_POOLS["Partner"]}, minw = 5, id = "your_collection_partners"})}
end

G.FUNCS.your_collection_partners = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = create_UIBox_your_collection_partners(),
    }
end

function create_UIBox_your_collection_partners()
    local deck_tables = {}
    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(G.ROOM.T.x, G.ROOM.T.h, 3.6*G.CARD_W, 0.7*G.CARD_H, {card_limit = 4, type = "title", highlight_limit = 0, collection = true})
        table.insert(deck_tables, {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
            {n=G.UIT.O, config={object = G.your_collection[j]}}
        }})
    end
    local partner_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Partner"]/(4*#G.your_collection)) do
        table.insert(partner_options, localize("k_page").." "..tostring(i).."/"..tostring(math.ceil(#G.P_CENTER_POOLS["Partner"]/(4*#G.your_collection))))
    end
    for i = 1, 4 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Partner"][i+(j-1)*4]
            local card = Card(G.your_collection[j].T.x+G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*46/71, G.CARD_H*58/95, nil, center)
            --card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
    local t =  create_UIBox_generic_options({back_func = "your_collection_other_gameobjects", infotip = localize("ml_partner_unique_ability"), contents = {
        {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
        {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = partner_options, w = 4.5, cycle_shoulders = true, opt_callback = "your_collection_partner_page", current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = "wide"}})
        }}
    }})
    return t
end

G.FUNCS.your_collection_partner_page = function(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.your_collection do
        for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    for i = 1, 4 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Partner"][i+(j-1)*4+(4*#G.your_collection*(args.cycle_config.current_option-1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x+G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
            --card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end
    INIT_COLLECTION_CARD_ALERTS()
end

-- UI Page

function Partner_API.Partner:is_unlocked()
    return self.unlocked or Partner_API.config.temporary_unlock_all or G.PROFILES[G.SETTINGS.profile].all_unlocked
end

Partner_API.config_tab = function()
    return {n=G.UIT.ROOT, config = {align = "cm", padding = 0.05, colour = G.C.CLEAR}, nodes={
        create_toggle({label = localize("k_enable_partner"), ref_table = Partner_API.config, ref_value = "enable_partner"}),
	create_toggle({label = localize("k_enable_speech_bubble"), ref_table = Partner_API.config, ref_value = "enable_speech_bubble"}),
        create_toggle({label = localize("k_temporary_unlock_all"), ref_table = Partner_API.config, ref_value = "temporary_unlock_all"}),
    }}
end

local Card_set_sprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
    Card_set_sprites_ref(self, _center, _front)
    if _center and _center.set == "Partner" and not _center:is_unlocked() then
        self.children.center.atlas = G.ASSET_ATLAS["partner_Partner"]
        self.children.center:set_sprite_pos({x = 0, y = 4})
    end
end

local generate_card_ui_ref = generate_card_ui
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
    if _c and _c.set == "Partner" and _c:is_unlocked() and card_type and card_type == "Locked" and (specific_vars and not specific_vars.no_name or not specific_vars) then card_type = "Partner" end
    if _c and _c.set == "Partner" and _c:is_unlocked() and badges then badges.card_type = "Partner" end
    return generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
end

local Card_update_ref = Card.update
function Card:update(dt)
    Card_update_ref(self, dt)
    if self.ability.set == "Partner" and not self.states.drag.is then
        if self.T.x+self.T.w > G.ROOM.T.w then
            self.T.x = G.ROOM.T.w-self.T.w
        elseif self.T.x < 0 then
            self.T.x = 0
        end
        if self.T.y+self.T.h > G.ROOM.T.h then
            self.T.y = G.ROOM.T.h-self.T.h
        elseif self.T.y < 0 then
            self.T.y = 0
        end
    end
end

local create_UIBox_card_unlock_ref = create_UIBox_card_unlock
function create_UIBox_card_unlock(card_center)
    local ret = create_UIBox_card_unlock_ref(card_center)
    local title = ret.nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].nodes[1].config
    if card_center.set == "Partner" then
        title.object:remove()
        title.object = DynaText({string = {localize("k_partner")}, colours = {G.C.BLUE}, shadow = true, rotate = true, bump = true, pop_in = 0.3, pop_in_rate = 2, scale = 1.2})
    end
    return ret
end

local create_UIBox_notify_alert_ref = create_UIBox_notify_alert
function create_UIBox_notify_alert(_achievement, _type)
    local ret = create_UIBox_notify_alert_ref(_achievement, _type)
    local title = ret.nodes[1].nodes[1].nodes[2].nodes[1].nodes[1].config
    if _type == "Partner" then
        title.text = localize("k_partner")
    end
    return ret
end

function Card:add_partner_speech_bubble(forced_key)
    if not Partner_API.config.enable_speech_bubble then return end
    if self.children.speech_bubble then self.children.speech_bubble:remove() end
    local align = nil
    if self.T.x+self.T.w/2 > G.ROOM.T.w/2 then align = "cl" end
    self.config.speech_bubble_align = {align = align or "cr", offset = {x=align and -0.1 or 0.1,y=0}, parent = self}
    self.children.speech_bubble = UIBox{
        definition = G.UIDEF.partner_speech_bubble(forced_key),
        config = self.config.speech_bubble_align
    }
    self.children.speech_bubble:set_role{role_type = "Minor", xy_bond = "Strong", r_bond = "Weak", major = self}
    self.children.speech_bubble.states.visible = false
    local hold_time = (G.SETTINGS.GAMESPEED*4) or 4
    G.E_MANAGER:add_event(Event({trigger = "after", delay = hold_time, blockable = false, blocking = false, func = function()
        self:remove_partner_speech_bubble()
    return true end}))
end

function G.UIDEF.partner_speech_bubble(forced_key)
    local text = {}
    localize{type = "quips", key = forced_key or "pq_1", nodes=text}
    local row = {}
    for k, v in ipairs(text) do
        row[#row+1] = {n=G.UIT.R, config={align = "cl"}, nodes=v}
    end
    local t = {n=G.UIT.ROOT, config = {align = "cm", minh = 1, r = 0.3, padding = 0.07, minw = 1, colour = G.C.JOKER_GREY, shadow = true}, nodes={
        {n=G.UIT.C, config={align = "cm", minh = 1, r = 0.2, padding = 0.1, minw = 1, colour = G.C.WHITE}, nodes={
            {n=G.UIT.C, config={align = "cm", minh = 1, r = 0.2, padding = 0.03, minw = 1, colour = G.C.WHITE}, nodes=row}
        }}
    }}
    return t
end

function Card:partner_say_stuff(n, not_first)
    if not Partner_API.config.enable_speech_bubble then return end
    self.talking = true
    if not not_first then 
        G.E_MANAGER:add_event(Event({trigger = "after", delay = 0.1, func = function()
            if self.children.speech_bubble then self.children.speech_bubble.states.visible = true end
            self:partner_say_stuff(n, true)
        return true end}))
    else
        if n <= 0 then self.talking = false; return end
        play_sound("voice"..math.random(1, 11), G.SPEEDFACTOR*(math.random()*0.2+1), 0.5)
        self:juice_up(0.6, 1)
        G.E_MANAGER:add_event(Event({trigger = "after", blockable = false, blocking = false, delay = 0.13, func = function()
            self:partner_say_stuff(n-1, true)
        return true end}))
    end
end

function Card:remove_partner_speech_bubble()
    if self.children.speech_bubble then self.children.speech_bubble:remove(); self.children.speech_bubble = nil end
end

local Card_draw_ref = Card.draw
function Card:draw(layer)
    Card_draw_ref(self, layer)
    if self.children.speech_bubble then
        self.children.speech_bubble:draw()
    end
end

local Card_move_ref = Card.move
function Card:move(dt)
    Card_move_ref(self, dt)
    if self.children.speech_bubble then
        local align = nil
        if self.T.x+self.T.w/2 > G.ROOM.T.w/2 then align = "cl" end
        self.children.speech_bubble:set_alignment({type = align or "cr", offset = {x=align and -0.1 or 0.1,y=0}, parent = self})
    end
end

-- New Run Page

G.FUNCS.run_setup_partners_option = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = create_UIBox_partners_option(),
        config = {no_esc = true}
    }
end

function create_UIBox_partners_option()
    G.GAME.viewed_partner = G.P_CENTER_POOLS["Partner"][G.PROFILES[G.SETTINGS.profile].MEMORY.partner] or G.P_CENTER_POOLS["Partner"][1]
    local partner_selection, partner_selection_cycle = create_partner_selection()
    G.partner_area = CardArea(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W*46/71, G.CARD_H*58/95, {card_limit = 2, type = "title", highlight_limit = 0})
    local center = G.GAME.viewed_partner
    local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
    local minw = 3
    local UI_table = G.GAME.viewed_partner:is_unlocked() and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
    local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = minw, minh = 2, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, minw-0.2)}}
    --card.sticker = get_joker_win_sticker(center)
    card.states.hover.can = false
    G.partner_area:emplace(card)
    local t = create_UIBox_generic_options({no_back = true, contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.15, r = 0.1, colour = G.C.L_BLACK}, nodes={
            {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={
                partner_selection,
                partner_selection_cycle
            }},
            {n=G.UIT.C, config={align = "tm", minw = 3, minh = 1, r = 0.1, colour = G.C.BLACK, padding = 0.15, emboss = 0.05}, nodes={
                {n=G.UIT.R, config={align = "cm", emboss = 0.1, r = 0.1, minw = 2, minh = 0.5}, nodes={
                    {n=G.UIT.O, config={id = nil, func = "RUN_SETUP_check_partner_name", object = Moveable()}},
                }},
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                    {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner_card", object = G.partner_area}},
                }},
                {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, emboss = 0.1, r = 0.1}, nodes={
                    {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner", object = UIBox{definition = partner_main, config = {offset = {x=0,y=0}}}}}
                }}
            }},
        }},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {n=G.UIT.C, config={minw = 2.72, minh = 0.8, r = 0.1, hover = true, button = "skip_partner", colour = G.C.FILTER, align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_skip"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.2}, nodes={}},
            {n=G.UIT.C, config={minw = 2.72, minh = 0.8, r = 0.1, hover = true, button = "random_partner", colour = G.C.BLUE, align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_random"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
            {n=G.UIT.C, config={align = "cm", minw = 0.2}, nodes={}},
            {n=G.UIT.C, config={minw = 3.33, minh = 0.8, r = 0.1, hover = true, button = "select_partner", func = "select_partner_button", align = "cm", emboss = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.T, config={text = localize("b_partner_agree"), scale = 0.5, colour = G.C.WHITE}}
                }},
            }},
        }},
    }})
    return t
end

function create_partner_selection()
    local partner_tables = {}
    G.partner_selection = {}
    for i = 1, 2 do
        local row = {n=G.UIT.R, config={colour = G.C.LIGHT}, nodes={}}
        for j = 1, 4 do
            G.partner_selection[j+(i-1)*4] = CardArea(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W*46/71, G.CARD_H*58/95, {card_limit = 2, type = "title", highlight_limit = 0})
            table.insert(row.nodes, {n=G.UIT.O, config={object = G.partner_selection[j+(i-1)*4]}})
        end
        table.insert(partner_tables, row)
    end
    local partner_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS["Partner"]/(#G.partner_selection)) do
        table.insert(partner_options, localize("k_page").." "..tostring(i).."/"..tostring(math.ceil(#G.P_CENTER_POOLS["Partner"]/(#G.partner_selection))))
    end
    local viewed_partner = 1
    for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v.name == G.GAME.viewed_partner.name then
            viewed_partner = math.ceil(k/(#G.partner_selection))
            break
        end
    end
    for i = 1, #G.partner_selection do
        local center = G.P_CENTER_POOLS["Partner"][i+(#G.partner_selection*(viewed_partner-1))]
        if not center then break end
        local card = Card(G.partner_selection[i].T.x+G.partner_selection[i].T.w/2-G.CARD_W*23/71, G.partner_selection[i].T.y+G.partner_selection[i].T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, empty, center)
        card.no_ui = true; card.config.card.no_ui = true
        G.partner_selection[i]:emplace(card)
    end
    local t, tt = {n=G.UIT.R, config={align = "cm", r = 0.1, minh = 3.6, colour = G.C.BLACK, emboss = 0.05}, nodes=partner_tables},
    {n=G.UIT.R, config={align = "cm"}, nodes={
        create_option_cycle({options = partner_options, w = 2.5, cycle_shoulders = true, opt_callback = "your_selection_partner_page", current_option = viewed_partner, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = "wide"}})
    }}
    return t, tt
end

G.FUNCS.your_selection_partner_page = function(args)
    if not args or not args.cycle_config then return end
    for j = 1, #G.partner_selection do
        for i = #G.partner_selection[j].cards, 1, -1 do
            local c = G.partner_selection[j]:remove_card(G.partner_selection[j].cards[i])
            c:remove()
            c = nil
        end
    end
    for j = 1, #G.partner_selection do
        local center = G.P_CENTER_POOLS["Partner"][j+(#G.partner_selection*(args.cycle_config.current_option-1))]
        if not center then break end
        local card = Card(G.partner_selection[j].T.x+G.partner_selection[j].T.w/2-G.CARD_W*23/71, G.partner_selection[j].T.y+G.partner_selection[j].T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
        card.no_ui = true; card.config.card.no_ui = true
        G.partner_selection[j]:emplace(card)
    end
end

G.FUNCS.RUN_SETUP_check_partner_card = function(e)
    if e.config.object and G.GAME.viewed_partner.name ~= e.config.id then
        local c = G.partner_area:remove_card(G.partner_area.cards[1])
        c:remove()
        c = nil
        local center = G.GAME.viewed_partner
        local card = Card(G.partner_area.T.x+G.partner_area.T.w/2-G.CARD_W*23/71, G.partner_area.T.y+G.partner_area.T.h/2-G.CARD_H*29/95, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
        card.states.hover.can = false
        G.partner_area:emplace(card)
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.RUN_SETUP_check_partner_name = function(e)
    if e.config.object and G.GAME.viewed_partner.name ~= e.config.id then
        local partner_name = G.GAME.viewed_partner:is_unlocked() and localize{type = "name_text", set = "Partner", key = G.GAME.viewed_partner.key} or localize("k_locked")
        e.config.object:remove()
        e.config.object = UIBox{
            definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={
                {n=G.UIT.O, config={id = G.GAME.viewed_partner.name, func = "RUN_SETUP_check_partner_name", object = DynaText({string = partner_name, maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}},
            }},
            config = {offset = {x=0,y=0}, align = "cm", parent = e}
        }
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.RUN_SETUP_check_partner = function(e)
    if G.GAME.viewed_partner.name ~= e.config.id then
	local minw = 3
        local UI_table = G.GAME.viewed_partner:is_unlocked() and generate_card_ui(G.GAME.viewed_partner, nil, nil, "Partner") or generate_card_ui(G.GAME.viewed_partner, nil, nil, "Locked")
        local partner_main = {n=G.UIT.ROOT, config={align = "cm", minw = minw, minh = 2, id = G.GAME.viewed_partner.name, colour = G.C.CLEAR}, nodes={desc_from_rows(UI_table.main, true, minw-0.2)}}
        e.config.object:remove() 
        e.config.object = UIBox{
            definition = partner_main,
            config = {offset = {x=0,y=0}, align = "cm", parent = e}
        }
        e.config.id = G.GAME.viewed_partner.name
    end
end

G.FUNCS.skip_partner = function()
    G.FUNCS.exit_overlay_menu()
    G.GAME.skip_partner = true
end

G.FUNCS.random_partner = function()
    local center = pseudorandom_element(G.P_CENTER_POOLS["Partner"], pseudoseed(os.time()))
    G.GAME.viewed_partner = center
    for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
        if v == G.GAME.viewed_partner then
            G.PROFILES[G.SETTINGS.profile].MEMORY.partner = k
        end
    end
end

G.FUNCS.select_partner_button = function(e)
    if G.GAME.viewed_partner and G.GAME.viewed_partner:is_unlocked() then
        e.config.colour = G.C.GREEN
        e.config.button = "select_partner"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.select_partner = function()
    G.FUNCS.exit_overlay_menu()
    G.E_MANAGER:add_event(Event({func = function()
        G.GAME.selected_partner = G.GAME.viewed_partner.key
        G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*1.6, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, G.GAME.viewed_partner)
        G.GAME.selected_partner_card:juice_up(0.3, 0.5)
    return true end}))
end

local run_setup_option_ref = G.UIDEF.run_setup_option
function G.UIDEF.run_setup_option(type)
    local t = run_setup_option_ref(type)
    if type == "New Run" then
        t.nodes[#t.nodes].nodes[#t.nodes[#t.nodes].nodes] = {n=G.UIT.C, config={align = "cm", minw = 2.4}, nodes={
            type == "New Run" and create_toggle{col = true, label = localize("k_partner"), label_scale = 0.28, w = 0, scale = 0.7, ref_table = Partner_API.config, ref_value = "enable_partner"} or nil
        }}
    end
    return t
end

-- Galdur Compat
local run_setup_option_new_model_ref = G.UIDEF.run_setup_option_new_model
function G.UIDEF.run_setup_option_new_model(type)
    local t = run_setup_option_new_model_ref(type)
    t.nodes[#t.nodes].nodes[2].nodes[#t.nodes[#t.nodes].nodes[2].nodes+1] = {n=G.UIT.C, config={align = "cm", minw = 2.4}, nodes={
        type == "New Run" and create_toggle{col = true, label = localize("k_partner"), label_scale = 0.28, w = 0, scale = 0.7, ref_table = Partner_API.config, ref_value = "enable_partner"} or nil
    }}
	return t
end

local Game_start_run_ref = Game.start_run
function Game:start_run(args)
    Game_start_run_ref(self, args)
    if not G.GAME.selected_partner and not G.GAME.skip_partner and Partner_API.config.enable_partner then
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.run_setup_partners_option()
        return true end}))
    elseif G.GAME.selected_partner then
        G.E_MANAGER:add_event(Event({func = function()
            local center = nil
            for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
                if v.key == G.GAME.selected_partner then center = v end
            end
            G.GAME.selected_partner_card = Card(G.deck.T.x+G.deck.T.w-G.CARD_W*0.6, G.deck.T.y-G.CARD_H*1.6, G.CARD_W*46/71, G.CARD_H*58/95, G.P_CARDS.empty, center)
            G.GAME.selected_partner_card:juice_up(0.3, 0.5)
            if G.GAME.selected_partner_table then
                for k, v in pairs(G.GAME.selected_partner_table) do
                    G.GAME.selected_partner_card.ability.extra[k] = v
                end
                G.GAME.selected_partner_table = nil
            end
        return true end}))
    end
end

-- Controller Page

local Controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    Controller_queue_R_cursor_press_ref(self, x, y)
    if self.locks.frame then return end
    self.partner_R_cursor_queue = {x = x, y = y}
end

local Controller_update_ref = Controller.update
function Controller:update(dt)
    Controller_update_ref(self, dt)
    if self.partner_R_cursor_queue then 
        self:partner_R_cursor_press(self.partner_R_cursor_queue.x, self.partner_R_cursor_queue.y)
        self.partner_R_cursor_queue = nil
    end
    if not self.cursor_up.partner_R_handled then
        if self.cursor_down.partner_R_target then 
            if (not self.cursor_down.partner_R_target.click_timeout or self.cursor_down.partner_R_target.click_timeout*G.SPEEDFACTOR > self.cursor_up.partner_R_time - self.cursor_down.partner_R_time) then
                if Vector_Dist(self.cursor_down.partner_R_T, self.cursor_up.partner_R_T) < G.MIN_CLICK_DIST then 
                    if self.cursor_down.partner_R_target.states.click.can then
                        self.clicked.partner_R_target = self.cursor_down.partner_R_target
                        self.clicked.partner_R_handled = false
                    end
                end
            end
        end
        self.cursor_up.partner_R_handled = true
    end
    if not self.clicked.partner_R_handled then
        if self.clicked.partner_R_target then
            self.clicked.partner_R_target:partner_R_click()
            self.clicked.partner_R_handled = true
        end
    end
end

function Controller:partner_R_cursor_press(x, y)
    if ((self.locked) and (not G.SETTINGS.paused or G.screenwipe)) or (self.locks.frame) then return end
    local x = x or self.cursor_position.x
    local y = y or self.cursor_position.y
    self.cursor_down.partner_R_T = {x = x/(G.TILESCALE*G.TILESIZE), y = y/(G.TILESCALE*G.TILESIZE)}
    self.cursor_down.partner_R_time = G.TIMERS.TOTAL
    self.cursor_down.partner_R_target = nil
    local press_node = (self.HID.touch and self.cursor_hover.target) or self.hovering.target or self.focused.target
    if press_node then 
        self.cursor_down.partner_R_target = press_node.states.click.can and press_node or press_node:can_drag() or nil
    end
    if self.cursor_down.partner_R_target == nil then
        self.cursor_down.partner_R_target = G.ROOM
    end
end

local love_mousereleased_ref = love.mousereleased
function love.mousereleased(x, y, button)
    love_mousereleased_ref(x, y, button)
    if button == 2 then G.CONTROLLER:partner_R_cursor_release(x, y) end
end

local Controller_button_release_update_ref = Controller.button_release_update
function Controller:button_release_update(button, dt)
    Controller_button_release_update_ref(self, button, dt)
    if not self.held_button_times[button] then return end
    if button == "b" then
        self:partner_R_cursor_release()
    end
end

function Controller:partner_R_cursor_release(x, y)
    if ((self.locked) and (not G.SETTINGS.paused or G.screenwipe)) or (self.locks.frame) then return end
    local x = x or self.cursor_position.x
    local y = y or self.cursor_position.y
    self.cursor_up.partner_R_T = {x = x/(G.TILESCALE*G.TILESIZE), y = y/(G.TILESCALE*G.TILESIZE)}
    self.cursor_up.partner_R_time = G.TIMERS.TOTAL
    self.cursor_up.partner_R_handled = false
end

function Node:partner_R_click() end

-- Hook Page

local save_run_ref = save_run
function save_run()
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card.ability then
        G.GAME.selected_partner_table = G.GAME.selected_partner_table or {}
        for k, v in pairs(G.GAME.selected_partner_card.ability.extra) do
            G.GAME.selected_partner_table[k] = v
        end
    end
    save_run_ref()
end

local Card_click_ref = Card.click
function Card:click()
    Card_click_ref(self)
    if self.ability.set == "Partner" and self.area and self.area.config.type == "title" then
        G.GAME.viewed_partner = self.config.center
        for k, v in pairs(G.P_CENTER_POOLS["Partner"]) do
            if v == G.GAME.viewed_partner then
                G.PROFILES[G.SETTINGS.profile].MEMORY.partner = k
            end
        end
    end
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card == self then
        if self.children.speech_bubble then
            self:remove_partner_speech_bubble()
        elseif not G.GAME.partner_click_deal then
            G.GAME.partner_click_deal = true
            local ret = G.GAME.selected_partner_card:calculate_partner({partner_click = true})
            if ret then
                SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
            end
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_click_deal = nil
            return true end}))
        end
    end
end

function Card:partner_R_click()
    if G.GAME.selected_partner_card and G.GAME.selected_partner_card == self then
        if not G.GAME.partner_R_click_deal then
	    G.GAME.partner_R_click_deal = true
            local ret = G.GAME.selected_partner_card:calculate_partner({partner_R_click = true})
            if ret then
                SMODS.trigger_effects({{individual = ret}}, G.GAME.selected_partner_card)
            end
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_R_click_deal = nil
            return true end}))
        end
    end
end

-- Talisman Compat
to_big = to_big or function(a)
    return a
end

to_number = to_number or function(a)
    return a
end

function Card:calculate_partner(context)
    if not context then return end
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate and type(obj.calculate) == "function" then
        local ret = obj:calculate(self, context)
        self:general_partner_speech(context)
        if ret then return ret end
    end
end

function Card:general_partner_speech(context)
    if not context or self.config.center.no_quips then return end
    if context.partner_setting_blind and G.GAME.round == 1 then
        if self.config.center.individual_quips then
            G.E_MANAGER:add_event(Event({func = function()
                local max_quips = 0
                for k, v in pairs(G.localization.misc.quips) do
                    if string.find(k, self.config.center.key) then
                        max_quips = max_quips + 1
                    end
                end
                self:add_partner_speech_bubble(self.config.center.key.."_"..math.random(1, max_quips))
                self:partner_say_stuff(5)
            return true end}))
        else
            G.E_MANAGER:add_event(Event({func = function()
                self:add_partner_speech_bubble("pnr_"..math.random(1,6))
                self:partner_say_stuff(5)
            return true end}))
        end
    end
    if context.partner_setting_blind and context.blind.boss and G.GAME.round_resets.ante == G.GAME.win_ante then
        if self.config.center.individual_quips then
            G.E_MANAGER:add_event(Event({func = function()
                local max_quips = 0
                for k, v in pairs(G.localization.misc.quips) do
                    if string.find(k, self.config.center.key) then
                        max_quips = max_quips + 1
                    end
                end
                self:add_partner_speech_bubble(self.config.center.key.."_"..math.random(1, max_quips))
                self:partner_say_stuff(5)
            return true end}))
        else
            G.E_MANAGER:add_event(Event({func = function()
                self:add_partner_speech_bubble("dq_1")
                self:partner_say_stuff(5)
            return true end}))
        end
    end
end

function Card:calculate_partner_cash()
    local obj = self.config.center
    if self.ability.set == "Partner" and obj.calculate_cash and type(obj.calculate_cash) == "function" then
        local ret = obj:calculate_cash(self)
        if ret then return ret end
    end
end

local SMODS_calculate_repetitions_ref = SMODS.calculate_repetitions
SMODS.calculate_repetitions = function(card, context, reps)
    local reps = SMODS_calculate_repetitions_ref(card, context, reps)
    if G.GAME.selected_partner_card then
        local ret = G.GAME.selected_partner_card:calculate_partner(context)
        if ret then
            SMODS.insert_repetitions(reps, ret, card)
        end
    end
    return reps
end

local SMODS_calculate_card_areas_ref = SMODS.calculate_card_areas
function SMODS.calculate_card_areas(_type, context, return_table, args)
    local flags = SMODS_calculate_card_areas_ref(_type, context, return_table, args)
    if G.GAME.selected_partner_card then
        if _type == "individual" and args and args.main_scoring then
            local ret = G.GAME.selected_partner_card:calculate_partner(context)
            if ret then
                return_table[#return_table+1] = {individual = ret}
            end
        end
    end
    return flags
end

-- Localization Page

function Partner_API.process_loc_text()
    G.localization.descriptions.Partner = G.localization.descriptions.Partner or {}
end

-- Atlas Page

SMODS.Atlas{
    key = "modicon",   
    px = 34,
    py = 34,
    path = "icon.png"
}

SMODS.Atlas{
    key = "Partner",
    px = 46,
    py = 58,
    path = "Partners.png"
}

-- Register Page

Partner_API.Partner{
    key = "joker",
    name = "Joker Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_joker", chips = 0, chip_mod = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_joker")) then benefits = 2 end
        return { vars = {card.ability.extra.chips, card.ability.extra.chip_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_main and card.ability.extra.chips >= 1 then
            return {
                message = localize{type = "variable", key = "a_chips", vars = {card.ability.extra.chips}},
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
        if context.partner_before then
            local benefits = 1
            if next(SMODS.find_card("j_joker")) then benefits = 2 end
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.CHIPS})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_joker" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "mime",
    name = "Mime Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 0},
    loc_txt = {},
    atlas = "Partner",
    individual_quips = true,
    config = {extra = {related_card = "j_mime", repetitions = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_mime")) then benefits = 2 end
        return { vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card and G.hand.cards[1] and context.other_card == G.hand.cards[1] and next(context.card_effects[1]) then
            local benefits = 1
            if next(SMODS.find_card("j_mime")) then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_mime" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "raised_fist",
    name = "Fist Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_raised_fist", mult = 1, mult_mod = 0.5}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.other_card and G.hand.cards[1] and context.poker_hands and next(context.poker_hands["Pair"]) then
            local min_id = 15
            local raised_card = nil
            for i = 1, #G.hand.cards do
                if min_id >= G.hand.cards[i].base.id and not SMODS.has_no_rank(G.hand.cards[i]) then
                    min_id = G.hand.cards[i].base.id
                    raised_card = G.hand.cards[i]
                end
            end
            if context.other_card == raised_card then
                if context.other_card.debuff then
                    return {
                        message = localize("k_debuffed"),
                        colour = G.C.RED,
                        card = card,
                    }
                else
                    return {
                        mult = card.ability.extra.mult,
                        card = card
                    }
                end
            end
        end
        if context.partner_before and context.poker_hands and next(context.poker_hands["Pair"]) then
            local benefits = 1
            if next(SMODS.find_card("j_raised_fist")) then benefits = 2 end
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MULT})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_raised_fist" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "egg",
    name = "Egg Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 0},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_egg", sell_cost_mod = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_egg")) then benefits = 2 end
        return { vars = {card.ability.extra.sell_cost_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_end_of_round then
            local benefits = 1
            if next(SMODS.find_card("j_egg")) then benefits = 2 end
            for k, v in ipairs(G.jokers.cards) do
                v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.sell_cost_mod*benefits
                v:set_cost()
            end
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_val_up"), colour = G.C.MONEY})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_egg" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "burglar",
    name = "Burglar Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_burglar", hands_played_mod = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_burglar")) then benefits = 2 end
        return { vars = {card.ability.extra.hands_played_mod*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_setting_blind and context.blind.boss then
            local benefits = 1
            if next(SMODS.find_card("j_burglar")) then benefits = 2 end
            G.E_MANAGER:add_event(Event({func = function()
                ease_hands_played(card.ability.extra.hands_played_mod*benefits)
                card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "variable", key = "a_hands", vars = {card.ability.extra.hands_played_mod*benefits}}})
            return true end}))
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_burglar" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "faceless",
    name = "Faceless Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_faceless", discard_dollars = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_faceless")) then benefits = 2 end
        return { vars = {card.ability.extra.discard_dollars*benefits} }
    end,
    calculate = function(self, card, context)
        if context.partner_discard and context.other_card and context.other_card:is_face() then
            local benefits = 1
            if next(SMODS.find_card("j_faceless")) then benefits = 2 end
            ease_dollars(card.ability.extra.discard_dollars*benefits)
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("$")..card.ability.extra.discard_dollars*benefits, colour = G.C.MONEY})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_faceless" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "hallucination",
    name = "Hallucination Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_hallucination"}},
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.partner_open_booster then
            G.E_MANAGER:add_event(Event({func = function()
                --thats too unbalanced
                --local _planet = nil
                --for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                    --if v.config.hand_type == G.GAME.last_hand_played then
                        --_planet = v.key
                    --end
                --end
                local _card = create_card("Joker", G.pack_cards, nil, nil, nil, nil, nil, "hal_pnr")
                _card:add_to_deck()
                G.pack_cards:emplace(_card)
                if next(SMODS.find_card("j_hallucination")) then G.GAME.pack_choices = G.GAME.pack_choices + 1 end
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_plus_joker"), colour = G.C.GREEN})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_hallucination" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "fortune_teller",
    name = "Fortune Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 1},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_fortune_teller", round = 3, rounds = 3}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.p_arcana_normal_1
        return { vars = {card.ability.extra.rounds, card.ability.extra.round} }
    end,
    calculate = function(self, card, context)
        if context.partner_setting_blind then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds <= 0 then
                card.ability.extra.rounds = 0
            end
        end
        if context.partner_starting_shop and card.ability.extra.rounds <= 0 then
            card.ability.extra.rounds = card.ability.extra.round
            G.E_MANAGER:add_event(Event({func = function()
                local key = "p_arcana_normal_"..(math.random(1, 4))
                if next(SMODS.find_card("j_fortune_teller")) then key = "p_arcana_mega_"..(math.random(1, 2)) end
                local _card = Card(G.shop_booster.T.x+G.shop_booster.T.w/2, G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                create_shop_card_ui(_card, "Booster", G.shop_booster)
                _card:start_materialize()
                G.shop_booster:emplace(_card)
                if next(SMODS.find_card("j_fortune_teller")) then _card.ability.couponed = true; _card:set_cost() end
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_booster"), colour = G.C.PURPLE})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_fortune_teller" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "golden",
    name = "Golden Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_golden", dollars = 2, dollars_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.dollars} }
    end,
    calculate = function(self, card, context)
        if context.partner_skip_blind then
            local benefits = 1
            if next(SMODS.find_card("j_golden")) then benefits = 2 end
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollars_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MONEY})
        end
    end,
    calculate_cash = function(self, card)
        return card.ability.extra.dollars
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_golden" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "baseball",
    name = "Baseball Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_baseball", mult = 3, mult_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult} }
    end,
    calculate = function(self, card, context)
        if context.partner_other_main and context.other_card then
            if context.other_card.ability.set == "Joker" and context.other_card.config.center.rarity == 2 then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
        if context.partner_skipping_booster then
            local benefits = 1
            if next(SMODS.find_card("j_baseball")) then benefits = 2 end
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_mod*benefits
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex"), colour = G.C.MULT})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_baseball" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "trading",
    name = "Trading Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_trading", discard_dollars = 2}},
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.discard_dollars} }
    end,
    calculate = function(self, card, context)
        local benefits = 1
        if next(SMODS.find_card("j_trading")) then benefits = 5 end
        if context.partner_discard and G.GAME.current_round.discards_left <= 1 and #context.full_hand <= 1*benefits then
            if context.other_card == context.full_hand[#context.full_hand] then
                ease_dollars(-card.ability.extra.discard_dollars*#context.full_hand)
                card_eval_status_text(card, "dollars", -card.ability.extra.discard_dollars*#context.full_hand)
            end
            return { remove = true }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_trading" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "flash",
    name = "Flash Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 2},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_flash", first_reroll = false}},
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_negative
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.partner_reroll_shop and not card.ability.extra.first_reroll then
            for i = 1, #G.shop_jokers.cards do
                if not G.shop_jokers.cards[i].edition and G.shop_jokers.cards[i].ability.set == "Joker" then
                    card.ability.extra.first_reroll = true
                    card_eval_status_text(card, "extra", nil, nil, nil, {message = localize{type = "name_text", key = "e_negative", set = "Edition"}, colour = G.C.DARK_EDITION})
                    G.shop_jokers.cards[i]:set_edition({negative = true}, true)
                    if next(SMODS.find_card("j_flash")) then G.shop_jokers.cards[i].ability.couponed = true; G.shop_jokers.cards[i]:set_cost() end
                    break
                end
            end
        end
        if context.partner_ending_shop and card.ability.extra.first_reroll then
            card.ability.extra.first_reroll = false
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_flash" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "throwback",
    name = "Throwback Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 0, y = 3},
    loc_txt = {},
    atlas = "Partner",
    individual_quips = true,
    config = {extra = {related_card = "j_throwback", xmult = 1, xmult_mod = 0.5, cost = 2}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_throwback")) then benefits = 2 end
        return { vars = {card.ability.extra.xmult, card.ability.extra.xmult_mod*benefits, card.ability.extra.cost} }
    end,
    calculate = function(self, card, context)
        if context.partner_main and card.ability.extra.xmult > 1 then
            return {
                message = localize{type = "variable", key = "a_xmult", vars = {card.ability.extra.xmult}},
                Xmult_mod = card.ability.extra.xmult,
            }
        end
        if context.partner_after and card.ability.extra.xmult > 1 then
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.extra.xmult = 1
            return true end}))
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_reset"), colour = G.C.RED})
        end
        if context.partner_click and ((to_big(G.GAME.dollars) - to_big(G.GAME.bankrupt_at)) >= to_big(card.ability.extra.cost)) then
            G.GAME.partner_click_deal = true
            local benefits = 1
            if next(SMODS.find_card("j_throwback")) then benefits = 2 end
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_mod*benefits
            ease_dollars(-card.ability.extra.cost)
            card_eval_status_text(card, "dollars", -card.ability.extra.cost)
            G.E_MANAGER:add_event(Event({func = function()
                G.GAME.partner_click_deal = nil
            return true end}))
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_throwback" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "hanging_chad",
    name = "Chad Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 1, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_hanging_chad", repetitions = 1}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_hanging_chad")) then benefits = 2 end
        return { vars = {card.ability.extra.repetitions*benefits} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.other_card and context.scoring_hand and context.other_card == context.scoring_hand[1] then
            local benefits = 1
            if next(SMODS.find_card("j_hanging_chad")) then benefits = 2 end
            return {
                message = localize("k_again_ex"),
                repetitions = card.ability.extra.repetitions*benefits,
                card = card
            }
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_hanging_chad" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "bloodstone",
    name = "Blood Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 2, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_bloodstone", xmult = 1.5}},
    loc_vars = function(self, info_queue, card)
        local benefits = 1
        if next(SMODS.find_card("j_bloodstone")) then benefits = 2 end
        return { vars = {card.ability.extra.xmult*benefits} }
    end,
    calculate = function(self, card, context)
        if context.individual and context.other_card and context.scoring_hand then
            local first_heart = nil
            for i = 1, #context.scoring_hand do
                if context.scoring_hand[i]:is_suit("Hearts") then
                    first_heart = context.scoring_hand[i]
                    break
                end
            end
            if context.other_card == first_heart then
                local benefits = 1
                if next(SMODS.find_card("j_bloodstone")) then benefits = 2 end
                return {
                    x_mult = card.ability.extra.xmult*benefits,
                    colour = G.C.RED,
                    card = card
                }
            end
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_bloodstone" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}

Partner_API.Partner{
    key = "burnt",
    name = "Burnt Partner",
    unlocked = false,
    discovered = true,
    pos = {x = 3, y = 3},
    loc_txt = {},
    atlas = "Partner",
    config = {extra = {related_card = "j_burnt", odd = 4, upgrade_mod = 1}},
    loc_vars = function(self, info_queue, card)
        return { vars = {""..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odd} }
    end,
    calculate = function(self, card, context)
        if context.partner_pre_discard and pseudorandom("burnt_pnr") < G.GAME.probabilities.normal/card.ability.extra.odd then
            local benefits = 1
            if next(SMODS.find_card("j_burnt")) then benefits = 2 end
            local text, disp_text = G.FUNCS.get_poker_hand_info(context.full_hand)
            card_eval_status_text(card, "extra", nil, nil, nil, {message = localize("k_upgrade_ex")})
            update_hand_text({sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(text, "poker_hands"), chips = G.GAME.hands[text].chips, mult = G.GAME.hands[text].mult, level = G.GAME.hands[text].level})
            level_up_hand(card, text, nil, card.ability.extra.upgrade_mod*benefits)
            update_hand_text({sound = "button", volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = "", level = ""})
        end
    end,
    check_for_unlock = function(self, args)
        for _, v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if v.key == "j_burnt" then
                if get_joker_win_sticker(v, true) >= 8 then
                    return true
                end
                break
            end
        end
    end,
}
