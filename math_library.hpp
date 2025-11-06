#ifndef MATH_LIBRARY_HPP
#define MATH_LIBRARY_HPP
namespace math_library{
    constexpr double PI = 3.141592653589793;
    double potencia(double base, int expoente );
    int fatorial(int n);
    double areaCirculo(int raio);
    double areaRetangulo(int base, int altura);
    int areaTriangulo(int base, int altura);
    template<typename A, typename B> 
    auto operator+(A number, B number2){
        return number + number2;
    }
    template<typename A, typename B> 
    auto operator*(A number, B number2){
        return number*number2;
    }
    template<typename A, typename B> 
    auto operator/(A number, B number2){
        return number / number2;
    }
    template<typename A, typename B> 
    auto operator-(A number , B number2){
        return number - number2;
    }
}

#endif
