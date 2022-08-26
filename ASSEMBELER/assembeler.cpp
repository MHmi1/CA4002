#include <iostream>
#include <iomanip>
#include <fstream>
#include <algorithm>
#include <bitset>
#include <string>
#include <vector>

#define NOP "00000000000000000000000000000000" // 32 of "0"
using namespace std;

/* This struct is helpful for tying labels to their address for branch and jump instructions */
struct Labels
{
  string name;
  int address;
};

vector<Labels> label; //Vector of struct labels

int numberOfInstructions = 0; //hold number Of Instructions in input file
bool ERROR = false; //a flag to know we have error or not
int tokenSize = 0; //The size of the tokenized original assembly file.
char token; //token holder.
vector<char> tokens; //Vector of tokens taken from the original file.
vector<string> symbols; //Vector of symbols.


/* Converts decimal values (int) to string */
string dec2bin(int value)
{
    stringstream ht;
    ht << value;

    stringstream bt;
    bt << ht.str();

    unsigned n;
    bt >> n;
    bitset<16> b(n);

    return b.to_string();
}


/* Converts a string letters to lower case */
string lowerCase(string input)
{
    transform(input.begin(), input.end(), input.begin(), ::tolower);
    return input;
}


/* Opens the file and reads it, creates a table of tokens (no spaces) */
void openFile(char *filename)
{
    ifstream file;
    file.open(filename);

    if(!file.is_open()) //If the file does not exist the program crashes.
    {
        cout << "FILE DOES NOT EXIST/FAILED TO OPEN FILE!" << endl;
        exit(EXIT_FAILURE);
    }

    else
    {
        int i = 0;
        char temp;

        while (!file.eof())
        {
            file.get(temp);
            tokens.push_back(temp);
            i++;
            tokenSize++;
        }
        i = 0;
        tokenSize--;
    }
}


/*The cal_offset function calculates offsets for I-type Instructions (bne,lc,sc)*/
string cal_offset(string temp_symbol)
{
    int long long offset;
    string off;

    offset = stoi(temp_symbol);
    off = dec2bin(offset);

    return off;  
}


/* The immdiateTable function handles the immediate values of instructions (sc,lc) */
string immediateTable(int &symbolCounter)
{
    string off;

    symbolCounter++; //Increment counter to the immediate value symbol.
    string temp_symbol = symbols[symbolCounter]; //Store the value symbol in a temporary variable.
    off = cal_offset(temp_symbol); //calculating offset to return it
    return off; //We return the address in binary form to be added to the rest of the sc,lc instructions.
}


/* The branchTable function handles the branch address for branch instructions. */
string branchTable(int &symbolCounter, string &temp, int &labelsCounter, int &lineCounter)
{
    long long int offset = 0;
    string off;

    symbolCounter++; //Increment counter to the branch address symbol or offset.
    string temp_symbol = symbols[symbolCounter]; //Store the branch address symbol in a temporary variable.
    
    bool flag1 = true; //true means offset is a number 
    bool flag2 = false; //true means offset is a label
    
    int ts_size = temp_symbol.size(); //size of value symbol (offset)

    //this loop determines that offset is a number or not , default we consider offset is a number and
    //when we find a non-digit in string of offset  we change the flag1 to false 
    for (int p = 0; (p < ts_size) && (flag1 == true); p++)
    {
        if (isdigit(temp_symbol[p]) == false)
        {
            if (p == 0)
            {
                if (temp_symbol[0] == '-' || temp_symbol[0] == '+')
                {
                    break;
                }
                else
                {
                   flag1 = false; 
                }
                
            }
            else
            {
                flag1 = false;
            }
        }
    }

    //if offset be a number
    if (flag1 == true)
    {
        if ( stoi(temp_symbol) > 0 )
        {   
            if( stoi(temp_symbol) > (numberOfInstructions - (lineCounter+1) ))
            {
                cerr << "!!ERROR:\"The offset of 'bne' in line '"<< (lineCounter)+1 << "'(instructions) is invalid\"" << endl;
                cout << "!!!!Previous instructions are done!!!!" << endl;
                ERROR = true;
            }
        }
        else if ( stoi(temp_symbol) < 0 )
        {
            if ( (stoi(temp_symbol) * -1) > (lineCounter+1) )
            {
                cerr << "!!ERROR:\"The offset of 'bne' in line '"<< (lineCounter)+1 << "'(instructions) is invalid\"!!" << endl;
                cout << "!!!!Previous instructions are done!!!!" << endl;
                ERROR = true;
            }
            
        }

        off = cal_offset(temp_symbol);
    }
    
    //if offset be a label
    for(int i = 0; (i < labelsCounter) && (flag1 == false); i++) //Search the label vector (That we made in pass 1) for the branch label.
    {  
        if (label[i].name == temp_symbol)
        {
            if(label[i].address >  lineCounter)
            {
                offset = (label[i].address - lineCounter) - 1;
            }
            else
            {
                offset = -((lineCounter - label[i].address) + 1);
            }

            flag2 = true;
            //After finding it we turn it into binary form.
            off = dec2bin(offset);
            break;
        }
    }

    //when offset dosen't be a label or number
    if (flag2 == false && flag1 == false)
    {
        cerr << "!!ERROR:\"The offset of 'bne' in line '"<< (lineCounter)+1 << "'(instructions) is invalid\"!!" << endl;
        cout << "!!!!Previous instructions are done!!!!" << endl;
        ERROR = true;
    }
    
    temp = temp + off;

    return temp; //We return the address in binary form to be added to the rest of the branch instruction.
}


