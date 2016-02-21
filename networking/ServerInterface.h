#pragma once

#include<functional>
#include<vector>
#include<string>
#include<unordered_map>


/*
 *Button settings specified by developer
 */
struct Button{
	int id;
	int size_x;
	int size_y;
	int grid_x;
	int grid_y;
	std::string text;
	
	Button(int _id, int _size_x, int _size_y, int _grid_x, int _grid_y, std::string _text)
	:id(_id), size_x(_size_x), size_y(_size_y), grid_x(_grid_x), grid_y(_grid_y), text(_text){}
};

class ServerInterface {
public:
  
	//STORAGE FOR BUTTONS
	std::vector<Button*> btn_vec;
	//MAPPINNG FROM ID TO FUNCTION
	std::unordered_map<int, std::function<void()> > function_map;		  
//////////////////////SETTINGS//////////////////////////////////
/*
 *Create and store new button
 *RETURNS: 1 on success
 */
	int create_button(int id, int size_x, int size_y, int grid_x, int grid_y, std::string text, std::function<void()> func);		

  
//////////////////////INTERFACE/////////////////////////////////
 /**
   * Constructs the object and starts the server
   */
  ServerInterface(){}
  /**
   * Starts the server
   */
  bool startServer(/* parameters */);
  /**
   * Stops the server
   */
  bool stopServer();

  /**
   * In the case of a single threaded
   */ 
  bool process(); 

  /**
   * Stops the server if its running and destroys the object
   */
  ~ServerInterface();

  // Its going to be a bit harder to define how the communication works.
  // Probably do an example, then work it out
 };
