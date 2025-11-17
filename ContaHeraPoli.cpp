#include <iostream>
#include <vector>
using namespace std;

class ContaBancaria {
protected:
    double saldo;

public:
    int numero;

    ContaBancaria(double s = 0.0) : saldo(s) {}

    virtual double sacar(double valor) {
        if(valor <= saldo){
            saldo -= valor;
            return saldo;
        }
        return -1; // saldo insuficiente
    }

    double getSaldo() { return saldo; }
};

class ContaPoupanca : public ContaBancaria {
public:
    ContaPoupanca(double s = 0.0) : ContaBancaria(s) {}

    double sacar(double valor) override {
        if(valor > 200000.0) {
            return -1; // limite de saque
        }
        if(valor <= saldo){
            saldo -= valor;
            return saldo;
        }
        return -1;
    }
};

class ContaEspecial : public ContaBancaria {
public:
    ContaEspecial(double s = 0.0) : ContaBancaria(s) {}

    double sacar(double valor) override {
        if(saldo - valor >= -10000.0) { // saldo permitido até -10000
            saldo -= valor;
            return saldo;
        }
        return -1; // limite excedido
    }
};

int main() {
    vector<ContaBancaria*> contas;

    contas.push_back(new ContaPoupanca(500000)); // saldo inicial
    contas.push_back(new ContaEspecial(1000));   // saldo inicial

    for(ContaBancaria* c : contas) {
        double resultado = c->sacar(12000);
        if(resultado == -1){
            cout << "Saque não permitido" << endl;
        } else {
            cout << "Saque efetuado, novo saldo: " << resultado << endl;
        }
    }

    // liberar memória
    for(ContaBancaria* c : contas){
        delete c;
    }

    return 0;
}