/*The registerTable handles register symbols, matching them with the correct registers*/
string registerTable(int &symbolCounter, int &lineCounter)
{
    string temp;
    symbolCounter++; //Increment the counter for 'symbols' vector.
    string temp_symbol = symbols[symbolCounter]; //Stores the register symbol in a temporary variable.
    
        //Assigns appropriate binary representation of each register symbol.
        if(temp_symbol == "$0") temp = "00000";
        else if(temp_symbol == "$1") temp = "00001";
        else if(temp_symbol == "$2") temp = "00010";
        else if(temp_symbol == "$3") temp = "00011";
        else if(temp_symbol == "$4") temp = "00100";
        else if(temp_symbol == "$5") temp = "00101";
        else if(temp_symbol == "$6") temp = "00110";
        else if(temp_symbol == "$7") temp = "00111";
        else if(temp_symbol == "$8") temp = "01000";
        else if(temp_symbol == "$9") temp = "01001";
        else if(temp_symbol == "$10") temp = "01010";
        else if(temp_symbol == "$11") temp = "01011";
        else if(temp_symbol == "$12") temp = "01100";
        else if(temp_symbol == "$13") temp = "01101";
        else if(temp_symbol == "$14") temp = "01110";
        else if(temp_symbol == "$15") temp = "01111";
        else if(temp_symbol == "$16") temp = "10000";
        else if(temp_symbol == "$17") temp = "10001";
        else if(temp_symbol == "$18") temp = "10010";
        else if(temp_symbol == "$19") temp = "10011";
        else if(temp_symbol == "$20") temp = "10100";
        else if(temp_symbol == "$21") temp = "10101";
        else if(temp_symbol == "$22") temp = "10110";
        else if(temp_symbol == "$23") temp = "10111";
        else if(temp_symbol == "$24") temp = "11000";
        else if(temp_symbol == "$25") temp = "11001";
        else if(temp_symbol == "$26") temp = "11010";
        else if(temp_symbol == "$27") temp = "11011";
        else if(temp_symbol == "$28") temp = "11100";
        else if(temp_symbol == "$29") temp = "11101";
        else if(temp_symbol == "$30") temp = "11110";
        else if(temp_symbol == "$31") temp = "11111";
        //when register number be out of range
        else 
        {
            cerr << "!!ERROR:\"Register number in line '"<< (lineCounter)+1 << "'(instructions) is invalid";
            cerr << "...Register number has to be from 0 to 31\"!!" << endl;
            cout << "!!!!Previous instructions are done!!!!" << endl;
            ERROR = true;
        }

        return temp; //We return the register number in binary form to be added to the rest of the instruction.
}


