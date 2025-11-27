#include <iostream>
#include <list>
#include <string>
#include <limits>

using namespace std;

void listar(const list<string>& tarefa) {
    if (tarefa.empty()) {
        cout << "Lista vazia.\n";
        return;
    }

    cout << "\n=== Lista de Tarefas ===\n";
    for (const auto& n : tarefa) {
        cout << "- " << n << endl;
    }
}

void inicio(list<string>& tarefa) {
    cin.ignore(numeric_limits<streamsize>::max(), '\n');

    cout << "Digite a tarefa para adicionar no início: ";
    string item;
    getline(cin, item);

    tarefa.push_front(item);
    cout << "Tarefa adicionada!\n";
}

void fim(list<string>& tarefa) {
    cin.ignore(numeric_limits<streamsize>::max(), '\n');

    cout << "Digite a tarefa para adicionar no fim: ";
    string item;
    getline(cin, item);

    tarefa.push_back(item);
    cout << "Tarefa adicionada!\n";
}

void inserir(list<string>& tarefa) {
    if (tarefa.empty()) {
        cout << "Lista vazia.\n";
        return;
    }

    cin.ignore(numeric_limits<streamsize>::max(), '\n');

    cout << "Digite o nome da tarefa após a qual deseja inserir: ";
    string procurar;
    getline(cin, procurar);

    cout << "Digite a nova tarefa: ";
    string nova;
    getline(cin, nova);

    bool encontrado = false;

    for (auto it = tarefa.begin(); it != tarefa.end(); ++it) {
        if (*it == procurar) {
            ++it;                      // move para a posição depois do procurado
            tarefa.insert(it, nova);   // insere aqui
            encontrado = true;
            cout << "Tarefa inserida com sucesso!\n";
            break;
        }
    }

    if (!encontrado) {
        cout << "Tarefa não encontrada!\n";
    }
}

void remover(list<string>& tarefa) {
    if (tarefa.empty()) {
        cout << "Lista vazia.\n";
        return;
    }

    cin.ignore(numeric_limits<streamsize>::max(), '\n');

    cout << "Digite a tarefa que deseja remover: ";
    string target;
    getline(cin, target);

    tarefa.remove(target);
    cout << "Tarefa removida (se existia).\n";
}

int main() {
    list<string> valor;
    bool loop = true;

    while (loop) {
        cout << "\n===== MENU =====\n";
        cout << "1. Inserir tarefa no início\n";
        cout << "2. Inserir tarefa no fim\n";
        cout << "3. Inserir após uma tarefa\n";
        cout << "4. Remover tarefa\n";
        cout << "5. Listar tarefas\n";
        cout << "6. Sair\n";

        int escolha;
        cin >> escolha;

        switch (escolha) {
            case 1: inicio(valor); break;
            case 2: fim(valor); break;
            case 3: inserir(valor); break;
            case 4: remover(valor); break;
            case 5: listar(valor); break;
            case 6: loop = false; cout << "Saindo...\n"; break;
            default: cout << "Opção inválida!\n";
        }
    }

    return 0;
}
