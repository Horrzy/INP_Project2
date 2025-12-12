; Autor reseni: Jan Raska xraskaj00

; Projekt 2 - INP 2025
; Souhlaskove modulovana samohlaskova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "janraska" ; sem doplnte vase "janraska"
cipher:         .space  31 ; misto pro zapis zasifrovaneho textu
; zde si muzete nadefinovat vlastni promenne ci konstanty,
; napr. hodnoty posuvu pro jednotlive znaky sifrovacho klice

params_sys5:    .space  8 ; misto pro ulozeni adresy pocatku
                          ; retezce pro vypis pomoci syscall 5
                          ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

main:           ; ZDE NAHRADTE KOD VASIM RESENIM
                ; Inicializace registru
                daddi   r10, r0, msg        ; r10 = adresa msg (source)
                daddi   r11, r0, cipher     ; r11 = adresa cipher (dest)
                
                ; Inicializace Klic (r13) na 'z' (26. pismeno)
                ; Zadání: "Pokud samohlásce nepředchází žádná souhláska..., uvažujeme souhlásku „z“"
                daddi   r13, r0, 26         ; r13 = Key

                ; Konstanty
                daddi   r20, r0, 97         ; r20 = 'a'
                daddi   r21, r0, 122        ; r21 = 'z'

loop:
                lb      r12, 0(r10)         ; Nacteni znaku
                beq     r12, r0, end_loop   ; Konec retezce -> konec

                ; Detekce samohlasek (a, e, i, o, u, y)
                daddi   r5, r0, 97          ; 'a'
                beq     r12, r5, is_vowel
                daddi   r5, r0, 101         ; 'e'
                beq     r12, r5, is_vowel
                daddi   r5, r0, 105         ; 'i'
                beq     r12, r5, is_vowel
                daddi   r5, r0, 111         ; 'o'
                beq     r12, r5, is_vowel
                daddi   r5, r0, 117         ; 'u'
                beq     r12, r5, is_vowel
                daddi   r5, r0, 121         ; 'y'
                beq     r12, r5, is_vowel

                ; ELSE: JE TO SOUHLASKA
                ; Update klice: Key = Char - 'a' + 1
                dsub    r13, r12, r20       ; r13 = char - 97
                daddi   r13, r13, 1         ; r13 = r13 + 1
                
                ; Ulozit souhlasku beze zmeny
                sb      r12, 0(r11)
                b       next_char

is_vowel:
                ; JE TO SAMOHLASKA
                ; Sifrovat: NewChar = Char + Key
                dadd    r12, r12, r13       ; Posun
                
                ; Kontrola preteceni pres 'z'
                ; Pokud r12 > 'z', r12 -= 26
check_wrap:
                slt     r6, r21, r12        ; r6 = 1 pokud 'z' < r12
                beq     r6, r0, vowel_done  ; Pokud neni vetsi, hotovo
                daddi   r12, r12, -26       ; Wrap -26
                b       check_wrap          ; Pro jistotu znova (pri velkem klici)

vowel_done:
                sb      r12, 0(r11)         ; Ulozit zasifrovanou samohlasku

next_char:
                daddi   r10, r10, 1         ; msg++
                daddi   r11, r11, 1         ; cipher++
                b       loop

end_loop:
                sb      r0, 0(r11)          ; Null terminator pro cipher

                ; Vypis
                daddi   r4, r0, cipher      ; Adresa vysledku do r4
                jal     print_string        ; Vypis

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
