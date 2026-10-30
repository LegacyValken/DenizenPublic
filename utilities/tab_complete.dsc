# ----------------------------------------------------------- #
# Originally created by zozer__firehood
# This has been reuploaded to a public repo due to denizen forums being unavailable
# LegacyValken/LG_Legacy takes no credit for this code
# ----------------------------------------------------------- #

TabComplete:
  type: procedure
  debug: false
  definitions: command|data|raw_args
  script:
    - define raw_args <[raw_args].if_null[<empty>]>
    - define newArg <[raw_args].ends_with[ ].or[<[raw_args].equals[<empty>]>]>
    - define script <script[<[data]>]>
    - define currentData <[script].data_key[<[command]>]>
    - define args <list>
    - if <[raw_args]> != <empty>:
      - define 'args:|:<[raw_args].split[ ]>'
    - define argsSize <[args].size>
    - if <[newArg]>:
      - define argsSize:+:1
    - repeat <[argsSize].sub[1].round_down> as:index:
      - define value <[args].get[<[index]>]>
      - if <[value]> == <empty>:
        - repeat next
      - define keys <[currentData].keys>
      - define permLockedKeys <[keys].filter[starts_with[?]]>
      - define keys:<-:<[permLockedKeys]>
      - if <[keys].contains[<[value]>]>:
        - define currentData <[currentData].get[<[value]>]>
      - else if <[permLockedKeys].size> > 0:
        - define perm <[permLockedKeys].filter[ends_with[ <[value]>]]>
        - if <[perm].is_empty> || !<player.has_permission[<[perm].first.after[?].before[ ].unescaped>]>:
          - determine <list>
        - define currentData <[currentData].get[<[perm].first>]>
      - else:
        - define default <[keys].filter[starts_with[_]]>
        - if <[default].is_empty>:
          - determine <list>
        - define currentData <[currentData].get[<[default].first>]>
      - if <[currentData]> == end:
        - determine <list>
    - foreach <[currentData].keys>:
      - if <[value].starts_with[_]>:
        - define value <[value].after[_]>
        - if <[value].starts_with[*]>:
          - define ret:|:<proc[<[data]>_<[value].after[*]>].context[<[args]>]>
      - else if <[value].starts_with[?]>:
        - define perm <[value].before[ ].after[?].unescaped>
        - if <player.has_permission[<[perm]>]>:
          - define ret:|:<[value].after[ ]>
      - else:
        - define ret:->:<[value]>
    - if !<[ret].exists>:
      - determine <list>
    - if <[newArg]>:
      - determine <[ret]>
    - determine <[ret].filter[starts_with[<[args].last>]]>