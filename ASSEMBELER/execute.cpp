#include "assembeler.cpp"
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

int main(int argc, char *argv[])
{
    openFile("Input.txt");
    cout << "file open and parsed..." << endl;
    compareTokens();
    cout << "Tokens Compared..." << endl;
    //for testing //
        //printSymbols();
        //cout << "Symbols Printed..." << endl;
    printFile();
    cout << "Assembled file created..." << endl;
    //getch();
    return 0;
}
