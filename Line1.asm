; vers�o de 10/05/2007
; corrigido erro de arredondamento na rotina line.
; circle e full_circle disponibilizados por Jefferson Moro em 10/2009
; este e o 2 codigo de testes o primeiro e o linec0
segment code
..start:
                call init_teclado
    		mov 		ax,data
    		mov 		ds,ax
    		mov 		ax,stack
    		mov 		ss,ax
    		mov 		sp,stacktop

; salvar modo corrente de video(vendo como est� o modo de video da maquina)
        	mov  		ah,0Fh
    		int  		10h
    		mov  		[modo_anterior],al  
    		mov             word[qu1], 1
    		mov             word[qu2], 1
    		
    		jmp		q1 

; alterar modo de video para gr�fico 640x480 16 cores
init_teclado:
		mov ah, 09h
		mov al, 01h
		int 21h
		ret

bola:
		mov 		bx, [pxc]
		mov		ax,320
		add 		ax, bx
		push		ax
		
		mov 		bx, [pyc]
		mov		ax,140
		add 		ax, bx
		push		ax
		
		mov		ax,10
		
		push		ax
		call	full_circle
		
		
		
		ret
q1:
	
		call limpar_tela
		 
		; Carrega o valor do contador em um registrador
  		call bola
	        mov		cx, 10
	        call		barra
	     
	        mov              cx, 10
	        mov             bx, 0
	        call            blocos
		
		
		
		mov             ax, word[qu1]
		add             word[pxc], ax
		mov             ax, word[qu2]
		add 		word [pyc],ax

		call 		adelante
		call 		verifica_parede
		call            verifica_barra
		jmp 		q1
		
verifica_barra: ;caso a bola encoste na barra
		mov     ax, [pyc]
		cmp     ax, -120
		jl sair
		cmp     ax, 0
		jne     continuar2 ; se pyc não for 0, pula para continuar

		mov     ax, [pxc]
		mov     bx, [pxl]
		sub     bx, 50
		cmp     ax, bx
		jl      continuar2 ; se pxc <  pxl-50, pula para continuar
		mov     bx, [pxl]
		add     bx, 50
		cmp     ax, bx
		jg      continuar2 ; se pxc > 345 + pxl, pula para continuar
		
		mov     bx, [pxl]
		cmp     ax, bx
		mov     word[qu1], -1
		mov     word[qu2], 1
		jl      q1 ; se pxc <  pxl-25, pula para continuar
		
		mov     bx, [pxl]
		cmp     ax, bx
		mov     word[qu1], 1
		mov     word[qu2], 1
		
		jmp     q1
continuar2:
 	ret ; retorna a o coaigo de execução		
			
sair:
	jmp sai	
	
barra:
               
		mov		byte[cor],branco_intenso	;antenas
	        mov             bx, [pxl]
	        mov             dx, [barrax]
		mov		ax, 370
		add             ax, bx
		push		ax
		mov		ax,dx
		push		ax
		mov		ax, 270
		add             ax, bx
		push		ax
		mov		ax,dx
		push		ax
		call		line
		mov             ax, -1
		add             [barrax],ax
		loop            barra
		mov             word [barrax], 130
		
		
		ret

;aqui vamos verificar para qual ciclo a bola vai, qual 'quandrante'	


		             
decrementa:

		call adelante
		call limpar_tela
		
		mov             ax, word[qu1]
		add             word[pxc], ax
		mov             ax, word[qu2]
		add 		word [pyc],ax
		; Carrega o valor do contador em um registrador
  		call bola
		mov		cx, 10
		call		barra
		mov		cx, 10
		
		mov             bx, 0
		call            blocos
		call     	verifica_barra
		
		jmp 		decrementa
		

limpar_tela:	
		mov     	al,12h
   		mov     	ah,0
    	        int     	10h	
		mov		byte[cor],vermelho	;circulos vermelhos	
		ret 		
verifica_parede:
		mov ax, [pxc]   ; Carrega o valor atual do contador
		mov bx, [pyc]
		
		mov dx, [qu1]
		mov cx, [qu2]
		

		
	        cmp ax, -280          ; Compara com 620
	        mov word[qu1], 1
	        mov word[qu2], -1
	        jl decrementa
	        
	        cmp ax, 290        ; Compara com 620
	        mov word[qu1], -1
	        mov word[qu2], -1
	        jg decrementa
	        
	        mov word[qu1], dx
	        mov word[qu2], cx
	        jmp    continuar
	        
	        
	



