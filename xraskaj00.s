; Autor reseni: Jan Raška xraskaj00

; Projekt 2 - INP 2025
; Souhlaskove modulovana samohlaskova sifra na architekture MIPS64

; DATA SEGMENT
                .data
msg:            .asciiz "janraska" ; sem doplnte vase "jmenoprijmeni"
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
                daddi   r10, r0, msg
                daddi   r11, r0, cipher
                
                ; Inicializace klíče na pozici "z", protože můžeme mít první písměno souhlásku
                daddi   r13, r0, 26         ; r13 = Key

                ; Konstanta pro vyýpočet pozice písmena
                daddi   r20, r0, 97         ; r20 = 'a'
                ; Konstanta pro kontrolu pretečení abecedy
                daddi   r21, r0, 122        ; r21 = 'z'

loop:
                lb      r12, 0(r10)         ; Nacteni znaku
                beq     r12, r0, end_loop   ; Konec řetězce

                ; Detekce samohlásek (a, e, i, o, u, y)
                daddi   r5, r0, 97          ; 'a'
                beq     r12, r5, vowel_shift
                daddi   r5, r0, 101         ; 'e'
                beq     r12, r5, vowel_shift
                daddi   r5, r0, 105         ; 'i'
                beq     r12, r5, vowel_shift
                daddi   r5, r0, 111         ; 'o'
                beq     r12, r5, vowel_shift
                daddi   r5, r0, 117         ; 'u'
                beq     r12, r5, vowel_shift
                daddi   r5, r0, 121         ; 'y'
                beq     r12, r5, vowel_shift

                ; Aktualizujeme klíč r13 (pozice v abecedě)
                ; r13 = znak - 'a' (ascii 97) + 1
                dsub    r13, r12, r20       ; r13 = char - 97
                daddi   r13, r13, 1         ; r13 = r13 + 1
                
                ; Uložit souhlásku beze změny
                sb      r12, 0(r11)
                b       next_char

vowel_shift:
                ;NewChar = char + r13 (klic pro posunuti)
                dadd    r12, r12, r13       ; Posun
                

overflow:
                slt     r6, r21, r12        ; r6 = 1 pokud 'z' < r12
                beq     r6, r0, vowel_done  ; Pokud neni vetsi, hotovo
                daddi   r12, r12, -26       ; Wrap -26
                b       overflow

vowel_done:
                sb      r12, 0(r11)         ; Uložit zašifrovanou samohlásku

next_char:
                daddi   r10, r10, 1         ; msg++
                daddi   r11, r11, 1         ; cipher++
                b       loop

end_loop:
                sb      r0, 0(r11)

                ; Vypis
                daddi   r4, r0, cipher      ; Adresa vysledku do r4
                jal     print_string        ; Vypis

; NASLEDUJICI KOD NEMODIFIKUJTE!

                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
