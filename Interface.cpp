#include <iostream>
#include <vector>
using namespace std;

class IMensalidade {
    public:
        virtual double calcularPagamento(double mensalidade) = 0;
        virtual ~IMensalidade() = 0;
};
IMensalidade::~IMensalidade(){}
class AlunoNormal : public IMensalidade{
    public:
        double calcularPagamento(double mensalidade) override{
            return mensalidade;
        }
};
class AlunoBolseiro : public IMensalidade{
    public:
        double calcularPagamento(double mensalidade) override{
            return mensalidade/=2;
        }
};
class AlunoPremium  : public IMensalidade{
    public:
        double calcularPagamento(double mensalidade) override{
            return mensalidade += mensalidade*0.2 ;
        }
};

int main(){
    vector<IMensalidade*>alunos;
    alunos.push_back(new AlunoNormal());
    alunos.push_back(new AlunoBolseiro());
    alunos.push_back(new AlunoPremium());
    double mensalidade = 30000;
    for(IMensalidade* aluno : alunos){
        cout << "Mensalidade "<< aluno->calcularPagamento(mensalidade)<<endl;
    }
    for(IMensalidade* aluno : alunos){
        delete aluno;
    }
    return 0;
}