/* The symbolPrint function is the 2nd Pass of the symbol list, we are forming the instruction in binary*/
string symbolPrint(int &symbolCounter, int &labelsCounter, int&lineCounter)
{
        string temp;
        string temp_symbol;
        //Src = source1, Trg = Target (source2), Dst = destination {Registers}. Imm = immediate value amount.
        string Src;
        string Trg;
        string Dst;
        string Imm;

        temp_symbol = symbols[symbolCounter]; //Store the symbol in a temporary symbol variable, it should be an instruction if no syntax errors.

        /*---------------------------------------------------------------------------------------------------------------------------------*/
        /* R-type - for these instructions we concatenate "000000" with the 3 registers (Src,Trg,Dst) and then the function in binary.     */
        /* I-type - for these instructions we concatenate the OpCode in binary with the register required and the 16 bit immediate value.  */
        /*---------------------------------------------------------------------------------------------------------------------------------*/
        
        //R-Type
        if(lowerCase(temp_symbol) == "addc")
        {
            temp = "000000";
            Dst = registerTable(symbolCounter, lineCounter);
            Src = registerTable(symbolCounter, lineCounter);
            Trg = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Dst + "00000110000";
        }
        else if(lowerCase(temp_symbol) == "mulc")
        {
            temp = "000000";
            Dst = registerTable(symbolCounter, lineCounter);
            Src = registerTable(symbolCounter, lineCounter);
            Trg = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Dst + "00000110010";
        }
        else if(lowerCase(temp_symbol) == "divc")
        {
            temp = "000000";
            Dst = registerTable(symbolCounter, lineCounter);
            Src = registerTable(symbolCounter, lineCounter);
            Trg = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Dst + "00000110011";
        }
        else if(lowerCase(temp_symbol) == "subc")
        {
            temp = "000000";
            Dst = registerTable(symbolCounter, lineCounter);
            Src = registerTable(symbolCounter, lineCounter);
            Trg = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Dst + "00000110001";
        }
        else if(lowerCase(temp_symbol) == "negc")
        {
            temp = "000000";
            Dst = registerTable(symbolCounter, lineCounter);
            Src = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + "00000" + Dst + "00000110100";
        }

        //I-Type
        else if(lowerCase(temp_symbol) == "bne")
        {
            temp = "000100";
            Src = registerTable(symbolCounter, lineCounter);
            Trg = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg; // and "+ offset" in branchTable function
            branchTable(symbolCounter, temp, labelsCounter, lineCounter);
        }
        else if(lowerCase(temp_symbol) == "lc")
        {
            temp = "010000";
            Trg = registerTable(symbolCounter, lineCounter);
            Imm = immediateTable(symbolCounter);
            Src = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Imm;
        }
        else if(lowerCase(temp_symbol) == "sc")
        {
            temp = "010001";
            Trg = registerTable(symbolCounter, lineCounter);
            Imm = immediateTable(symbolCounter);
            Src = registerTable(symbolCounter, lineCounter);
            temp = temp + Src + Trg + Imm;
        }
        
        else
        {
            //If a label is encountered we ignore it since we have previously recorded it.
            //However we increment the symbolCounter and we call the symbolPrint function to print the next line in it's place.

            symbolCounter++;
            temp = symbolPrint(symbolCounter, labelsCounter, lineCounter);
            return temp;
        }

    symbolCounter++;
    lineCounter++;
    return temp;
}


/*calculating number of Instructions in input file*/
void cal_numberofInstructions (int &numberOfSymbols, int &symbolsCounter)
{
    string temp_symbol;

    while (numberOfSymbols > symbolsCounter)
    {
        temp_symbol = symbols[symbolsCounter];

        if(lowerCase(temp_symbol) == "addc")      {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "mulc") {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "divc") {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "negc") {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "subc") {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "bne")  {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "lc")   {symbolsCounter += 4; numberOfInstructions++;}
        else if(lowerCase(temp_symbol) == "sc")   {symbolsCounter += 4; numberOfInstructions++;}
        else                                      {symbolsCounter += 1;                        }
    }
    
}


