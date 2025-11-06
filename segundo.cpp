#include <iostream>
#include "math_library.hpp"
using namespace std;
using namespace math_library;

int main() {
    double a, b;
    cout << "Digite dois números: ";
    cin >> a >> b;

    cout << "Soma: " << a + b << endl;
    cout << "Subtração: " << a - b << endl;
    cout << "Multiplicação: " << a * b << endl;
    cout << "Divisão: " << a / b << endl;

    cout << "Área do círculo (raio=5): " << areaCirculo(5) << endl;
    cout << "Fatorial de 5: " << fatorial(5) << endl;

    return 0;
}


