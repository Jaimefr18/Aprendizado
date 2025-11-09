#include <iostream> 
using namespace std;
class Produto{
    private :
        int quantidade;
    public :
        string nome;
        double preco;
    double valorTotalEstoque(int q, double p){
        preco = p;
        quantidade = q;
         return static_cast<double>(quantidade * preco);
    }
};

int main(){
    Produto produto1;
    produto1.nome = "Coca-cola";
    double resultado = produto1.valorTotalEstoque(150, 500);
    cout << "O valor total de estoque é " << resultado << endl;
    return 0;
}
