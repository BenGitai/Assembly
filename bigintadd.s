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
        str x0, [sp]
        b endElse1
        elseBlock1:
        // iLarger = lLength2
        str x1, [sp]
        endElse1:
        // return iLarger
        ldr x0, [sp]
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
        add x0, x0, AULDIGITS_OFFSET
        mov x1, 0
        mov x2, MAX_DIGITS
        lsl x2, x2, 3
        bl memset
        pastMemset:
        // ulCarry = 0
        mov x0, 0
        str x0, [sp, ULCARRY_OFFSET]
        // lIndex = 0
        str x0, [sp, LINDEX_OFFSET]
        beginLoop:
        // if (lIndex < lSumLength)
        ldr x0, [sp, LINDEX_OFFSET]
        ldr x1, [sp, LSUMLENGTH_OFFSET]
        cmp x0, x1
        ble endLoop
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
        // put pointers back in registers
        ldr x0, [sp, OADDEND1_OFFSET]
        ldr x1, [sp, OADDEND2_OFFSET]
        ldr x2, [sp, OSUM_OFFSET]
        // restore stack frame
        ldr x30, [sp]
        add sp, sp, ADD_STACK_BYTECOUNT
        ret
