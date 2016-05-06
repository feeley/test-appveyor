#include <stdio.h>

double a = 0.01;
double b = 4.00;
double c = 1.734723475976807e-18;

int main() {
  double x = a + b*c;
  printf("sizeof(void*)=%lu\n",sizeof(void*));
  printf("%g\n",a);
  printf("%g\n",b);
  printf("%g\n",c);
  printf("%g\n",x);
  return 0;
}
