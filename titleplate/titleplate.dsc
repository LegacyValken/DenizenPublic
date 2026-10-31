cfg_titles:
    type: data
    debug: false
    settings:
        # If the title system should be enabled.
        enabled: true
        # The default title to give to players.
        default_title: new_player
        # The vertical direction in where the titleplate will appear above the player.
        # Options: TOP, BOTTOM
        position: BOTTOM
        # Enclosing left and right symbols for title
        # Ex: ≪Newbie≫ would be default.
        # You can leave these as <empty> if you don't want them to show up.
        left_sym: ≪
        right_sym: ≫
        # Colors for the enclosing left and right symbols
        left_clr: <&f>
        right_clr: <&f>
        # The permission to look for when using administrator commands.
        admin_permission: dTitle.admin
    titles:
        new_player:
            title: Newbie
            # Material is represented in the menu inventory, defaults to a white banner.
            material: player_head
        server_op:
            title: <&d>Server Operator
            material: bedrock
        special_player:
            title: <&gradient[from=<&6>;to=<&c>]>The Chosen
            material: command_block
        player_killer:
            title: <&c>⚔ <&f><bold>Slayer
            material: iron_sword

cmd_titles:
    type: command
    debug: false
    name: titles
    usage: /titles (<&e>grant <&f>| <&e>revoke<&f>) <&f><&lt><&e>title_id<&f><&gt> (<&e>player_name<&f>)
    description: Manage player titles.
    tab completions:
        1: <list[grant|give|remove|revoke]>
        2: <script[cfg_titles].data_key[titles].keys>
        3: <server.players.parse[name]>
    script:

        - if not <script[cfg_titles].parsed_key[settings.enabled]>:
            - narrate "<&c>The title system is not currently enabled."
            - stop

        - choose <context.args.first.if_null[null]>:
            - case grant give:
                - if <player.exists> and not <player.has_permission[<script[cfg_titles].data_key[settings.admin_permission]>]>:
                    - narrate "<&c>You do not have permission to give titles."
                    - stop
                - if not <context.args.get[2].exists>:
                    - narrate "<&c>You must provide an ID."
                    - stop

                - define id <context.args.get[2]>
                - if <[id]> not in <script[cfg_titles].data_key[titles].keys>:
                    - narrate "<&c>Invalid title ID: <&e><[id]>"
                    - stop

                - if <context.args.get[3].exists>:
                    - define target <context.args.get[3]>
                    - if <[target]> == <empty>:
                        - narrate "<&c>You must put a player name."
                        - stop
                    - if not <server.match_offline_player[<[target]>].exists>:
                        - narrate "<&c>Invalid player: <&e><[target]>"
                        - stop

                    - define target <server.match_offline_player[<[target]>]>
                    - if <[id]> in <[target].flag[titles].if_null[<list>]>:
                        - narrate "<&e><[target].display_name> <&c>already has title: <&f><[id].proc[title_display]>"
                        - stop

                    - run title_grant def.id:<[id]> player:<[target]>
                    - narrate "<&7><italic>You were granted the title of: <&f><[id].proc[title_display]>" targets:<[target]>
                    - narrate "<&7><italic>You gave <&e><[target].display_name><&7><italic> the title of: <&f><[id].proc[title_display]>"
                    - stop

                - if not <player.exists>:
                    - narrate "<&c>Only players can grant themselves titles.<&nl><&7><italic>Did you forget the player argument?"
                    - stop

                - if <[id]> in <player.flag[titles].if_null[<list>]>:
                    - narrate "<&c>You already have the title: <&f><[id].proc[title_display]>"
                    - stop

                - run title_grant def.id:<[id]>
                - narrate "<&7><italic>Granted you the title of: <&f><[id].proc[title_display]>"
            - case remove revoke:
                - if <player.exists> and not <player.has_permission[<script[cfg_titles].data_key[settings.admin_permission]>]>:
                    - narrate "<&c>You do not have permission to remove titles."
                    - stop
                - if not <context.args.get[2].exists>:
                    - narrate "<&c>You must provide an ID."
                    - stop

                - define id <context.args.get[2]>
                - if <[id]> not in <script[cfg_titles].data_key[titles].keys>:
                    - narrate "<&c>Invalid title ID: <&e><[id]>"
                    - stop

                - if <context.args.get[3]>:
                    - define target <context.args.get[3]>
                    - if <[target]> == <empty>:
                        - narrate "<&c>You must put a player name."
                        - stop
                    - if not <server.match_offline_player[<[target]>].exists>:
                        - narrate "<&c>Invalid player: <&e><[target]>"
                        - stop

                    - define target <server.match_offline_player[<[target]>]>
                    - if <[id]> not in <[target].flag[titles].if_null[<list>]>:
                        - narrate "<&c>Player doesn't have the title: <&f><[id].proc[title_display]>"
                        - stop

                    - run title_remove def.id:<[id]> player:<[target]>
                    - narrate "<&7><italic>You were stripped of the title: <&f><[id].proc[title_display]>" targets:<[target]>
                    - narrate "<&7><italic>You stripped <&e><[target].display_name><&7><italic> of the title: <&f><[id].proc[title_display]>"
                    - stop

                - if not <player.exists>:
                    - narrate "<&c>Only players can revoke titles.<&nl><&7><italic>Did you forget the player argument?"
                    - stop

                - if <[id]> not in <player.flag[titles].if_null[<list>]>:
                    - narrate "<&c>You do not have the title: <&f><[id].proc[title_display]>"
                    - stop

                - run title_remove def.id:<[id]>
                - narrate "<&7><italic>Revoked title of: <&f><[id].proc[title_display]>"
            - default:
                - inject titles_events.scripts.menu_open

