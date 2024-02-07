
 include LIBGFX.INC

pile    segment stack         ; Segment de pile

    dw 100 dup(0)             ; Definition de la pile


pile    ends

donnees segment public  ; ******* Segment de donnees **********

; ------ lettre pour exit---------
    lettre db 0          ; Lettre


extrn prestaImage:word

crab DW   14,140
cr01 DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
cr11 DB   0, 0, 0, 7, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0
cr12 DB   0, 0, 0, 0, 7, 0, 0, 0, 7, 0, 0, 0, 0, 0
cr21 DB   0, 0, 0, 7, 7, 7, 7, 7, 7, 7, 0, 0, 0, 0
cr22 DB   0, 0, 7, 7, 4, 7, 7, 7, 0, 7, 7, 0, 0, 0
cr31 DB   0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0
cr32 DB   0, 7, 0, 7, 7, 7, 7, 7, 7, 7, 0, 7, 0, 0
cr41 DB   0, 7, 0, 7, 0, 0, 0, 0, 0, 7, 0, 7, 0, 0
cr42 DB   0, 0, 0, 0, 7, 7, 0, 7, 7, 0, 0, 0, 0, 0
cr51 DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

barc DW   14,140
ba01 DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
ba11 DB   0, 0, 0, 7, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0
ba12 DB   0, 7, 0, 0, 7, 0, 0, 0, 7, 0, 0, 7, 0, 0
ba21 DB   0, 7, 0, 7, 7, 7, 7, 7, 7, 7, 0, 7, 0, 0
ba22 DB   0, 7, 7, 7, 0, 7, 7, 7, 4, 7, 7, 7, 0, 0
ba31 DB   0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0
ba32 DB   0, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 0
ba41 DB   0, 0, 0, 7, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0
ba42 DB   0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0
ba51 DB   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; +++++++++++++++++++++++++++++++++++++++++++++
;               CONSTANTES
; +++++++++++++++++++++++++++++++++++++++++++++
; ============- CRAB ICONS =====================

;Ressource pacman


; +++++++++++++++++++++++++++++++++++++++++++++
;               VARIABLES
; +++++++++++++++++++++++++++++++++++++++++++++

cycle DB  0
direction DB 0
posX  DW  5
posY  DW  5

donnees ends    ; ********** FIN Segment de donnees ************

; +++++++++++++++++++++++++++++++++++++++++++++
;               PROGRAMME
; +++++++++++++++++++++++++++++++++++++++++++++
code    segment public        ; Segment de code
assume  cs:code,ds:donnees,es:code,ss:pile

prog:
; ================== Gestion des registres =========
	mov AX, donnees
	mov DS, AX

	CALL Video13h
    mov tempo, 20

    mov Rx, 100
    mov Ry, 20
    mov Rh, 50
    mov Rw, 10
    mov col, 7

    CALL initPic


    RET


initPic:

    CALL Video13h
    CALL dessineImage
    CALL gererEntreesUtilisateur

    RET

 
dessineImage:
    mov BX, offset prestaImage  
    CALL drawIcon
    RET

gererEntreesUtilisateur:
    mov AH, 01h             ; 01h = fonction getchar DOS... resultats dans AL
    int 21h                 ; lire un caractere
    mov lettre, AL          ; stocker le caractere

    cmp AL, 'Q'             ; comparer avec 'Q'
    je restaurerModeVideo   ; si 'Q', sortir

    cmp AL, 0Dh             ; comparer avec la touche "Enter" (code ASCII 0Dh)
    jne neRienFaire         ; Si different de "Enter", ne rien faire

    jmp map            ; Si "Enter", executer la gameloop

neRienFaire:
    CALL initPic                     ; Ne rien faire pour les autres caracteres

restaurerModeVideo:
    CALL VideoCMD
    jmp fin                             ; Si 'Q', sortir
    



;cycle <<  
dessine:
    mov AX, posX
    mov hX, AX
    mov AX, posY
	mov hY, AX
    cmp cycle, 0
    jne dess1            
	mov BX, offset crab  ; cycle = 0
	CALL drawIcon
    RET
dess1: 
	mov BX, offset barc  ; cycle = 1
	CALL drawIcon
    RET

    ;------- docycle ---------------
; >> posX, cycle
docycle:
    cmp direction, 0   ; move right
    jne moveL
    inc posX
    jmp cycle1
moveL:                 ; move left
    cmp direction, 1
    jne moveU
    dec posX
    jmp cycle1
