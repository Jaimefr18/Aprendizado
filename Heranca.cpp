#include <iostream>
using namespace std;

class Pessoa{
    public:
        string nome;
    private:
        int nif;
    protected:
        int idade;
    public:void AlterarCpf(string n, int nF, int i){
        nome = n;
        nif = nF;
        idade = i ;
        cout << "Dados alterados e guardados com sucesso" << endl;
    }
    public:void mostrar(){
        cout << "Nome: "<< nome << endl << " NIF: " << nif << endl << " Idade: " << idade << endl;
    }
};
class Aluno : public Pessoa{
    public:void curso(){
        cout << "Atualmente cursando em engenharia" << endl;
    }
    public:void AumentarIdade(){
        int novaIdade = idade + 1;
        cout << "A nova idade é: " << novaIdade << endl;
    }
};

int main(){
    Aluno aluno;
    aluno.AlterarCpf("jaime", 203557, 18);
    aluno.AumentarIdade();
    aluno.curso();
    aluno.mostrar();
    return 0;
}