#include <iostream>
#include <vector>
#include <limits>
using namespace std;

void adicionarValor(vector<int>& valor) {
    int numero;
    cout << "\n========= Adicionar Valor =========\n";
    cout << "Adicione um valor: ";
    cin >> numero;
    valor.push_back(numero);
    cout << "Adicionado com sucesso!\n";
}

void listarValor(const vector<int>& valor) {
    cout << "\n========= Listar Valores =========\n";
    if (valor.empty()) {
        cout << "O vector está vazio!\n";
        return;
    }

    for (auto n : valor) {
        cout << n << endl;
    }
}

void maiorMenor(const vector<int>& valor) {
    cout << "\n========= Maior e Menor =========\n";
    if (valor.empty()) {
        cout << "O vector está vazio!\n";
        return;
    }

    int maior = valor[0];
    int menor = valor[0];

    for (auto n : valor) {
        if (n > maior) maior = n;
        if (n < menor) menor = n;
    }

    cout << "Maior valor: " << maior << endl;
    cout << "Menor valor: " << menor << endl;
}

void procurarValor(const vector<int>& valor) {
    cout << "\n========= Procurar Valor =========\n";
    if (valor.empty()) {
        cout << "O vector está vazio!\n";
        return;
    }

    cout << "Digite o valor que deseja procurar: ";
    int alvo;
    cin >> alvo;

    bool encontrado = false;

    for (size_t i = 0; i < valor.size(); i++) {
        if (valor[i] == alvo) {
            cout << "Valor encontrado na posição " << i << endl;
            encontrado = true;
        }
    }

    if (!encontrado)
        cout << "Valor não encontrado!\n";
}

double media(const vector<int>& valor) {
    if (valor.empty()) return 0;

    int soma = 0;
    for (auto n : valor)
        soma += n;

    return static_cast<double>(soma) / valor.size();
}

int main() {
    vector<int> valor;
    bool loop = true;

    while (loop) {
        cout << "\n===== MENU =====\n";
        cout << "1. Adicionar valor\n";
        cout << "2. Listar valores\n";
        cout << "3. Maior e menor\n";
        cout << "4. Procurar valor\n";
        cout << "5. Média\n";
        cout << "6. Sair\n";
        cout << "Escolha: ";

        int escolha;
        cin >> escolha;

        switch (escolha) {
            case 1: adicionarValor(valor); break;
            case 2: listarValor(valor); break;
            case 3: maiorMenor(valor); break;
            case 4: procurarValor(valor); break;
            case 5: 
                cout << "\n========= Média =========\n";
                cout << "Média: " << media(valor) << endl;
                break;
            case 6: 
                loop = false; 
                cout << "Saindo...\n";
                break;
            default:
                cout << "Opção inválida!\n";
                break;
        }
    }

    return 0;
}
