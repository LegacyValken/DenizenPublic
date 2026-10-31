# ------------------------------------ #
# General use scripts that I've found handy or plan to slot into other projects
# ------------------------------------ #

item_menu_notake:
    debug: false
    type: item
    material: gray_stained_glass_pane
    display name: <&r><empty>
    mechanisms:
        components_patch:
            tooltip_display:
                hide_tooltip: byte:1

item_menu_leftarrow:
    type: item
    debug: false
    material: player_head
    display name: <&f>Previous Page
    mechanisms:
        skull_skin: 6d9cb85a-2b76-4e1f-bccc-941978fd4de0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTE4NWM5N2RiYjgzNTNkZTY1MjY5OGQyNGI2NDMyN2I3OTNhM2YzMmE5OGJlNjdiNzE5ZmJlZGFiMzVlIn19fQ==

item_menu_rightarrow:
    type: item
    debug: false
    material: player_head
    display name: <&f>Next Page
    mechanisms:
        skull_skin: 3cd9b7a3-c8bc-4a05-8cb9-0b6d4673bca9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzFjMGVkZWRkNzExNWZjMWIyM2Q1MWNlOTY2MzU4YjI3MTk1ZGFmMjZlYmI2ZTQ1YTY2YzM0YzY5YzM0MDkxIn19fQ

clamp:
    type: procedure
    debug: false
    definitions: int|min|max
    script:
        - define int <[min]> if:<[int].is_less_than[<[min]>]>
        - define int <[max]> if:<[int].is_more_than[<[max]>]>
        - determine <[int]>

time_stopwatch:
    type: procedure
    debug: false
    definitions: duration
    script:
        - determine <util.time_now.start_of_day.add[<[duration].as[duration]>].format[m:ss]>

# Credit: Berufeng
circumference:
    type: procedure
    debug: false
    definitions: cuboid
    script:

        - define min <[cuboid].min.with_y[64]>
        - define max <[cuboid].max.with_y[64]>
        - define cube <[min].to_cuboid[<[max]>]>

        - define width <[cuboid].min.x.sub[<[cuboid].max.x>].abs>
        - define length <[cuboid].min.z.sub[<[cuboid].max.z>].abs>
        - determine <[width].add[<[length]>].mul[2]>