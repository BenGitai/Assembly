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
        // if lLength1 > lLength2
        cmp x0, x1
        ble elseBlock1
        // return lLength 1
        b endElse1
        elseBlock1:
        // return lLength2
        mov x0 x1
        endElse1:
        ret 
    
   .global BigInt_add
    // stack variables
    .equ ADD_STACK_BYTECOUNT, 80
    LENGTH1 .req x19
    PDIGITS1 .req x20
    LENGTH2 .req x21
    PDIGITS2 .req x22
    LENGTH3 .req x23
    PDIGITS3 .req x24
    ULCARRY .req x25
    ULSUM .req x26
    LINDEX .req x27
    LSUMLENGTH .req x28

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
        str ULCARRY, [sp, 56]
        str ULSUM, [sp, 64]
        str LINDEX, [sp, 72]
        str LSUMLENGTH, [sp, 80]

        // put params into callee saved registers
        ldr x3, [x0]
        mov LENGTH1, x3
        add x3, x3, 8
        mov PDIGITS1, x3
        ldr x3, [x1]
        mov LENGTH2, x3
        add x3, x3, 8
        mov PDIGITS2, x3
        ldr x3, [x2]
        mov LENGTH3, x3
        add x3, x3, 8
        mov PDIGITS3, x3


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
        add x0, x0, AULDIGITS_OFFSET
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 3
        bl memset
        pastMemset:
        // ulCarry = 0
        mov ULCARRY, 0
        // lIndex = 0
        mov LINDEX, 0
        beginLoop:
        // if (lIndex < lSumLength)
        cmp LINDEX, LSUMLENGTH
        bge endLoop
        // body of for loop 
        // ulSum = ulCarry
        mov ULSUM, ULCARRY
        // ulCarry = 0
        mov ULCARRY, 0
        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [PDIGITS1, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0
        cmp ULSUM, x0
        bhs endIf1
         // ulCarry = 1
        mov ULCARRY, 1
        endIf1:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [PDIGITS2, LINDEX, lsl 3]
        add ULSUM, ULSUM, x0
        cmp ULSUM, x0
        bhs endIf2
         // ulCarry = 1
        mov ULCARRY, 1
        endIf2:
        // oSum->aulDigits[lIndex] = ulSum;
        str ULSUM, [PDIGITS3, LINDEX, lsl 3]

        // update loop variable
        add LINDEX, LINDEX, 1
        b beginLoop
        endLoop:
        //if (ulCarry != 1) goto ulCarrynot1;
        ldr x0, [sp, ULCARRY_OFFSET]
        cmp x0, 1
        bne ulCarrynot1

        //if (lSumLength != MAX_DIGITS) goto endlSum;
        ldr x0, [sp, LSUMLENGTH_OFFSET]
        cmp x0, MAX_DIGITS
        bne endlSum

        //return false;
        mov x0, FALSE
        b return

        // endlSum
        endlSum:

        //osum->aulDigits[lSumLength] = 1;
        ldr x0, [sp, OSUM_OFFSET]
        add x0, x0, AULDIGITS_OFFSET
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        mov x2, 1
        str x2, [x0, x1, lsl 3]

        //lSumLength++;
        ldr x0, [sp, LSUMLENGTH_OFFSET]
        add x0, x0, 1
        str x0, [sp, LSUMLENGTH_OFFSET]

        //ulCarrynot1
        ulCarrynot1:
        //osum->lLength = lSumLength;
        ldr x0, [sp, OSUM_OFFSET]
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        str x1, [x0, LLENGTH_OFFSET]

        //return true;
        mov x0, TRUE
        return:
        // restore stack frame
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
