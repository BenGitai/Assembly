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


        // load llengths into registers
        mov x0, LENGTH1
        mov x1, LENGTH2
        bl BigInt_larger
        // store result in lSumLength 
        mov LSUMLENGTH, x0

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
        // ulCarry = 0
        mov ULCARRY, 0
        // lIndex = 0
        mov LINDEX, 0
        beginLoop:
        // if (lIndex < lSumLength)
        ldr x0, [sp, LINDEX_OFFSET]
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        cmp x0, x1
        bge endLoop
        // body of for loop 
        // ulSum = ulCarry
        ldr x0, [sp, ULCARRY_OFFSET]
        str x0, [sp, ULSUM_OFFSET]
        // ulCarry = 0
        mov x0, 0
        str x0, [sp, ULCARRY_OFFSET]
        // ulSum += oAddend1->aulDigits[lIndex];
        ldr x0, [sp, ULSUM_OFFSET] 
        ldr x1, [sp, LINDEX_OFFSET] 
        ldr x2, [sp, OADDEND1_OFFSET]
        add x2, x2, AULDIGITS_OFFSET
        ldr x2, [x2, x1, lsl 3]
        add x0, x0, x2
        str x0, [sp, ULSUM_OFFSET]
        cmp x0, x2
        bhs endIf
        // ulCarry = 1
        mov x0, 1
        str x0, [sp, ULCARRY_OFFSET]
        endIf:
        // ulSum += oAddend2->aulDigits[lIndex];
        ldr x0, [sp, ULSUM_OFFSET] 
        ldr x1, [sp, LINDEX_OFFSET] 
        ldr x2, [sp, OADDEND2_OFFSET]
        add x2, x2, AULDIGITS_OFFSET
        ldr x2, [x2, x1, lsl 3]
        add x0, x0, x2
        str x0, [sp, ULSUM_OFFSET]
        cmp x0, x2
        bhs endIf2
        // ulCarry = 1
        mov x0, 1
        str x0, [sp, ULCARRY_OFFSET]
        endIf2:
        // oSum->aulDigits[lIndex] = ulSum;
        ldr x0, [sp, LINDEX_OFFSET]
        ldr x1, [sp, OSUM_OFFSET]
        add x1, x1, AULDIGITS_OFFSET
        ldr x2, [sp, ULSUM_OFFSET]
        str x2, [x1, x0, lsl 3]

        // update loop variable
        ldr x0, [sp, LINDEX_OFFSET]
        add x0, x0, 1
        str x0, [sp, LINDEX_OFFSET]
        b beginLoop
        endLoop:
        //if (ulCarry != 1) goto ulCarrynot1;
        cmp ULCARRY, 1
        bne ulCarrynot1

        //if (lSumLength != MAX_DIGITS) goto endlSum;
        cmp LSUMLENGTH, MAX_DIGITS
        bne endlSum

        //return false;
        mov x0, FALSE
        b return

        // endlSum
        endlSum:

        //osum->aulDigits[lSumLength] = 1;
        ldr x0, [PDIGITS3]
        mov x2, 1
        str x2, [x0, LSUMLENGTH, lsl 3]

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
