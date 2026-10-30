cfg_nameplate:
    type: data
    settings:
        # If the nameplate system should be enabled
        enabled: true
        # Text to display on the nameplate, uses parsing.
        text: <&e><player.display_name>
        # Visible through blocks
        see_through: false
        # Default transprency
        opacity_default: 255
        # Transprency when sneaking
        opacity_sneak: 145
        # Transparency when invisible through potions
        opacity_invisible: 5

nameplate_entity:
    type: entity
    debug: false
    entity_type: text_display
    mechanisms:
        text: <&sp>
        pivot: center
        see_through: false
        text_shadowed: true
        background_color: TRANSPARENT
        translation: 0,0.3,0

nameplate_events:
    type: world
    debug: false
    scripts:
        cleanup:
            # In the event of a crash or goof, remove the flag.
            - flag <server.players_flagged[nameplate]> nameplate:!
            # Remove stray nameplates.
            - if <server.flag[nameplate_cache].any.if_null[false]>:
                - foreach <server.flag[nameplate_cache]> as:plate:
                    - flag SERVER nameplate_cache:<-:<[plate]>
                    - remove <[plate]>
    events:
        after scripts loaded:
            - define enabled <script[cfg_nameplate].parsed_key[settings.enabled]>
            - foreach <server.online_players> as:__player:
                - if <[enabled]>:
                    - run nameplate_create
                    - team name:nonames add:<player.display_name>
                    - adjust <player.flag[nameplate]> see_through:<script[cfg_nameplate].parsed_key[settings.see_through]>
                - else:
                    - run nameplate_remove
                    - team name:nonames remove:<player.display_name>
            - if !<[enabled]>:
                - run <script.name>.scripts.cleanup
        on delta time secondly:
            - stop if:<script[cfg_nameplate].parsed_key[settings.enabled].not>
            - foreach <server.online_players> as:__player:
                - inject nameplate_update
        on server start:
            - team name:nonames option:name_tag_visibility status:never
            - team name:nonames option:see_invisible status:never
            - flag SERVER nameplate_cache:<list> if:<server.has_flag[nameplate_cache].not>
            - run <script.name>.scripts.cleanup
        after player potion effects modified effect:invisibility:
            - stop if:<script[cfg_nameplate].parsed_key[settings.enabled].not>
            - inject nameplate_update
        on player joins:
            - if !<script[cfg_nameplate].parsed_key[settings.enabled]>:
                - team name:nonames remove:<player.display_name>
                - stop
            - team name:nonames add:<player.display_name>
            - inject nameplate_create
        on player toggles sneaking:
            - define cfg <script[cfg_nameplate].parsed_key[settings]>
            - stop if:<[cfg.enabled].not>
            - define opacity <[cfg.opacity_default]>
            - if <context.state>:
                - define opacity <[cfg.opacity_sneak]>
            - if <player.has_effect[invisibility]>:
                - define opacity <[cfg.opacity_invisible]>
            - adjust <player.flag[nameplate]> opacity:<[opacity]>
        on player quits:
            - stop if:<script[cfg_nameplate].parsed_key[settings.enabled].not>
            - inject nameplate_remove
        # Players forcefully dismount when they touch portals, we're gonna remount them to the player.
        after player enters portal:
            - stop if:<script[cfg_nameplate].parsed_key[settings.enabled].not>
            - inject nameplate_update

nameplate_create:
    type: task
    debug: false
    script:
        - if !<player.is_online> || <player.has_flag[nameplate]>:
            - stop
        - spawn nameplate_entity <player.eye_location> save:holo
        - define holo <entry[holo].spawned_entity>
        - flag SERVER nameplate_cache:->:<[holo]>
        - adjust <player> hide_entity:<[holo]>
        - mount <[holo]>|<player>
        - flag <player> nameplate:<[holo]>
        - define see_through <script[cfg_nameplate].parsed_key[settings.see_through]>
        - adjust <[holo]> see_through:<[see_through]>
        - inject nameplate_update

nameplate_update:
    type: task
    debug: false
    definitions: text
    script:

        - if !<player.is_online> || <player.has_flag[nameplate].not> || !<player.flag[nameplate].is_spawned||true>:
            - stop

        - define cfg <script[cfg_nameplate].parsed_key[settings]>
        - define txt <[cfg.text]>
        - define txt <[text]> if:<[text].exists>

        - define holo <player.flag[nameplate]>
        - if !<[holo].is_spawned>:
            - inject nameplate_remove
            - inject nameplate_create
            - stop
        # Prevent problems with nameplate being in a different world for some reason.
        - if <player.location.world> != <[holo].location.world> or <[holo].location.distance[<player.location>]> > 2:
            - mount <[holo]> CANCEL
            # Mount actually teleports to the player regardless of world.
            - mount <[holo]>|<player>
        - define opacity <[cfg.opacity_default]>
        - define opacity <[cfg.opacity_sneak]> if:<player.is_sneaking>
        - define opacity <[cfg.opacity_invisible]> if:<player.has_effect[INVISIBILITY]>
        - adjust <[holo]> opacity:<[opacity]>
        - adjust <[holo]> text:<[txt]>

nameplate_remove:
    type: task
    debug: false
    script:
        - stop if:<player.has_flag[nameplate].not>
        - flag SERVER nameplate_cache:<-:<player.flag[nameplate]>
        - mount <player.flag[nameplate]> CANCEL
        - remove <player.flag[nameplate]>
        - flag <player> nameplate:!
