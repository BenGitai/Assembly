
   /* Check for a carry out of the last "column" of the addition. */
   if (ulCarry == 1)
   {
      if (lSumLength == MAX_DIGITS)
         return FALSE;
      oSum->aulDigits[lSumLength] = 1;
      lSumLength++;
   }

   /* Set the length of the sum. */
   oSum->lLength = lSumLength;

   return TRUE;

   // flattened if
    //if (ulCarry != 1) goto ulCarrynot1;
    cmp x0, 1
    bne ulCarrynot1

    //if (lSumLength != MAX_DIGITS) goto endlSum;
    ldr x0, [sp, LSUMLENGTH_OFFSET]
    cmp x0, MAX_DIGITS
    bne endlSum

    //return false;
    mov x0, FALSE
    // restore stack frame
    ldr x30, [sp]
    add sp, sp, ADD_STACK_BYTECOUNT
    ret

    // endlSum
    endlSum:

    //osum->aulDigits[lSumLength] = 1;
    ldr x0, [sp, OSUM_OFFSET]
    ldr x0, [x0, AULDIGITS_OFFSET]
    ldr x1, [sp, LSUMLENGTH_OFFSET]
    mov x2, 1
    str x2, [x0, x1, lsl 4]

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
    // restore stack frame
    ldr x30, [sp]
    add sp, sp, ADD_STACK_BYTECOUNT
    ret