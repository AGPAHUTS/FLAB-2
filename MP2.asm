; ==============================================================================
; MP2: Dungeon Adventure and Survival Game (Optimized & Fixed)
; Target: x86 32-bit NASM on Linux (int 0x80)
; ==============================================================================

section .data
    welcome_art db "=======================================", 0xA
                db "       DUNGEON OF THE LOST KING        ", 0xA
                db "=======================================", 0xA
                db "              |>>>>                    ", 0xA
                db "              |          _  _|_  _     ", 0xA
                db "             |;|_|;|_|;|               ", 0xA
                db "             \.    .  /                ", 0xA
                db "              \:  .  /                 ", 0xA
                db "               ||:   |                 ", 0xA
                db "               ||:.  |                 ", 0xA
                db "               ||:  .|                 ", 0xA
                db "       ENTER IF YOU DARE!              ", 0xA
                db "=======================================", 0xA, 0
    
    prompt_name  db "Enter your hero name: ", 0
    prompt_class db "Choose your character:", 0xA
                 db "[1] Warrior (HP:100, ATK:20, Potions:2)", 0xA
                 db "[2] Mage    (HP:70,  ATK:30, Potions:3)", 0xA
                 db "[3] Archer  (HP:85,  ATK:25, Potions:2)", 0xA
                 db "Enter choice: ", 0
    
    msg_welcome  db "Welcome, ", 0
    msg_excl     db "!", 0xA, 0
    
    c_warrior    db "Warrior", 0
    c_mage       db "Mage", 0
    c_archer     db "Archer", 0

    menu_str     db 0xA, "================ MAIN MENU ================", 0xA
                 db "[1] Explore Dungeon", 0xA
                 db "[2] View Character Status", 0xA
                 db "[3] Use Health Potion", 0xA
                 db "[4] View Inventory", 0xA
                 db "[5] Exit Game", 0xA
                 db "Enter your choice: ", 0

    err_msg      db "Invalid selection!", 0xA, 0

    goblin_art   db 0xA, "          ,      ,         ", 0xA
                 db "         /(.-''''-.)\      ", 0xA
                 db "        |\  \/      \/  /| ", 0xA
                 db "        | \ / =.  .= \ / | ", 0xA
                 db "         \  \   ^    /  /  ", 0xA
                 db "          \  '-----'  /    ", 0xA
                 db "A GOBLIN APPEARS!", 0xA, 0

    treasure_art db 0xA, "          __________         ", 0xA
                 db "         /_________/|        ", 0xA
                 db "        |  _____  | |        ", 0xA
                 db "        | |  ?  | | |        ", 0xA
                 db "        | |_____| | /        ", 0xA
                 db "        |_________|/         ", 0xA
                 db "YOU FOUND A CHEST! [1] Open [2] Leave: ", 0

    msg_chest    db "You found 50 Gold!", 0xA, 0
    msg_leave    db "You left the chest.", 0xA, 0

    dragon_art   db 0xA, "               / \  //\    ", 0xA
                 db "              |\___/|      ", 0xA
                 db "              \      /     ", 0xA
                 db "             0  0  \       ", 0xA
                 db "             |     /       ", 0xA
                 db "              ^    \       ", 0xA
                 db "             /    /        ", 0xA
                 db "          \___/   \        ", 0xA
                 db "         /    \___________\/", 0xA
                 db "THE DRAGON AWAKENS!", 0xA, 0

    combat_menu  db "[1] Attack [2] Defend [3] Potion [4] Run: ", 0
    msg_atk      db "You deal ", 0
    msg_def      db "You defend! Damage reduced by 5.", 0xA, 0
    msg_run      db "You fled from combat!", 0xA, 0
    msg_hit      db "Enemy hits for ", 0
    msg_dmg_sfx  db " damage!", 0xA, 0
    msg_def_foe  db "Enemy Defeated!", 0xA, 0
    msg_cleared  db "All rooms cleared!", 0xA, 0

    lbl_status   db 0xA, "===== STATUS =====", 0xA, 0
    lbl_inv      db 0xA, "===== INVENTORY =====", 0xA, 0
    str_name     db "Name: ", 0
    str_class    db "Class: ", 0
    str_hp       db "Health: ", 0
    str_slash    db "/", 0
    str_atk_lbl  db "Attack: ", 0
    str_pot      db "Potions: ", 0
    str_gold     db "Gold: ", 0

    msg_pot_use  db "Restored 20 HP!", 0xA, 0
    msg_pot_full db "Health is full!", 0xA, 0
    msg_no_pot   db "No potions left!", 0xA, 0

    victory_art  db 0xA, "=======================================", 0xA
                 db "               VICTORY!                ", 0xA
                 db "=======================================", 0xA
                 db "CONGRATULATIONS, ", 0
    vic_p2       db "! You defeated the dragon!", 0xA, 0
    hero_title   db "YOU ARE A HERO!", 0xA, 0

    gameover_art db 0xA, "=======================================", 0xA
                 db "              GAME OVER                ", 0xA
                 db "=======================================", 0xA
                 db "Your hero has fallen.", 0xA, 0

    newline      db 0xA, 0

