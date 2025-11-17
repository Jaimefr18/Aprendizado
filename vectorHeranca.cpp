#include <iostream>
#include <vector>
using namespace std;

class Animal{
    public:
        virtual void Falar(){
            cout << "O animal emitiu um som" << endl;
        }
};
class Cachorro : public Animal{
    public:
        void Falar() override {
            cout << "Auuuuuu" << endl;
    }
};
class Gato : public Animal{
    public:
        void Falar()override{
           cout << "Miauuuuu" << endl; 
        }
};

int main(){
    vector <Animal*>animal;
    animal.push_back(new Cachorro());
    animal.push_back(new Gato());
    for(Animal* a : animal){
        a->Falar();
    }
    for(Animal* a : animal){
        delete a;
    }
    return 0;
}
