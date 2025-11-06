#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>
#include <string>
using namespace std;

void Adicionar(string &nome, double &nota);

void Atualizar(string &nome, double &nota);

void Listar(string &nome, double &nota);

void Apagar(string &nome, double &nota);

int main(){
    bool isplaying = true;
    int opcao;
    string nome;
    double nota;
    while(isplaying){
        cout << "Bem vindo ao sistema de gestão de alunos" << endl;
        cout << "Selecione uma das opções abaixo:\n[1]Adicionar\n[2]Atualizar\n[3]Listar\n[4]Apagar\n[5]Sair\n" << endl;
        cin >> opcao;
        cin.ignore();
        switch(opcao){
            case 1:
            Adicionar(nome, nota); break;
            case 2: 
            Atualizar(nome, nota); break;
            case 3:
            Listar(nome, nota); break;
            case 4:
            Apagar(nome, nota); break;
            case 5:
            cout << "Saindo..." << endl;
            isplaying = false; break;
            default:
            cout << "Opção inválida tente novamente" << endl; break;

        }
    }
    return 0;
}

void Adicionar(string &nome, double &nota){
    ofstream Arquivo("listaAlunos.txt", ios::app);
    if(!Arquivo){
        cout << "Não foi possível abrir o arquivo, tente novamente" << endl;
    }
    cout << "Nome do aluno(a):\n";
    getline(cin, nome);
    cout << "Nota do aluno(a)\n";
    cin >> nota;
    cin.ignore();
    Arquivo << nome << " " << nota << endl; 
    Arquivo.close();
}

void Atualizar(string &nome, double &nota){
    ifstream Arquivo("listaAlunos.txt");
    if(!Arquivo){
        cout << "Falha ao abrir o arquivo" << endl;
    }

   vector <string>linhas;
   string linha, procurar;
   cout << "Pesquisar" << endl;
   getline(cin, procurar);
   while(getline(Arquivo, linha)){
    linhas.push_back(linha);
   }
   for (int i = 0; i < linhas.size(); i++){
    if(linhas[i].find(procurar) != string :: npos){
        stringstream ss(linhas[i]);
        ss >> nome >> nota;
        cout << "Nova nota" << endl;
        cin >> nota;
        cin.ignore();
        linhas[i] = nome + " " + to_string(nota);
    }
   }
   ofstream ArquivoSaida("listaAlunos.txt");
   for(int i = 0; i < linhas.size(); i++){
    ArquivoSaida << linhas[i] << endl;
   }
   Arquivo.close();
}

void Listar(string &nome, double &nota){
    ifstream ArquivoSaida("listaAlunos.txt");
    if(!ArquivoSaida){
        cout << "Erro ao abrir o arquivo" << endl;
    }
    string linha;
    while(getline(ArquivoSaida, linha)){
        stringstream ss(linha);
        ss >> nome >> nota;
        cout << "Nome: " << nome << " Nota: " << nota << endl;
    }
    ArquivoSaida.close();
}

void Apagar(string &nome, double &nota){
    ifstream Arquivo("listaAlunos.txt");
    vector <string> linhas;
    string linha, nomeAluno;
    cout << "Digite o nome do aluno que deseja eliminar" << endl;
    getline(cin , nomeAluno);

    while(getline(Arquivo, linha)){
        linhas.push_back(linha);
    }
    for(int i = linhas.size()-1 ; i>=0 ; i--){
        if(linhas[i].find(nomeAluno) != string::npos){
            linhas.erase(linhas.begin() + i);
        }
    }
    ofstream ArquivoSaida("listaAlunos.txt");
    for(string mostrar : linhas){
        ArquivoSaida << mostrar << endl;
    }
    ArquivoSaida.close();
}