menu_titles:
    type: inventory
    debug: false
    inventory: chest
    size: 36
    title: Titles
    gui: true

titles_events:
    type: world
    debug: false
    scripts:
        menu_reopen:
            - define page <player.flag[menu.page]> if:<[page].exists.not>
            - flag <player> menu.noclose duration:1t
            - inject <script.name>.scripts.menu_open
        menu_open:
            - define inv_id menu_titles
            - define page 1 if:<[page].exists.not>
            - flag <player> menu.inv:<[inv_id]>
            - flag <player> menu.page:<[page]>
            - define inv <inventory[<[inv_id]>]>
            - define titles <player.flag[titles].if_null[<list>].alphabetical>
            - define titles <script[cfg_titles].data_key[titles].keys> if:<player.has_permission[<script[cfg_titles].data_key[settings.admin_permission]>]>
            - if <[page]> == 1:
                - define no_title <item[barrier]>
                - adjust def:no_title flag:title:REMOVE_CURRENTLY_SELECTED_TITLE
                - adjust def:no_title display:<&c>Disable
                - adjust def:no_title "lore:<&nl><&7><italic>This will turn off the title above your head."
                - define title_items:->:<[no_title]>

            - foreach <[titles]> as:title:
                - define i <item[<script[cfg_titles].data_key[titles.<[title]>.material].if_null[white_banner]>]>
                - adjust def:i flag:title:<[title]>
                - adjust def:i display:<&r><&f><[title].proc[title_display]>
                - if <player.has_flag[title]> and <player.flag[title]> == <[title]>:
                    - adjust def:i "lore:<&nl><&r><&e><bold>This is your currently selected title."
                - adjust def:i hides:ALL
                - define title_items:->:<[i]>

            - define list_size <[title_items].size>
            - define mx_ln 27
            - define mx_pg <[list_size].div[<[mx_ln]>].round_up>
            - define page <[mx_pg]> if:<[page].is_more_than[<[mx_pg]>]>
            - define min_int <[mx_ln].mul[<[page]>].sub[<[mx_ln].sub[1]>]>
            - define max_int <[mx_ln].mul[<[page]>]>
            - if <[max_int]> > <[list_size]>:
                - define max_int <[list_size]>

            - foreach <[title_items].get[<[min_int]>].to[<[max_int]>]> as:t_item:
                - inventory set o:<[t_item]> slot:<[loop_index]> d:<[inv]>
            - foreach <util.list_numbers[from=28;to=36]> as:idx:
                - inventory set o:item_menu_notake slot:<[idx]> d:<[inv]>
            - if <[page]> > 1:
                - inventory set o:<item[item_menu_leftarrow]> slot:28 d:<[inv]>
            - if <[page]> < <[mx_pg]>:
                - inventory set o:<item[item_menu_rightarrow]> slot:36 d:<[inv]>
            - inventory open d:<[inv]>
        cleanup:
            - foreach <server.players_flagged[titleplate]> as:ply:
                - flag <[ply]> titleplate:!
            - if <server.flag[titleplate_cache].any.if_null[false]>:
                - foreach <server.flag[titleplate_cache]> as:plate:
                    - flag SERVER titleplate_cache:<-:<[plate]>
                    - remove <[plate]>
    events:
        on player clicks in menu_titles:
            - stop if:<context.action.equals[NOTHING]>
            - stop if:<context.clicked_inventory.if_null[null_inv].equals[<player.open_inventory>].not>
            - stop if:<context.item.advanced_matches[item_menu_notake]>

            - if not <script[cfg_nameplate].parsed_key[settings.enabled].if_null[false]>:
                - narrate "<&c>The nameplate system is not currently enabled."
                - playsound <player> sound:block.lava.extinguish
                - stop

            - if not <script[cfg_titles].parsed_key[settings.enabled].if_null[false]>:
                - narrate "<&c>The title system is not currently enabled."
                - playsound <player> sound:block.lava.extinguish
                - stop

            - choose <context.item.script.name.if_null[null_script]>:
                - case item_menu_leftarrow:
                    - playsound <player> sound:ui.button.click
                    - define page <player.flag[menu.page].sub[1]>
                    - inject <script.name>.scripts.menu_reopen
                - case item_menu_rightarrow:
                    - playsound <player> sound:ui.button.click
                    - define page <player.flag[menu.page].add[1]>
                    - inject <script.name>.scripts.menu_reopen
                - default:
                    - define id <context.item.flag[title]>
                    - if <[id]> == REMOVE_CURRENTLY_SELECTED_TITLE:
                        - stop if:<player.has_flag[title].not>
                        - flag <player> title:!
                        - run titleplate_remove
                        - narrate "<&7><italic>You have removed your current title."
                        - playsound <player> sound:ui.button.click
                        - inject <script.name>.scripts.menu_reopen
                        - stop

                    - if not <player.has_permission[<script[cfg_titles].data_key[settings.admin_permission]>]> and <[id]> not in <player.flag[titles]>:
                        - narrate "<&c>You don't currently own the title: <&f><[id].proc[title_display]>"
                        - playsound <player> sound:block.lava.extinguish
                        - inject <script.name>.scripts.menu_reopen
                        - stop

                    - if <player.has_flag[title]> and <player.flag[title]> == <[id]>:
                        - narrate "<&c>You already have this title equipped."
                        - playsound <player> sound:block.lava.extinguish
                        - stop

                    - define id <context.item.flag[title]>
                    - flag <player> title:<[id]>
                    - narrate "<&7>Selected title: <&e><[id].proc[title_display]>"
                    - playsound <player> sound:ui.button.click

                    - run titleplate_create if:<player.has_flag[titleplate].not>
                    - run nameplate_update
                    - inject <script.name>.scripts.menu_reopen

        on player closes menu_titles:
            - flag <player> menu:! if:<player.has_flag[menu.noclose].not>

