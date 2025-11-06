#include <iostream>
#include <stdexcept>
#include "math_library.hpp"
namespace math_library{
    int fatorial(int n){
        if(n<0) throw std::invalid_argument("O número deve ser maior que 0\n");
        if(n<=1) return 1;
        return n * fatorial(n-1);
    }
    double potencia(double base, int expoente){
        double resultado=1;
        if(base < 0 && expoente%2==0) throw std::invalid_argument("A base não deve ser menor que 0 e o expoente par ao mesmo tempo\n");
        for(int i = 1; i <=expoente ; i++){
           resultado *= base;
        }
        return resultado;
    }
    double areaCirculo(int raio){ 
        return PI * static_cast<double>(raio * raio);
    }
    double areaRetangulo(int base, int altura){
        return base * altura;
    }
    int areaTriangulo(int base, double altura){
        return base * (altura/2);
    }

}
