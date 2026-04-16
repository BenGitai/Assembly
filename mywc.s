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
        str x30 [iChar]

        // while (iChar != EOF) 
        subs x0 iChar EOF
        be      endLoop

        // lCharCount++
        ldr x0 [lCharCount]
        add x0 x0 1
        str x0 [lCharCount]

        // if (isspace(iChar))
        ldr x0 [iChar]
        bl isspace
        cmp x30
        be elseBlock

        // if (iInWord)
        ldr x0 [iInWord]
        cmp x0
        bne endElse

        // iInWord = FALSE
        mov x0 FALSE
        str x0 [iInWord]
        // lWordCount++
        ldr x0 [lWordCount]
        add x0 x0 1
        str x0 [lWordCount]
        // skip else block
        b endElse

elseBlock:
        // if (! iInWord)
        ldr x0 [iInWord]
        cmp iInWord
        bne endElse
        // inWord = TRUE
        mov x0 TRUE
        str x0 [iInWord]

endElse:
        // if (iChar == '\n')
        ldr x0 [iChar]
        subs x0 x0 '\n'
        cmp x0
        bne beginLoop
        // iLineCount++
        ldr x0 [iLineCount]
        add x0 x0 1
        str x0 [iLineCount]
        b beginLoop

endLoop:
        // if(iInWord)
        ldr x0 [iInWord]
        cmp iInWord
        bne print
        // lWordCount++
        ldr x0 [lWordCount]
        add x0 x0 1
        str x0 [lWordCount]

print:
        // printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
        adr x0 printfFormatStr
        ldr x1 [iLineCount]
        ldr x2 [lWordCount]
        ldr x3 [lCharCount]
        bl printf
        // return 0
        mov x30 0
        ret 
