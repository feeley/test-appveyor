#include <stdio.h>

double a = 0.01;
double b = 4.00;
double c = 1.734723475976807e-18;

int main() {
  double x = a + b*c;
  printf("sizeof(void*)=%lu\n",sizeof(void*));
  printf("%f\n",a);
  printf("%f\n",b);
  printf("%f\n",c);
  printf("%f\n",x);
  printf("0x%016llx\n",*(long long*)&a);
  printf("0x%016llx\n",*(long long*)&b);
  printf("0x%016llx\n",*(long long*)&c);
  printf("0x%016llx\n",*(long long*)&x);
  return 0;
}
