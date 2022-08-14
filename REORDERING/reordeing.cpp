//this program detect Dependency between instructions in complex processor and try add NOP or reorder it ... (c/c++)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <vector>

#define MAX 20  //max num of instr
#define NOP 00000000000000000000000000000000

using namespace std;

vector<string> Dependencies(0); //store all raw dep
vector<int> branch_num(0); //store number of bne instructions


struct st  // struct to store part of instructions
{
int op ;  //number of instr
char in_op[10];  // type of operation 
char label[5]; 
char opd[3][10]; //operands of instr
}s[MAX]; 

int I=0;	

//prototype of functions 					
void split(char temp[]);
void data_dep(void);
void name_dep(void);
void control_dep(void);

FILE *wp;
int main(void)
{
	char temp[40];

	//Opening file
	FILE *fp;
	fp=fopen("Input.txt","r");
	wp=fopen("output.txt","w");
	if(fp==NULL)
		{cerr<<"-->  error in Opening instructions file !!";return 0;} //error handling 


	while(!feof(fp)) //read inputed file and split it 
	{
		fgets(temp,40,fp);
		if(!strncmp(temp,"\n",1))
		{continue;}

		split(temp);

		I++;
	}
	
    control_dep();
	
	data_dep();
	
	name_dep();

	fclose(fp);
	fclose(wp);

cout<<"\n \n ";

for (auto str : Dependencies) 
	   {
	       cout<<" --> load use data hazard candidates : "<<str<<endl;
	   }
	   
	for(int i=0;i<I-1;i++)
	{
	for(int j=i+1;j<I;j++)
	{
	for (auto & str : Dependencies)
	   {
	       	if((strcmp(s[stoi(str.substr(0,str.find("&")))-1].in_op,"LC")==0) && str.size() != 0 )   //Search to find dependencies between two consecutive instructions and first instr must be LC 
            cout <<  "\n --> load used data Dependency found at "<< str.substr(0,str.find("&")) << "  instruction and To consider forwarder we must add NOP after this instruction ! " <<endl; // print result 
          str.erase (str.begin()+1);    //delete printd record
	   }
	   
	}
	}
	
	cout<<"\n The analysis was successful  ! " <<endl;
	
	 
	 	
	return 0;
}

int branch_search (int num) // searching at global vector to find for a branch instr
{
    int flag=-1;
   	for (auto & i : branch_num)
   	{
       if (num == i) 
       flag=1;
   	}
    return flag;
}

void split(char temp[]) // splitting and tokenizing instr to its parts
{
	int flag=1;

	char *store;
	int len=strlen(temp);

	for(int i=0;i<len;i++)
	{
		if(temp[i]==':')
		{flag--;}
	}
	s[I].op=0;
	cout<<" " <<I+1<<"   instruction -->\n\t";
	fprintf(wp,"-%d instruction--\n\t\t\t",I+1);
		store=strtok(temp,": ,   	 \n");
		do
		{
		cout<<store<<" ";
			fprintf(wp,"%s ",store);
			switch(flag)
				{
				case 0:
					strcpy(s[I].label,store);
					break;
				case 1:
					strcpy(s[I].in_op,store);
					break;
				case 2:
					strcpy(s[I].opd[0],store);
					s[I].op++;
					break;
				case 3:
					strcpy(s[I].opd[1],store);
					s[I].op++;
					break;
				case 4:
					strcpy(s[I].opd[2],store);
					s[I].op++;
					break;
				}
			flag++;
		}
		while(store=strtok(NULL,": ,   	 \n"));
		cout<<"\n";
		fprintf(wp,"\n");

return;
}



void data_dep(void) // finding and print all data dependencies (type read after write)
{
cout<<"\n\t1. Data Dependency(RAW)---------------\n";
	fprintf(wp,"\n\n1. Data Dependency(RAW)------------------------------------------------\n");
	for(int i=0;i<I-1;i++)
	{
		//Checking for data dependent operands
		for(int j=i+1;j<I;j++)
		{
			if((strcmp(s[i].opd[0],s[j].opd[1])==0||strcmp(s[i].opd[0],s[j].opd[2])==0) && branch_search(i) == -1 )
			{
			if(s[i].op!=0)
			cout<<"Exists between instruction "<< i+1 <<" and "<<j+1 <<" because of register " << s[i].opd[0] << endl;
			fprintf(wp,"Exists between instruction %d and %d because of register -%s- \n",i+1,j+1,s[i].opd[0]);
			if ((j+1) - (i+1)== 1 ) {Dependencies.push_back(to_string(i+1)+"&"+to_string(j+1)) ;}

			    
			}
		}
	}

}



void name_dep(void)  //finding and print all data dependencies (type {write after read} and {write after write} )
{

	fprintf(wp,"\n\n2. Name Dependency--------------------------------------------------------\n");
	cout<<"\n\t2a. Anti-Dependency(WAR)---------------\n";
	fprintf(wp,"\n\t2a. Anti-Dependency(WAR)---------------\n");
	for(int i=0;i<I-1;i++)
	{
		for(int j=i+1;j<I;j++)
		{
			if((strcmp(s[i].opd[1],s[j].opd[0])==0||strcmp(s[i].opd[2],s[j].opd[0])==0 )&& branch_search(i) == -1)
			{
				if(s[j].op!=0)
cout<<"Exists between instruction "<< i+1 <<" and "<<j+1 <<" because of register " << s[j].opd[0] << endl;				
fprintf(wp,"Exists between instruction %d and %d because of register -%s- \n",i+1,j+1,s[j].opd[0]);
			}
		}
	}

cout<<"\n\t2b. Output Dependency(WAW)---------------\n";
	fprintf(wp,"\n\t2b. Output Dependency(WAW)---------------\n");
		for(int i=0;i<I-1;i++)
		{
			for(int j=i+1;j<I;j++)
			{
				if(strcmp(s[i].opd[0],s[j].opd[0])==0 && branch_search(i) == -1)
				{
				if(s[j].op!=0)
cout<<"Exists between instruction "<< i+1 <<" and "<<j+1 <<" because of register " << s[j].opd[0] << endl;				fprintf(wp,"Exists between instruction %d and %d because of register -%s- \n",i+1,j+1,s[j].opd[0]);
				}
			}
		}

}



void control_dep(void) //finding and print all control dependencies related to bne instruction 
{
	cout<<"\n3. Control Dependencey-------\n";
	fprintf(wp,"\n\n3. Control Dependence-------------------------------------------------------\n");
	for(int i=0,branch=0,loop=0;i<I;i++)
	{
		int min,max=0;
		//Checking for branch instruction 
		if(strcmp(s[i].in_op,"BNE")==0)	
		{
           branch_num.push_back(i);
			branch=i;
			int x=s[branch].op-1;
				//Checking for the destination of branch
				for(int j=0;j<I;j++)
				{
					if(strcmp(s[j].label, s[branch].opd[x])==0)
					{
					loop=j;
					min= branch<loop?branch:loop;
					max= branch>loop?branch:loop;
					}
				}

				if(max!=0 && min!=0)
				{
			cout<<"Exists for branch--> "<< s[branch].opd[x] <<  "  and the instructions that are dependent are : \n";
				fprintf(wp,"\nExists for branch--> %s \n The instructions that are dependent are from Instruction no  : %d -> %d\n ",s[branch].opd[x],min,max);
				fprintf(wp,"DependentInstructions is/are:\n");
				for(;min<max;min++)
					{

						if(strcmp(s[branch].in_op,s[min].in_op))
						{printf("%s\n",s[min].in_op);
						fprintf(wp,"%s\n",s[min].in_op);}
					}
				}


		}

	}

}