moveU:
    cmp direction, 2
    jne moveD
    dec posY
    jmp cycle1
moveD:
    inc posY
    
cycle1:          ; change cycle 0-1
    cmp cycle, 0
    jne cycle0
    mov cycle, 1
    RET
cycle0:
    mov cycle, 0
    RET
     
;------- interact ---------------
; >> direction
interact:
	call PeekKey
    cmp userinput, '*'
    jne  testR
    call VideoCMD
	mov AH,4Ch      ; 4Ch = fonction de fin de prog DOS
	mov AL,00h      ; code de sortie 0 (tout s'est bien passe)
	int 21h		  
testR:
    CMP userinput,'M'	; M for right			; case M
    JNE testL
    MOV direction, 0
    RET
testL:
    CMP userinput,'K'	; K for left			; case K
    JNE testU
    MOV direction, 1
	RET
testU:
    CMP userinput,'H'	; H for up				; case H
    JNE testD 
    MOV direction, 2
	RET
testD:
    CMP userinput,'P'	; P for down			; case P
	JNE noHit
    MOV direction, 3
    RET
noHit:
    RET
     
;------- isdead ---------------
; posX, posX >>
isdead:
    mov AX, posX
    add AX, 13
    mov cCX, AX
    mov AX, posY
    add AX, 8
    mov cDX, AX
    call ReadPxl
    cmp rdcol, 0
    je  notdead
    call VideoCMD
	mov AH,4Ch      ; 4Ch = fonction de fin de prog DOS
	mov AL,00h      ; code de sortie 0 (tout s'est bien passe)
	int 21h		
notDead:
    ret


; ========== MAP =============================


map:

    CALL VideoCMD

    ; creer les border horizontales haut et bas
    call BorderHTopBot


    ;creer les border verticales gauche et droite
    call BorderVSide

    ;creer les border horizontales gauche haut et milieu puis droite haut et milieu
    call BorderHSide

    ;creer les border verticales droite et gauche esthethique
    call BorderSideBloc

    ;creer le bloc rectangle fantôme
    call blocSpirit

    ; creer les boules verte antidote anti fantome
    call drawBigPixelPointV1
    call drawBigPixelPointV2
    call drawBigPixelPointV3
    call drawBigPixelPointV4
    call drawBigPixelPointV5

    ;creer les boules de pacman
    call initLinePixV1
    call initLinePixV2
    call initLinePixV3
    call initLinePixV4
    call initLinePixV5
    call initLinePixV6
    call initLinePixV7
    call initLinePixV8
    call initLinePixV9
    call initLinePixV10
    call initLinePixV11
    call initLinePixV12
    call initLinePixV13

    call initLinePixH1
    call initLinePixH2
    call initLinePixH3
    call initLinePixH4
    call initLinePixH5
    call initLinePixH6
    call initLinePixH7
    call initLinePixH8
    call initLinePixH9
    call initLinePixH10
    call initLinePixH11
    call initLinePixH12
    call initLinePixH13
    call initLinePixH14
    call initLinePixH15
    call initLinePixH16
    call initLinePixH17

    ;creer les obstacles
    call blocPac

    ;appeler GAME LOOP
    call gameloop

    RET

; ========== GAME LOOP =============================
gameloop:  
    CALL dessine
    call docycle
    call sleep
    call interact
                             ;call isdead
    jmp gameloop

; ===Fonction MAP===

;================================== Pour après et simplifier le code ==========
;BorderHTopBot:
    ;mov CX, mapVarX
    ;mov BX, 310
    ;mov DX, mapVarY
    ;mov col, 9
    ;call horizontal

    ;cmp mapVarY, 5
    ;je changeValueBorderHTopBot
    ;RET
    

;changeValueBorderHTopBot:   
    ;mov mapVarY, 195
    ;jmp BorderHTopBot

;================================== fin de : Pour après et simplifier le code ==============

BorderHTopBot:
    ; Appel pour la première ligne horizontale
    mov DX, 5
    call drawHorizontal

    ; Appel pour la deuxième ligne horizontale
    mov DX, 195
    call drawHorizontal

    RET

; Procédure pour dessiner une ligne horizontale
drawHorizontal:
    mov CX, 5
    mov BX, 310
    mov col, 9
    call horizontal
    RET  

BorderVSide:
    mov CX, 5
    mov BX, 60
    mov DX, 5
    mov col, 9
    call vertical

    mov CX, 315
    mov BX, 60
    mov DX, 5
    mov col, 9
    call vertical

    mov CX, 67
    mov BX, 11
    mov DX, 65
    mov col, 9
    call vertical

    mov CX, 254
    mov BX, 10
    mov DX, 65
    mov col, 9
    call vertical

    mov CX, 67
    mov BX, 11
    mov DX, 95
    mov col, 9
    call vertical

    mov CX, 254
    mov BX, 10
    mov DX, 95
    mov col, 9
    call vertical

    mov CX, 5
    mov BX, 90
    mov DX, 105
    mov col, 9
    call vertical

    mov CX, 315
    mov BX, 91
    mov DX, 105
    mov col, 9
    call vertical

    RET

BorderHSide:
    mov CX, 5
    mov BX, 62
    mov DX, 65
    mov col, 9
    call horizontal

    mov CX, 254
    mov BX, 62
    mov DX, 65
    mov col, 9
    call horizontal

    mov CX, 0
    mov BX, 67
    mov DX, 75
    mov col, 9
    call horizontal

    mov CX, 254
    mov BX, 66
    mov DX, 75
    mov col, 9
    call horizontal

    mov CX, 0
    mov BX, 67
    mov DX, 95
    mov col, 9
    call horizontal

    mov CX, 254
    mov BX, 66
    mov DX, 95
    mov col, 9
    call horizontal

    mov CX, 5
    mov BX, 62
    mov DX, 105
    mov col, 9
    call horizontal

    mov CX, 254
    mov BX, 62
    mov DX, 105
    mov col, 9
    call horizontal

    RET

BorderSideBloc:
    mov CX, 1
    mov BX, 60
    mov DX, 5
    mov col, 9
    call vertical

    mov CX, 319
    mov BX, 60
    mov DX, 5
    mov col, 9
    call vertical

    mov CX, 1
    mov BX, 90
    mov DX, 105
    mov col, 9
    call vertical

    mov CX, 319
    mov BX, 91
    mov DX, 105
    mov col, 9
    call vertical

    mov CX, 5
    mov BX, 310
    mov DX, 0
    mov col, 9
    call horizontal

    mov CX, 5
    mov BX, 310
    mov DX, 199
    mov col, 9
    call horizontal


    RET

blocSpirit:
    mov CX, 141 ; x
    mov BX, 20
    mov DX, 85 ;y
    mov col, 9
    call vertical

    mov CX, 183
    mov BX, 20
    mov DX, 85
    mov col, 9
    call vertical

    mov CX, 141
    mov BX, 42
    mov DX, 105
    mov col, 9
    call horizontal
    RET


initLinePixV1:
    mov cCX, 9
    mov cDX, 19
    call linePixV
    RET

initLinePixV2:
    mov cCX, 58
    mov cDX, 19
    call linePixV2
    RET

initLinePixV3:
    mov cCX, 12
    mov cDX, 157
    call linePixV3
    RET

initLinePixV4:
    mov cCX, 77
    mov cDX, 63
    call linePixV4
    RET

initLinePixV5:
    mov cCX, 245
    mov cDX, 63
    call linePixV5
    RET

initLinePixV6:
    mov cCX, 308
    mov cDX, 157
    call linePixV6
    RET

initLinePixV7:
    mov cCX, 308
    mov cDX, 110
    call linePixV7
    RET

initLinePixV8:
    mov cCX, 12
    mov cDX, 110
    call linePixV8
    RET

initLinePixV9:
    mov cCX, 123
    mov cDX, 168
    call linePixV9
    RET

initLinePixV10:
    mov cCX, 163
    mov cDX, 168
    call linePixV10
    RET

initLinePixV11:
    mov cCX, 201
    mov cDX, 168
    call linePixV11
    RET

initLinePixV12:
    mov cCX, 222
    mov cDX, 138
    call linePixV12
    RET

initLinePixV13:
    mov cCX, 100
    mov cDX, 138
    call linePixV13
    RET

initLinePixH1:
    mov cCX, 16
    mov cDX, 12
    call linePixH
    RET

initLinePixH2:
    mov cCX, 160
    mov cDX, 9
    call linePixH2
    RET

initLinePixH3:
    mov cCX, 14
    mov cDX, 56
    call linePixH3
    RET

initLinePixH4:
    mov cCX, 167
    mov cDX, 33
    call linePixH4
    RET

initLinePixH5:
    mov cCX, 252
    mov cDX, 33
    call linePixH5
    RET

initLinePixH6:
    mov cCX, 0
    mov cDX, 85
    call linePixH6
    RET

initLinePixH7:
    mov cCX, 254
    mov cDX, 85
    call linePixH7
    RET

initLinePixH8:
    mov cCX, 12
    mov cDX, 185
    call linePixH8
    RET

initLinePixH9:
    mov cCX, 19
    mov cDX, 157
    call linePixH9
    RET

initLinePixH10:
    mov cCX, 252
    mov cDX, 157
    call linePixH10
    RET

initLinePixH11:
    mov cCX, 19
    mov cDX, 110
    call linePixH11
    RET

initLinePixH12:
    mov cCX, 252
    mov cDX, 110
    call linePixH12
    RET

initLinePixH13:
    mov cCX, 19
    mov cDX, 138
    call linePixH13
    RET

initLinePixH14:
    mov cCX, 294
    mov cDX, 138
    call linePixH14
    RET

initLinePixH15:
    mov cCX, 109
    mov cDX, 159
    call linePixH15
    RET

initLinePixH16:
    mov cCX, 201
    mov cDX, 159
    call linePixH16
    RET

initLinePixH17:
    mov cCX, 108
    mov cDX, 134
    call linePixH17
    RET




linePixV:
    call drawPixelVertical
    add cDX, 7
    cmp cDX, 56
    jle linePixV
    RET

linePixV2:
    call drawPixelVertical2
    add cDX, 7
    cmp cDX, 49
    jle linePixV2
    RET

linePixV3:
    call drawPixelVertical3
    add cDX, 7
    cmp cDX, 178
    jle linePixV3
    RET

linePixV4:
    call drawPixelVertical4
    add cDX, 7
    cmp cDX, 159
    jle linePixV4
    RET

linePixV5:
    call drawPixelVertical5
    add cDX, 7
    cmp cDX, 159
    jle linePixV5
    RET

linePixV6:
    call drawPixelVertical6
    add cDX, 7
    cmp cDX, 178
    jle linePixV6
    RET

linePixV7:
    call drawPixelVertical7
    add cDX, 7
    cmp cDX, 138
    jle linePixV7
    RET

linePixV8:
    call drawPixelVertical8
    add cDX, 7
    cmp cDX, 138
    jle linePixV8
    RET

linePixV9:
    call drawPixelVertical9
    add cDX, 7
    cmp cDX, 180
    jle linePixV9
    RET

linePixV10:
    call drawPixelVertical10
    add cDX, 7
    cmp cDX, 180
    jle linePixV10
    RET

linePixV11:
    call drawPixelVertical11
    add cDX, 7
    cmp cDX, 180
    jle linePixV11
    RET


linePixV12:
    call drawPixelVertical12
    add cDX, 7
    cmp cDX, 161
    jle linePixV12
    RET

linePixV13:
    call drawPixelVertical13
    add cDX, 7
    cmp cDX, 161
    jle linePixV13
    RET



linePixH:
    call drawPixelHorizontal
    add cCX, 7
    cmp cCX, 140
    jle linePixH
    RET

linePixH2:
    call drawPixelHorizontal
    add cCX, 7
    cmp cCX, 301
    jle linePixH2
    RET

linePixH3:
    call drawPixelHorizontal2
    add cCX, 7
    cmp cCX, 301
    jle linePixH3
    RET

linePixH4:
    call drawPixelHorizontal4
    add cCX, 7
    cmp cCX, 228
    jle linePixH4
    RET

linePixH5:
    call drawPixelHorizontal4
    add cCX, 7
    cmp cCX, 301
    jle linePixH5
    RET

linePixH6:
    call drawPixelHorizontal6
    add cCX, 7
    cmp cCX, 72
    jle linePixH6
    RET

linePixH7:
    call drawPixelHorizontal6
    add cCX, 7
    cmp cCX, 320
    jle linePixH7
    RET

linePixH8:
    call drawPixelHorizontal8
    add cCX, 7
    cmp cCX, 308
    jle linePixH8
    RET

linePixH9:
    call drawPixelHorizontal9
    add cCX, 7
    cmp cCX, 70
    jle linePixH9
    RET

linePixH10:
    call drawPixelHorizontal9
    add cCX, 7
    cmp cCX, 301
    jle linePixH10
    RET

linePixH11:
    call drawPixelHorizontal11
    add cCX, 7
    cmp cCX, 68
    jle linePixH11
    RET

linePixH12:
    call drawPixelHorizontal11
    add cCX, 7
    cmp cCX, 308
    jle linePixH12
    RET

linePixH13:
    call drawPixelHorizontal13
    add cCX, 7
    cmp cCX, 28
    jle linePixH13
    RET

linePixH14:
    call drawPixelHorizontal13
    add cCX, 7
    cmp cCX, 308
    jle linePixH14
    RET

linePixH15:
    call drawPixelHorizontal15
    add cCX, 7
    cmp cCX, 123
    jle linePixH15
    RET


linePixH16:
    call drawPixelHorizontal15
    add cCX, 7
    cmp cCX, 215
    jle linePixH16
    RET

linePixH17:
    call drawPixelHorizontal17
    add cCX, 7
    cmp cCX, 219
    jle linePixH17
    RET

drawBigPixelPointV1:
    mov cCX, 26
    mov cDX, 146
    mov col, 47
    call BigPixl

    mov cCX, 27
    mov cDX, 146
    mov col, 47
    call BigPixl

    mov cCX, 26
    mov cDX, 147
    mov col, 47
    call BigPixl

    mov cCX, 27
    mov cDX, 147
    mov col, 47
    call BigPixl

    ret

drawBigPixelPointV2:
    mov cCX, 293
    mov cDX, 146
    mov col, 47
    call BigPixl

    mov cCX, 294
    mov cDX, 146
    mov col, 47
    call BigPixl

    mov cCX, 293
    mov cDX, 147
    mov col, 47
    call BigPixl

    mov cCX, 294
    mov cDX, 147
    mov col, 47
    call BigPixl

    ret


drawBigPixelPointV3:
    mov cCX, 162
    mov cDX, 160
    mov col, 47
    call BigPixl

    mov cCX, 163
    mov cDX, 160
    mov col, 47
    call BigPixl

    mov cCX, 162
    mov cDX, 161
    mov col, 47
    call BigPixl

    mov cCX, 163
    mov cDX, 161
    mov col, 47
    call BigPixl

    ret

    mov cCX, 9
    mov cDX, 12

drawBigPixelPointV4:
    mov cCX, 9
    mov cDX, 12
    mov col, 47
    call BigPixl

    mov cCX, 10
    mov cDX, 12
    mov col, 47
    call BigPixl

    mov cCX, 9
    mov cDX, 13
    mov col, 47
    call BigPixl

    mov cCX, 10
    mov cDX, 13
    mov col, 47
    call BigPixl

    ret


drawBigPixelPointV5:
    mov cCX, 244
    mov cDX, 32
    mov col, 47
    call BigPixl

    mov cCX, 245
    mov cDX, 32
    mov col, 47
    call BigPixl

    mov cCX, 244
    mov cDX, 33
    mov col, 47
    call BigPixl

    mov cCX, 245
    mov cDX, 33
    mov col, 47
    call BigPixl

    ret

drawPixelVertical:
    mov cCX, 10
    mov col, 14
    call BigPixl

    mov cCX, 308
    mov col, 14
    call BigPixl

    RET

drawPixelVertical2:
    mov cCX, 58
    mov col, 14
    call BigPixl

    mov cCX, 135
    mov col, 14
    call BigPixl

    mov cCX, 160
    mov col, 14
    call BigPixl

    RET

drawPixelVertical3:
    mov cCX, 12
    mov col, 14
    call BigPixl
    RET

drawPixelVertical4:
    mov cCX, 77
    mov col, 14
    call BigPixl
    RET

drawPixelVertical5:
    mov cCX, 245
    mov col, 14
    call BigPixl
    RET

drawPixelVertical6:
    mov cCX, 308
    mov col, 14
    call BigPixl
    RET

drawPixelVertical7:
    mov cCX, 308
    mov col, 14
    call BigPixl
    RET

drawPixelVertical8:
    mov cCX, 12
    mov col, 14
    call BigPixl
    RET

drawPixelVertical9:
    mov cCX, 123
    mov col, 14
    call BigPixl
    RET

drawPixelVertical10:
    mov cCX, 163
    mov col, 14
    call BigPixl
    RET

drawPixelVertical11:
    mov cCX, 201
    mov col, 14
    call BigPixl
    RET

drawPixelVertical12:
    mov cCX, 222
    mov col, 14
    call BigPixl
    RET

drawPixelVertical13:
    mov cCX, 100
    mov col, 14
    call BigPixl
    RET




drawPixelHorizontal:
    mov cDX, 12
    mov col, 14
    call BigPixl
    RET

drawPixelHorizontal2:
    mov cDX, 56
    mov col, 14
    call BigPixl
    RET

drawPixelHorizontal4:
    mov cDX, 33
    mov col, 14
    call BigPixl
    RET

drawPixelHorizontal6:
    mov cDX, 85
    mov col, 14
    call BigPixl
    RET

drawPixelHorizontal8:
    mov cDX, 185
    mov col, 14
    call BigPixl
    ret

drawPixelHorizontal9:
    mov cDX, 157
    mov col, 14
    call BigPixl
    ret

drawPixelHorizontal11:
    mov cDX, 110
    mov col, 14
    call BigPixl
    ret

drawPixelHorizontal13:
    mov cDX, 138
    mov col, 14
    call BigPixl
    ret

drawPixelHorizontal15:
    mov cDX, 159
    mov col, 14
    call BigPixl
    RET

drawPixelHorizontal17:
    mov cDX, 134
    mov col, 14
    call BigPixl
    RET



blocPac:
    mov col, 9
	mov Rx, 20
	mov Ry, 20
	mov Rw, 30
    mov Rh, 30
    call Rectangle

    mov col, 9
	mov Rx, 145
	mov Ry, 5
	mov Rw, 10
    mov Rh, 40
    call Rectangle

    mov col, 9
	mov Rx, 70
	mov Ry, 20
	mov Rw, 57
    mov Rh, 30
    call Rectangle

    mov col, 9
	mov Rx, 167
	mov Ry, 17
	mov Rw, 135
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 167
	mov Ry, 43
	mov Rw, 135
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 230
	mov Ry, 24
	mov Rw, 7
    mov Rh, 19
    call Rectangle

    mov col, 9
	mov Rx, 5
	mov Ry, 144
	mov Rw, 16
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 299
	mov Ry, 144
	mov Rw, 16
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 130
	mov Ry, 153
	mov Rw, 25
    mov Rh, 21
    call Rectangle

    mov col, 9
	mov Rx, 170
	mov Ry, 153
	mov Rw, 25
    mov Rh, 21
    call Rectangle

    ; Les 3 rectangles long central bas
    mov col, 9
	mov Rx, 108
	mov Ry, 141
	mov Rw, 107
    mov Rh, 12
    call Rectangle

    mov col, 9
	mov Rx, 21
	mov Ry, 166
	mov Rw, 95
    mov Rh, 12
    call Rectangle

    mov col, 9
	mov Rx, 208
	mov Ry, 166
	mov Rw, 95
    mov Rh, 12
    call Rectangle

    mov col, 9
	mov Rx, 19
	mov Ry, 117
	mov Rw, 51
    mov Rh, 16
    call Rectangle

    mov col, 9
	mov Rx, 36
	mov Ry, 133
	mov Rw, 34
    mov Rh, 18
    call Rectangle

    mov col, 9
	mov Rx, 253
	mov Ry, 117
	mov Rw, 51
    mov Rh, 16
    call Rectangle

    mov col, 9
	mov Rx, 253
	mov Ry, 133
	mov Rw, 34
    mov Rh, 18
    call Rectangle

    mov col, 9
	mov Rx, 85
	mov Ry, 91
	mov Rw, 9
    mov Rh, 75
    call Rectangle

    mov col, 9
	mov Rx, 228
	mov Ry, 91
	mov Rw, 9
    mov Rh, 75
    call Rectangle

    mov col, 9
	mov Rx, 85
	mov Ry, 63
	mov Rw, 9
    mov Rh, 14
    call Rectangle

    mov col, 9
	mov Rx, 228
	mov Ry, 63
	mov Rw, 9
    mov Rh, 14
    call Rectangle

    mov col, 9
	mov Rx, 108
	mov Ry, 63
	mov Rw, 107
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 108
	mov Ry, 121
	mov Rw, 107
    mov Rh, 7
    call Rectangle

    mov col, 9
	mov Rx, 108
	mov Ry, 70
	mov Rw, 7
    mov Rh, 35
    call Rectangle

    mov col, 9
	mov Rx, 208
	mov Ry, 86
	mov Rw, 7
    mov Rh, 35
    call Rectangle

    mov col, 9
	mov Rx, 115
	mov Ry, 98
	mov Rw, 10
    mov Rh, 7
    call Rectangle

    RET




; ================= FIN DU CODE ===============
        
fin:
    mov AH, 4Ch                         ; 4Ch = fonction exit DOS
    mov AL, 00h                         ; code de sortie 0 (OK)
    int 21h

code ends                               ; Fin du segment de code
end prog                                ; Fin du programme
