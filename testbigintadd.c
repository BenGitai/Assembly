#include "bigint.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <limits.h>

static BigInt_T createBigInt(unsigned long ul)
{
   BigInt_T oBigInt = BigInt_new(ul);
   if (oBigInt == NULL)
   {
      fprintf(stderr, "Memory allocation error\n");
      exit(EXIT_FAILURE);
   }
   return oBigInt;
}

unsigned long void compute(unsigned long a, unsigned long b)
{
   BigInt_T oFirst = createBigInt(a);
   BigInt_T oSecond = createBigInt(b);
   BigInt_T oSum = createBigInt(0);

   if (BigInt_add(oFirst, oSecond, oSum))
      BigInt_writeHex(stdout, oSum);
   else
      printf("Addition overflow");
   putchar('\n');

   BigInt_free(oSum);
   BigInt_free(oSecond);
   BigInt_free(oFirst);
}

int main(void)
{
   compute(0, 0);
   compute(0, 1);
   compute(1, 0);
   compute(1, 1);
   compute(123456789, 987654321);
   compute(ULONG_MAX - 1, ULONG_MAX - 1);
   compute(ULONG_MAX - 1, ULONG_MAX);
   compute(ULONG_MAX, ULONG_MAX - 1);
   compute(ULONG_MAX, ULONG_MAX);

   return EXIT_SUCCESS;
}