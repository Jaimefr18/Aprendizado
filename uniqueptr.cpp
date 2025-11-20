#include <iostream>
#include <vector>
#include <memory>
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
            return mensalidade/2;
        }
};
class AlunoPremium  : public IMensalidade{
    public:
        double calcularPagamento(double mensalidade) override{
            return mensalidade + mensalidade*0.2 ;
        }
};

int main(){
    vector<unique_ptr<IMensalidade>>alunos;
    alunos.push_back(make_unique<AlunoNormal>());
    alunos.push_back(make_unique<AlunoBolseiro>());
    alunos.push_back(make_unique<AlunoPremium>());
    double mensalidade = 30000;
    for(const auto& aluno : alunos){
        cout << "Mensalidade "<< aluno->calcularPagamento(mensalidade)<<endl;
    }
    return 0;
}
