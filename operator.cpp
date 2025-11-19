#include <iostream>
using namespace std;
class Soma{
    public:
        int valor;
        Soma(int v) : valor(v){}
        
        Soma operator+(const Soma& numero){
            return Soma(this->valor + numero.valor);     
        }
        
};
ostream& operator<<(ostream& out, const Soma& s){
    out << s.valor;
    return out;
}
int main(){
    Soma a(10);
    Soma b(20);
    Soma c = a + b;
    cout << "A soma é: " <<  c << endl;
    return 0;
}