section .bss
    p_name       resb 32
    p_name_len   resd 1
    class_ptr    resd 1
    max_hp       resd 1
    current_hp   resd 1
    atk_power    resd 1
    potions      resd 1
    gold         resd 1
    room         resd 1
    defend_flg   resd 1
    enemy_hp     resd 1
    enemy_atk    resd 1
    input_buf    resb 16
    num_buf      resb 12

section .text
    global _start

_start:
    mov dword [room], 1
    mov dword [gold], 0
    call display_welcome
    call get_player_info
    call initialize_character

menu_loop:
    call display_main_menu
    call read_input
    mov al, [input_buf]
    cmp al, '1'
    je do_exp
    cmp al, '2'
    je do_sta
    cmp al, '3'
    je do_pot
    cmp al, '4'
    je do_inv
    cmp al, '5'
    je exit_program
    
    push err_msg
    call print_cstring
    jmp menu_loop

do_exp: 
    call explore_dungeon
    jmp menu_loop
do_sta: 
    call display_status
    jmp menu_loop
do_pot: 
    call use_potion
    jmp menu_loop
do_inv: 
    call display_inventory
    jmp menu_loop

display_welcome:
    push welcome_art
    call print_cstring
    ret

get_player_info:
    push prompt_name
    call print_cstring
    mov eax, 3
    xor ebx, ebx
    mov ecx, p_name
    mov edx, 32
    int 0x80
    dec eax
    mov [p_name_len], eax
    mov byte [p_name + eax], 0  ; Strip newline

.class_prompt:
    push prompt_class
    call print_cstring
    call read_input
    mov al, [input_buf]
    sub al, '1'
    cmp al, 2
    jbe .class_ok
    push err_msg
    call print_cstring
    jmp .class_prompt
.class_ok:
    ret

initialize_character:
    mov al, [input_buf]
    sub al, '1'
    mov ecx, 100
    mov edx, 20
    mov esi, 2
    cmp al, 0
    je .set
    mov ecx, 70
    mov edx, 30
    mov esi, 3
    cmp al, 1
    je .set
    mov ecx, 85
    mov edx, 25
    mov esi, 2
.set:
    mov [max_hp], ecx
    mov [current_hp], ecx
    mov [atk_power], edx
    mov [potions], esi
    
    mov al, [input_buf]
    mov edx, c_warrior
    cmp al, '1'
    je .print_w
    mov edx, c_mage
    cmp al, '2'
    je .print_w
    mov edx, c_archer
.print_w:
    mov [class_ptr], edx
    push msg_welcome
    call print_cstring
    push dword [class_ptr]
    call print_cstring
    push p_name
    call print_cstring
    push msg_excl
    call print_cstring
    ret

display_main_menu:
    push menu_str
    call print_cstring
    ret

explore_dungeon:
    mov eax, [room]
    cmp eax, 1
    je .r1
    cmp eax, 2
    je .r2
    cmp eax, 3
    je .r3
    push msg_cleared
    call print_cstring
    ret
.r1:
    push goblin_art
    call print_cstring
    mov dword [enemy_hp], 30
    mov dword [enemy_atk], 10
    call battle_enemy
    ret
.r2:
    push treasure_art
    call print_cstring
    call read_input
    cmp byte [input_buf], '1'
    jne .skip_c
    add dword [gold], 50
    push msg_chest
    call print_cstring
    jmp .adv
.skip_c:
    push msg_leave
    call print_cstring
.adv:
    mov dword [room], 3
    ret
.r3:
    push dragon_art
    call print_cstring
    mov dword [enemy_hp], 60
    mov dword [enemy_atk], 15
    call battle_enemy
    ret

