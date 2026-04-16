/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void) {
beginLoop:
   iChar = getchar();
   if (iChar == EOF)
   goto endLoop;

    lCharCount++;

    if (!isspace(iChar))
    goto elseBlock;
    
    if (iInWord)
    goto endElse;
    
    lWordCount++;
    iInWord = FALSE;
    goto endElse;
    
    elseBlock:
    if (iInWord)
    goto endElse;
    iInWord = TRUE;
    
    endElse:
    if (iChar != '\n')
    goto beginLoop;
    lLineCount++;
    goto beginLoop;

   endLoop:
   if (!iInWord)
   goto print;
   lWordCount++;

   print:
   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