titleplate_entity:
    type: entity
    debug: false
    entity_type: text_display
    mechanisms:
        text: <&sp>
        pivot: center
        see_through: false
        text_shadowed: true
        background_color: TRANSPARENT
        translation: 0,0.6,0

titleplate_create:
    type: task
    debug: false
    script:
        - stop if:<player.is_online.not>
        - if <player.has_flag[titleplate]>:
            - run nameplate_update
            - stop
        - stop if:<player.has_flag[title].not>
        - spawn titleplate_entity <player.eye_location> save:holo
        - define holo <entry[holo].spawned_entity>
        - flag SERVER titleplate_cache:->:<[holo]>
        - adjust <player> hide_entity:<[holo]>
        - mount <[holo]>|<player>
        - flag <player> titleplate:<[holo]>
        - run nameplate_update

titleplate_remove:
    type: task
    debug: false
    script:
        - stop if:<player.has_flag[titleplate].not>
        - flag SERVER titleplate_cache:<-:<player.flag[titleplate]>
        - remove <player.flag[titleplate]>
        - flag <player> titleplate:!
        - run nameplate_update

titleplate_update:
    type: task
    debug: false
    script:
        - stop if:<player.is_online.not>
        - stop if:<player.has_flag[titleplate].not>
        - stop if:<player.flag[titleplate].is_spawned.not>
        - stop if:<script[cfg_nameplate].parsed_key[settings.enabled].if_null[false].not>
        # Sometimes the title may be missing but still spawned.
        - if not <player.has_flag[title]> and <player.has_flag[titleplate]>:
            - run titleplate_remove
            - stop

        - define title_trans 0,0.6,0
        - if <script[cfg_titles].data_key[settings.position]> == bottom:
            - define title_trans 0,0.3,0
        - adjust <player.flag[titleplate]> translation:<[title_trans]>

        - define l_sym <script[cfg_titles].parsed_key[settings.left_sym]>
        - define r_sym <script[cfg_titles].parsed_key[settings.right_sym]>
        - define l_clr <script[cfg_titles].parsed_key[settings.left_clr]>
        - define r_clr <script[cfg_titles].parsed_key[settings.right_clr]>
        - define txt <[l_clr]><[l_sym]><&r><player.flag[title].proc[title_display]><&r><[r_clr]><[r_sym]>

        - define holo <player.flag[titleplate]>
        - if not <[holo].is_spawned>:
            - run titleplate_remove
            - run titleplate_create
            - stop

        - if <player.location.world> != <[holo].location.world> or <[holo].location.distance[<player.location>]> > 2:
            - mount <[holo]> CANCEL
            - mount <[holo]>|<player>

        - define opacity <script[cfg_nameplate].data_key[settings.opacity_default]>
        - define opacity <script[cfg_nameplate].data_key[settings.opacity_sneak]> if:<player.is_sneaking>
        - define opacity <script[cfg_nameplate].data_key[settings.opacity_invisible]> if:<player.has_effect[INVISIBILITY]>
        - adjust <[holo]> opacity:<[opacity]>
        - adjust <[holo]> text:<[txt]>

title_grant:
    type: task
    debug: false
    definitions: id
    script:
        - stop if:<[id].exists.not>
        - stop if:<[id].is_in[<script[cfg_titles].data_key[titles].keys>].not>
        - stop if:<[id].is_in[<player.flag[titles].if_null[<list>]>]>
        - flag <player> titles:->:<[id]>

title_remove:
    type: task
    debug: false
    definitions: id
    script:
        - stop if:<[id].exists.not>
        - stop if:<[id].is_in[<script[cfg_titles].data_key[titles].keys>].not>
        - stop if:<[id].is_in[<player.flag[titles].if_null[<list>]>].not>
        - flag <player> titles:<-:<[id]>
        - if <player.flag[title]> == <[id]>:
            - run titleplate_remove
            - flag <player> title:!

title_display:
    type: procedure
    debug: false
    definitions: id
    script:
        - determine <script[cfg_titles].parsed_key[titles.<[id]>.title].if_null[?UNKNOWN_TITLE?]>