battle_enemy:
.loop:
    mov dword [defend_flg], 0
    push combat_menu
    call print_cstring
    call read_input
    mov al, [input_buf]
    cmp al, '1'
    je .atk
    cmp al, '2'
    je .def
    cmp al, '3'
    je .pot
    cmp al, '4'
    je .run
    push err_msg
    call print_cstring
    jmp .loop
.atk:
    mov eax, [atk_power]
    push msg_atk
    call print_cstring
    push dword [atk_power]
    call print_number
    push msg_dmg_sfx
    call print_cstring
    mov eax, [enemy_hp]
    sub eax, [atk_power]
    test eax, eax
    jns .set_e
    xor eax, eax
.set_e:
    mov [enemy_hp], eax
    jz .defeat
    jmp .retaliate
.def:
    mov dword [defend_flg], 1
    push msg_def
    call print_cstring
    jmp .retaliate
.pot:
    call use_potion
    jmp .retaliate
.run:
    push msg_run
    call print_cstring
    ret
.retaliate:
    mov eax, [enemy_atk]
    cmp dword [defend_flg], 1
    jne .hit_p
    sub eax, 5
    test eax, eax
    jns .hit_p
    xor eax, eax
.hit_p:
    push eax
    push msg_hit
    call print_cstring
    pop eax
    push eax
    call print_number
    push msg_dmg_sfx
    call print_cstring
    mov ebx, [current_hp]
    sub ebx, eax
    test ebx, ebx
    jns .set_p
    xor ebx, ebx
.set_p:
    mov [current_hp], ebx
    jz .gameover
    test ebx, ebx
    jz .gameover
    jmp .loop
.defeat:
    push msg_def_foe
    call print_cstring
    inc dword [room]
    cmp dword [room], 4
    jne .done
    call display_game_result
    call exit_program
.gameover:
    call display_game_result
    call exit_program
.done:
    ret

use_potion:
    cmp dword [potions], 0
    jle .none
    mov eax, [current_hp]
    cmp eax, [max_hp]
    jge .full
    add eax, 20
    cmp eax, [max_hp]
    jle .ok
    mov eax, [max_hp]
.ok:
    mov [current_hp], eax
    dec dword [potions]
    push msg_pot_use
    call print_cstring
    ret
.full:
    push msg_pot_full
    call print_cstring
    ret
.none:
    push msg_no_pot
    call print_cstring
    ret

display_status:
    push lbl_status
    call print_cstring
    push str_name
    call print_cstring
    push p_name
    call print_cstring
    push newline
    call print_cstring
    push str_class
    call print_cstring
    push dword [class_ptr]
    call print_cstring
    push newline
    call print_cstring
    push str_hp
    call print_cstring
    push dword [current_hp]
    call print_number
    push str_slash
    call print_cstring
    push dword [max_hp]
    call print_number
    push newline
    call print_cstring
    push str_atk_lbl
    call print_cstring
    push dword [atk_power]
    call print_number
    push newline
    call print_cstring
    ret

display_inventory:
    push lbl_inv
    call print_cstring
    push str_pot
    call print_cstring
    push dword [potions]
    call print_number
    push newline
    call print_cstring
    push str_gold
    call print_cstring
    push dword [gold]
    call print_number
    push newline
    call print_cstring
    ret

display_game_result:
    cmp dword [current_hp], 0
    jle .gov
    push victory_art
    call print_cstring
    push p_name
    call print_cstring
    push vic_p2
    call print_cstring
    push str_gold
    call print_cstring
    push dword [gold]
    call print_number
    push newline
    call print_cstring
    push hero_title
    call print_cstring
    ret
.gov:
    push gameover_art
    call print_cstring
    ret

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

; --- Utility Functions ---
read_input:
    mov eax, 3
    xor ebx, ebx
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    ret

print_cstring:
    mov edx, [esp + 4]    ; Get string pointer
    push edi
    mov edi, edx
    xor ecx, ecx          ; ecx will count length
.len:
    cmp byte [edi + ecx], 0
    je .prt
    inc ecx
    jmp .len
.prt:
    mov edx, ecx          ; Move length to edx (sys_write expects length in edx)
    mov ecx, edi          ; Move string pointer to ecx (sys_write expects pointer in ecx)
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    int 0x80
    pop edi
    ret 4

print_number:
    mov eax, [esp + 4]
    lea edi, [num_buf + 11]
    mov byte [edi], 0
    mov ebx, 10
    test eax, eax
    jnz .conv
    dec edi
    mov byte [edi], '0'
    jmp .out
.conv:
    test eax, eax
    jz .out
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    jmp .conv
.out:
    push edi
    call print_cstring
    ret 4