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
    
   .global BigInt_add
    // stack variables
    .equ ADD_STACK_BYTECOUNT, 80
    LENGTH1 .req x19
    PDIGITS1 .req x20
    LENGTH2 .req x21
    PDIGITS2 .req x22
    LENGTH3 .req x23
    PDIGITS3 .req x24
    ULSUM .req x25
    LINDEX .req x26
    LSUMLENGTH .req x27

BigInt_add:
        // allocate space on stack for params local vars
        sub sp, sp, ADD_STACK_BYTECOUNT
        // store return address
        str x30, [sp]
        // store callee saved info  
        str LENGTH1, [sp, 8]
        str PDIGITS1, [sp, 16]
        str LENGTH2, [sp, 24]
        str PDIGITS2, [sp, 32]
        str LENGTH3, [sp, 40]
        str PDIGITS3, [sp, 48]
        str ULSUM, [sp, 56]
        str LINDEX, [sp, 64]
        str LSUMLENGTH, [sp, 72]

        // put params into callee saved registers
        ldr x3, [x0]
        mov LENGTH1, x3
        add x0, x0, 8
        mov PDIGITS1, x0
        ldr x3, [x1]
        mov LENGTH2, x3
        add x1, x1, 8
        mov PDIGITS2, x1
        ldr x3, [x2]
        mov LENGTH3, x3
        add x2, x2, 8
        mov PDIGITS3, x2


        // if lLength1 > lLength2
        cmp LENGTH1, LENGTH2
        ble elseBlock1
        mov LSUMLENGTH, LENGTH1
        b pastElse
        elseBlock1:
        mov LSUMLENGTH, LENGTH2
        
        pastElse:
        // if (oSum->lLength > lSumLength)
        cmp LENGTH3, LSUMLENGTH
        ble pastMemset
        // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
        mov x0, PDIGITS3
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 3
        bl memset
        pastMemset:
        // lIndex = 0
        mov LINDEX, 0
        beginLoop:
        // body of for loop 
        // ulSum = ulCarry
        adc ULSUM, xzr, xzr
        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [PDIGITS1, LINDEX, lsl 3]
        adcs ULSUM, ULSUM, x0
        cmp ULSUM, x0
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [PDIGITS2, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0
        cmp ULSUM, x0
        // oSum->aulDigits[lIndex] = ulSum;
        str ULSUM, [PDIGITS3, LINDEX, lsl 3]

        // update loop variable
        add LINDEX, LINDEX, 1
        // if (lIndex < lSumLength)
        cmp LINDEX, LSUMLENGTH
        bge endLoop
        b beginLoop
        endLoop:
        //if (ulCarry != 1) goto ulCarrynot1;
        adcs x0, xzr, xzr
        cmp x0, 0
        beq ulCarrynot1

        //if (lSumLength != MAX_DIGITS) goto endlSum;
        cmp LSUMLENGTH, MAX_DIGITS
        bne endlSum

        //return false;
        mov x0, FALSE
        b return

        // endlSum
        endlSum:

        //osum->aulDigits[lSumLength] = 1;
        mov x2, 1
        str x2, [PDIGITS3, LSUMLENGTH, lsl 3]

        //lSumLength++;
        add LSUMLENGTH, LSUMLENGTH, 1

        //ulCarrynot1
        ulCarrynot1:
        //osum->lLength = lSumLength;
        mov LENGTH3, LSUMLENGTH

        //return true;
        mov x0, TRUE
        return:
        // update BigInt lLengths 
        sub PDIGITS1, PDIGITS1, 8
        str LENGTH1, [PDIGITS1]
        sub PDIGITS2, PDIGITS2, 8
        str LENGTH2, [PDIGITS2]
        sub PDIGITS3, PDIGITS3, 8
        str LENGTH3, [PDIGITS3]

        // restore callee saved registers
        ldr LENGTH1, [sp, 8]
        ldr PDIGITS1, [sp, 16]
        ldr LENGTH2, [sp, 24]
        ldr PDIGITS2, [sp, 32]
        ldr LENGTH3, [sp, 40]
        ldr PDIGITS3, [sp, 48]
        ldr ULCARRY, [sp, 56]
        ldr ULSUM, [sp, 64]
        ldr LINDEX, [sp, 72]
        ldr LSUMLENGTH, [sp, 80]
        
        // restore stack frame
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
