#include <iostream>
#include <deque>
#include <string>
#include <limits>
using namespace std;

void normal(deque<string>& comando) {
    cin.ignore(numeric_limits<streamsize>::max(), '\n');  // limpar buffer

    cout << "\n=========== Adicionar comando normal ===============\n";
    cout << "Digite o comando: ";

    string adicionar;
    getline(cin, adicionar);

    comando.push_back(adicionar);
    cout << "Comando adicionado com sucesso!\n";
}

void prioritario(deque<string>& comando) {
    cin.ignore(numeric_limits<streamsize>::max(), '\n');  // limpar buffer

    cout << "\n=========== Adicionar comando prioritário ===============\n";
    cout << "Digite o comando prioritário: ";

    string adicionar;
    getline(cin, adicionar);

    comando.push_front(adicionar);
    cout << "Comando prioritário adicionado!\n";
}

void proximo(deque<string>& comando) {
    cout << "\n=========== Executar próximo comando ===============\n";

    if (comando.empty()) {
        cout << "Nenhum comando para executar.\n";
        return;
    }

    cout << "Executando: " << comando.front() << endl;
    comando.pop_front();
}

void listar(const deque<string>& comando) {
    cout << "\n=========== Comandos na fila ===============\n";

    if (comando.empty()) {
        cout << "Nenhum comando na fila.\n";
        return;
    }

    for (const auto& c : comando) {
        cout << "- " << c << endl;
    }
}

int main() {
    deque<string> comando;
    bool loop = true;
    int escolha;

    while (loop) {
        cout << "\n=========== MENU ===============\n";
        cout << "1. Adicionar comando normal\n";
        cout << "2. Adicionar comando prioritário\n";
        cout << "3. Executar próximo comando\n";
        cout << "4. Ver comandos na fila\n";
        cout << "5. Sair\n";
        cout << "Escolha: ";

        cin >> escolha;

        switch (escolha) {
            case 1: normal(comando); break;
            case 2: prioritario(comando); break;
            case 3: proximo(comando); break;
            case 4: listar(comando); break;
            case 5:
                loop = false;
                cout << "Saindo...\n";
                break;
            default:
                cout << "Opção inválida!\n";
        }
    }

    return 0;
}
