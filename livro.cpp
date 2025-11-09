#include <iostream> 
using namespace std;
class Livro{
    private:
        string titulo;
        string autor;
        int paginas;
        int paginasLidas;
    public:
    Livro (string t, string a, int p, int pL){
        titulo = t;
        autor = a;
        paginas = p;
        paginasLidas = pL;
        cout << "Livro criado " << titulo << endl;
    }
    ~Livro(){
        cout << "Objeto destruído " << titulo << endl;
    }
        void lerPaginas(){
            cout << "Atualmente em: " << paginasLidas << endl;
            if(paginasLidas > paginas){
                paginasLidas = paginas;
            }
        }
        void getProgresso(){
            cout << "Progresso: " << static_cast<int>((paginasLidas / paginas)*100) << "%" << endl;
        }
        void exibirInformacoes(){
            cout << "Título: " << titulo << endl;
            cout << "Autor: " << autor << endl;
            cout << "Número de Páginas: " << paginas << endl;
            lerPaginas();
            getProgresso();
        }
        
};
int main(){
    Livro livro1("Rich Dad, Poor Dad", "Robert Kyosaki", 239, 200);
    livro1.exibirInformacoes();   
    return 0;
}
