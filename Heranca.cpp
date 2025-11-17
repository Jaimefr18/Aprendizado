#include <iostream>
using namespace std;

class Veiculo{
    public:virtual void mover(){
        cout << "Veículo em movimento" << endl;
    }
};
class Carro : public Veiculo{
    public:void mover() override{
        cout << "O carro está dirigindo" << endl;
    }
};
class Bicicleta : public Veiculo{
    public:void mover() override{
        cout << " A bicicleta está pedalando" << endl;
    }
};

int main(){
    Veiculo* veiculo1 = new Carro();
    Veiculo* veiculo2 = new Bicicleta();
    veiculo1->mover();
    veiculo2->mover();
    
    return 0;
}