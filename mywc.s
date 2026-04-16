//----------------------------------------------------------------------
// mywc.s
// Author: Jeremy Arking
//----------------------------------------------------------------------

        .equ FALSE,   0
        .equ TRUE,    1
        .equ EOF,    -1 

//----------------------------------------------------------------------
        .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------
        .section .data

lLineCount:
        .quad   0
lWordCount:
        .quad   0
lCharCount:
        .quad   0
iInWord:
        .word   FALSE

//----------------------------------------------------------------------
        .section .bss

iChar:
    .skip       4

//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and characters
        // are in stdin. A word is a sequence of non-whitespace characters.
        // Whitespace is defined by the isspace() function. Return 0.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        // Prolog
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

beginLoop:

        // iChar = getchar()
        bl getchar
	adr x1, iChar
        str x0, [x1]

        // while (iChar != EOF) 
	adr x0, iChar
	ldr x0, [x0]
	cmp w0, EOF
        beq      endLoop

        // lCharCount++
	adr x0, lCharCount
	ldr x1, [x0]
        add x1, x1, 1
        str x1, [x0]

        // if (isspace(iChar))
	adr x0, iChar
	ldr x0, [x0]
        bl isspace
        cmp x0, 0
        beq elseBlock

        // if (iInWord)
	adr x0, iInWord
	ldr w0, [x0]
        cmp w0, wzr
        beq endElse

        // iInWord = FALSE
	adr x1, iInWord
        mov w0, FALSE
        str w0, [x1]
        // lWordCount++
	adr x1, lWordCount
        ldr x0, [x1]
        add x0, x0, 1
        str x0, [x1]
        // skip else block
        b endElse

elseBlock:
        // if (! iInWord)
	adr x1, iInWord
	ldr x0, [x1]
        cmp w0, wzr
        bne endElse
        // inWord = TRUE
        mov x0, TRUE
        str x0, [x1]

endElse:
        // if (iChar == '\n')
	adr x1, iChar
	ldr x0, [x1]
        subs x0, x0, '\n'
        cmp x0, 0
        bne beginLoop
        // lLineCount++
	adr x1, lLineCount
        ldr x0, [x1]
        add x0, x0, 1
        str x0, [x1]
        b beginLoop

endLoop:
        // if(iInWord)
	adr x1, iInWord
        ldr x0, [x1]
        cmp x0, 0
        bne print
        // lWordCount++
	adr x1, lWordCount
        ldr x0, [x1]
        add x0, x0, 1
        str x0, [x1]

print:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr x0, printfFormatStr
	adr x4, lLineCount
        ldr x1, [x4]
	adr x4, lWordCount
        ldr x2, [x4]
	adr x4, lCharCount
        ldr x3, [x4]
        bl printf
        // return 0
	ldr x30, [sp]
        add sp, sp, MAIN_STACK_BYTECOUNT
	mov x0, 0
        ret 
