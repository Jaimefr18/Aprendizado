#include <iostream>

class Livro{
public:
    std::string titulo;
    std::string autor;
    int paginas;
    int paginasLidas;
    void exibirInformacoes(){
        std::cout <<" O livro " <<titulo << " do autor "<< autor << " tem " << paginas << std::endl;
    } 
    void lerPaginas(int numeroPaginas){
        paginasLidas = paginas;
        paginasLidas = paginas;
        std::cout << "Já leste "<<paginasLidas <<" páginas"<<  std::endl;
        std::cout << "Progresso " << (paginasLidas/paginas)*100 <<"%"<< std:: endl;
        if(paginasLidas > paginas){
            std::cout << "Concluído" << std::endl;
        }
    }
    
};

int main(){
    Livro livro1;
    livro1.titulo = "Rich Dad, Poor Dad";
    livro1.autor = " Robert Kyosaki";
    livro1.paginas = 239;
    livro1.exibirInformacoes();
    livro1.lerPaginas(200);
    return 0;
}
