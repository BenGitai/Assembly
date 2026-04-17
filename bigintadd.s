//----------------------------------------------------------------------
// bigintadd.s
// Author: Jeremy Arking and Ben Gitai
//----------------------------------------------------------------------

        .equ FALSE,   0
        .equ TRUE,    1
        .equ MAX_DIGITS, 32768


//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //--------------------------------------------------------------
        .equ LARGER_STACK_BYTECOUNT, 16
        // note for future optimization: No need for iLarger
BigInt_larger:
        // put space on stack for parameters and lLarger
        sub sp, sp, LARGER_STACK_BYTECOUNT
        // if lLength1 > lLength2
        cmp x0, x1
        ble elseBlock1
        // iLarger = lLength1
        str x0 [sp]
        goto endElse1
        elseBlock1:
        // iLarger = lLength2
        str x1 [sp]
        endElse1:
        // return iLarger
        ldr x0 [sp]
        // restore stack frame
        add sp, sp, LARGER_STACK_BYTECOUNT
        ret 
    
    .global BigInt_add
    // stack variables
    .equ ADD_STACK_BYTECOUNT, 128
    .equ OADDEND1_OFFSET, 16
    .equ OADDEND2_OFFSET, 32
    .equ OSUM_OFFSET, 48
    .equ ULCARRY_OFFSET, 64
    .equ ULSUM_OFFSET, 80
    .equ LINDEX_OFFSET, 96
    .equ LSUMLENGTH_OFFSET, 112
    
    // struct field offsets
    .equ LLENGTH_OFFSET, 0
    .equ AULDIGITS_OFFSET, 16

BigInt_add:
        // allocate space on stack for params local vars
        sub sp, sp, ADD_STACK_BYTECOUNT
        // store return address
        str x30, [sp]
        // store oAddend1 
        str x0, [sp, OADDEND1_OFFSET]
        // store oAddend2 
        str x1, [sp, OADDEND2_OFFSET]
        // store oSum 
        str x2, [sp, OSUM_OFFSET]

        // load llengths into registers
        ldr x0, [sp, OADDEND1_OFFSET]
        ldr x0, [x0, LLENGTH_OFFSET]
        ldr x1, [sp, OADDEND2_OFFSET]
        ldr x1, [x1, LLENGTH_OFFSET]
        bl BigInt_larger
        // store result in lSumLength 
        str x0, [sp, LSUMLENGTH_OFFSET]

        // if (oSum->lLength > lSumLength)
        ldr x0, [sp, OSUM_OFFSET]
        ldr x0, [x0, LLENGTH_OFFSET]
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        cmp x0, x1
        ble pastMemset
        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        ldr x0, [sp, OSUM_OFFSET]
        ldr x0, [x0, AULDIGITS_OFFSET]
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 4
        bl memset
        pastMemset:
        // ulCarry = 0
        mov x0, 0
        str x0, [sp, ULCARRY_OFFSET]










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
