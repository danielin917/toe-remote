#include "ServerInterface.h"
#include<iostream>
#include<string>
#include<unordered_map>
#include<functional>
int ServerInterface::create_button(int id, int size_x, int size_y, int grid_x, int grid_y, std::string text, std::function<void()> func)
{
	Button* btn = new Button(id, size_x, size_y, grid_x, grid_y, text);
	btn_vec.push_back(btn);
	function_map[id] = func;		
	return 1;	
}

