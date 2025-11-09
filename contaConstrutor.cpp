#include <iostream>
using namespace std;

class ContaBancaria{
    private:
        double saldo;
        bool ativada = true;
    public:
        string nome;
        ContaBancaria(string n, double sl, bool active){
            nome = n;
            saldo = sl;
            ativada = active;
            cout << "Conta criada " << nome << endl;
        }
        ~ContaBancaria(){
            cout << "Conta destruída " << nome << endl;
        }
        void Depositar(int deposito){
            if(ativada){
                if(deposito >= 0){
                    saldo += deposito;
                    cout << "Depósito de " << deposito << " feito com sucesso" << endl;
                    cout << "Saldo actual: " << saldo << endl;
                }else{
                    cout << "Depósito não pode ser negativo" << endl;
                }
            }else{
                cout << "Conta bloqueada" << endl;
            }
        }
        void Sacar(int sacar){
            if(ativada){
                getSaldo();
                if(sacar < saldo){
                    saldo-=sacar;
                    cout << "Saque de "<< sacar <<" realizado com sucesso" << endl;
                    getSaldo();
                }
            }
        }
        void getSaldo(){
            cout << "Disponível: " << saldo << endl;
        }
};

int main(){
    ContaBancaria conta1("Jaime Francisco", 10000.00, true);
    conta1.Depositar(50000);
    conta1.Sacar(20000);
    conta1.getSaldo();
    return 0;
}
