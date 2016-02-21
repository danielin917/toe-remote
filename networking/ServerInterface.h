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

/*
 * Parameters required to start the server.
 */
struct ServerParameters {
	std::vector<Button*> btn_vec;
	std::unordered_map<int, std::function<void()> > function_map;		  
	int create_button(int id, int size_x, int size_y, int grid_x, int grid_y, std::string text)
	{
		Button* btn = new Button(id, size_x, size_y, grid_x, grid_y, text);
		btn_vec.push_back(btn);
		return 1;	
	}	
};
class ServerInterface {
public:
  /**
   * Constructs the object and starts the server
   */
  ServerInterface(ServerParameters params);
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
