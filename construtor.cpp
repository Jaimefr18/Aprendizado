#include <iostream> 
using namespace std;
class Aluno {
    private :
        string nome;
        int nota1, nota2;
    public :
        Aluno(string n,int  n1,int  n2){
            nome = n;
            nota1 = n1;
            nota2 = n2;
            cout << "Aluno criado" << nome << endl;
        }
        ~Aluno(){
            cout << "Aluno destruído" << nome << endl;
        }
        void calcularMedia(){
            cout << "A média do " << nome << "é" << (nota1+nota2)/2 << endl;
        }
};
int main(){
    Aluno aluno1("Jaime Francisco", 20, 16);
    aluno1.calcularMedia();
    return 0;
}