/* The firstPass function runs through the symbol list and records all labels and their addresses */
void firstPass(int &symbolsCounter, int &lineCounter, int &labelsCounter) //This function looks through all symbols to find labels.
{
    string temp_symbol = symbols[symbolsCounter];
    
    if(lowerCase(temp_symbol) == "addc")      {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "mulc") {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "divc") {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "negc") {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "subc") {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "bne")  {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "lc")   {symbolsCounter += 4;}
    else if(lowerCase(temp_symbol) == "sc")   {symbolsCounter += 4;}

    else
    {
        //If a label is found that isn't an instruction is probably is a label and is recorded.
        Labels newLabel; //We create a new Labels object.
        newLabel.name = temp_symbol; //We store the name of the label.
        newLabel.address = lineCounter; //We store the lineCounter (address in decimal).
        label.push_back(newLabel); //Then we push the object into a vector for storage.

        //We do not increment lineCounter because a label is just a placeholder for the next instruction's address not it's own.
        labelsCounter++; //We increment the labels counter keeping track of the size of our vector.
        symbolsCounter++; //We increment symbolsCounter because the label is a symbol in our symbols vector.
    }

    lineCounter++; //We increment the line counter once after each instruction is run through. Except for when a label is found!
}


/* This is the main print function that utilizes all the functions above it to print out the assembled instructions */
void printFile() //This function prints to file.
{

    ofstream oFile;
    oFile.open("instructions.dat");
    //oFile.open("output.txt"); // for testing

    int lineCounter = 0; //The line counter records the line address count.
    int numberOfSymbols = symbols.size()-1; //This is the number of symbols we parsed from the assembly file.
    int symbolCounter = 0; //Whenever we iterate through the symbols vector we want to keep count as to not overflow.
    string instruction; //This string holds the final instruction in binary for printing.
    int labelsCounter = 0; //We keep a count of the labels we find in the symbols vector. 

    cal_numberofInstructions(numberOfSymbols,symbolCounter);
    symbolCounter = 0;//Reset symbolCounter to be used in the first pass

    //1st pass through symbols list to see if there are any labels, to record their addresses.
    for(int i = 0; numberOfSymbols > i;) 
    {
        firstPass(symbolCounter, lineCounter, labelsCounter);
        i = symbolCounter;
    }

    //Reset symbolCounter and lineCounter to be used in the second pass.
    symbolCounter = 0; 
    lineCounter = 0;

    if (numberOfInstructions > 1024)
    {
        cerr << "!!ERROR:\"Maximum Number of Instructions is 1024 (The rest of them are ignored)\"!!" << endl;
        numberOfInstructions = 1024;
    }

    //2nd pass goes through the symbol list and starts concatenating the correct string/instruction.
    for(int i = 0; i < numberOfInstructions; i++) 
    {
        instruction = symbolPrint(symbolCounter, labelsCounter, lineCounter);

        if(ERROR == true)
        {
            break;
        }
        oFile << instruction << endl;
    }
  
    oFile.close();
}


/* This is a function used for tests only use if you need to see the way the symbols were parsed */
void printSymbols()
{
    for(int i = 0; i < symbols.size()-1; i++)
    {
        cout << "i " << i << " symbol " << symbols[i] << endl;
    }
}


/* Checks for identifiers (lowercase symbols, ex: addc, lc) */
void identifiers(char &value, int &i)
{
    string temp;

    while(islower(value) || isupper(token))
    {
        if(i == tokenSize)
        {
            break;
        }

        temp += value;
        i++;
        value = tokens[i];
    }

    symbols.push_back(temp);
}


/* Checks for registers, knows if a register is being parsed a '$' symbol is encountered then records the number */
void registers(char &value, int &i)
{
    string temp;
    temp += value;
    i++;
    value = tokens[i];

    while(isdigit(value))
    {
        if(i == tokenSize)
        {
            break;
        }

        temp += value;
        i++;
        value = tokens[i];
    }

    symbols.push_back(temp);
}


/* Checks for digits, digits are usually addressees or offsets, it disguishes between the two and records appropriate symbols */
void digits(char &value, int &i)
{
    string temp;

    if(value == '-')
    {
        temp = value;
        i = i + 1;
    }
    
    value = tokens[i];

    while(isdigit(value) || islower(value) || isupper(token) )
    {
        if(i == tokenSize)
        {
            break;
        }

        temp += value;
        i++;
        value = tokens[i];
    }

    symbols.push_back(temp);

}


/* This function generates the symbol vector using the functions above it to distinguish between symbols */
void compareTokens() //This function turns all tokens into symbols.
{

    for(int i = 0; i < tokenSize; i++)
    {
            token = tokens[i];

            if(islower(token) || isupper(token))
            {
                identifiers(token, i);
            }
            if(token == '$')
            {
                registers(token, i);
            }
            if(isdigit(token) || token == '-')
            {
                digits(token, i);
            }

    }
}