adelante:
		    mov ah, 01h ; Verifica se uma tecla foi pressionada
		    int 16h
		    jz continuar ; Se não, continua

		    mov ah, 00h    ; Lê o código da tecla pressionada
		    int 16h
		    
		    cmp al, 'q'     ; Verifica se é uma tecla especial
		    je .check_exit

		    ; Lê a tecla especial (seta)
		    

		    cmp al, 'd'   ; Seta para a direita
		    je .right
		    
		    cmp al,  'a'  ; Seta para a esquerda
		    je .left
		    
		    
		    
		    jmp continuar
		    
.check_exit:
		    cmp al, 'q'
		    je sai ; Sai se foi 'q'
		    jmp continuar

.left:
		    ; Código para seta para a esquerda
		    ; Adicione seu código específico aqui
		    dec word [pxl]
		    jmp continuar

.right:
		    ; Código para seta para a direita
		    ; Adicione seu código específico aqui
		    inc word [pxl]
		    jmp continuar
                
continuar:
       
 	ret ; retorna a o coaigo de execução
sai:
	mov ah,0 ; set video mode
	mov al,[modo_anterior] ; recupera o modo anterior
	int 10h
	mov ax,4c00h
	int 21h
moveb:
		mov ah, 01h ;Ler caracter da STDIN
		int 16H
		jz continuar
		mov ah, 00h
		int 16h
		cmp al, '' ;Verifica se foi 's'. Se foi, finaliza o programa
		
		jne continuar
        


			
delay: ; Esteja atento pois talvez seja importante salvar contexto (no caso, CX, o que NÃO foi feito aqui).
	mov cx, word [velocidade] ; Carrega “velocidade” em cx (contador para loop)
del2:
	push cx ; Coloca cx na pilha para usa-lo em outro loop
	loop del2 ; Teste modificando este valor
	ret
del1:
	loop del1 ; No loop del1, cx é decrementado até que volte a ser zero
	pop cx ; Recupera cx da pilha
	loop del2 ; No loop del2, cx é decrementado até que seja zero
	ret
blocos:         
                mov       cx, 10
                
                mov       ax, [bone]
                cmp       ax, 0
               
                jne 	  bl1
                
                je        bl2
                
    
		
		ret
 
                
                		
bl1:            
                 mov             bx, 1
		mov		ax, 105
		mul             bx
		sub             ax, 85
		push		ax
		
		mov		ax, 420
		push		ax
		
		mov		ax, 105
		mul             bx 
		push		ax
		
		mov		ax, 420
		push		ax
		call		line
		loop             bl1
		mov       ax, [btwo]
                cmp       ax, 0
                mov        cx, 10
                jne       bl2
               
                je bl3
                
bl2:     
                 mov             bx, 2
		mov		ax, 105
		mul             bx
		sub             ax, 85
		push		ax
		
		mov		ax, 420
		push		ax
		
		mov		ax, 105
		mul             bx 
		push		ax
		
		mov		ax, 420
		push		ax
		call		line
	        loop            bl2
		mov       ax, [btree]
                cmp       ax, 0
                mov        cx, 10
                jne       bl3
                
                ret
bl3:     
                mov             bx, 3
		mov		ax, 105
		mul             bx
		sub             ax, 85
		push		ax
		
		mov		ax, 420
		push		ax
		
		mov		ax, 105
		mul             bx 
		push		ax
		
		mov		ax, 420
		push		ax
		call		line
		loop             bl3
		
               ret

	
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		
		;;colocar as imagens na tela dos circulos etc
		
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub		dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4


;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d
	
inf:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	

	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

;; parece mecher com delay e velocidade de print
;;altera o preenchimento da forma do circulo
	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	

	mov		si,bx
	sub		si,cx
	push    ax			;colonasca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	
	;;line mexe com a forma do criculo
	call line
	
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full
	
inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar_full:	
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call 	line
	
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call	line
	
	cmp		cx,dx
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6

;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		
		;;altera a forma do circulo
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
;*******************************************************************
segment data

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15


bone		dw 	1
btwo 		dw 	1
btree		dw 	1
bfour		dw 	0
bfive		dw 	1
bsix		dw 	1

		
blocosy   	dw              420,420,420,420,420,420,200,200,200,200,200,200
blocosx		dd              65,175,285,395,505,615,65,175,285,395,505,615
modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0	
velocidade      dw              1
;;cotadores que parte com valor 0 de um posicao predefinida como, (320, 140)
pxc             dw              0
pyc             dw              0
pxl             dw              0
pyl             dw              0
;variaveis de adicao e subtracao para otimizacao do cosigo
qu1             dw              0
qu2             dw              0
barrax          dw              130
quadrante       dw              0
quadrante_size  equ             $ - quadrante

mens    	db  		'Funcao Grafica'
;*************************************************************************
segment stack stack
    		resb 		512
stacktop:
