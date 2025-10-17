// Test file for formatting demo
#include <iostream>
#include <vector>

class   TestClass{
public:
void badly_formatted_function(   int param1,int param2   )
{
std::cout<<"This is poorly formatted"<<std::endl;
}

private:
std::vector<int>data;
};

int main(){
TestClass obj;
obj.badly_formatted_function(1,2);
return 0;
}