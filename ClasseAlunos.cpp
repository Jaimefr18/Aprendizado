#include <iostream>
using namespace std;

class Aluno{
private:
    int nota1, nota2;
public:
    string nome;

int calcularMedia(int primeiraNota, int segundaNota){
    int resultado;
    nota1 = primeiraNota;
    nota2 = segundaNota;
    resultado = (nota1 + nota2)/2;
    return resultado;
    
}    
    
};

int main(){
    Aluno aluno1;
    aluno1.nome = "Jaime Francisco";
    int resultado = aluno1.calcularMedia(100,200);
    cout << "A média do " << aluno1.nome << " é " << resultado << endl;
    
    return 0;
}
