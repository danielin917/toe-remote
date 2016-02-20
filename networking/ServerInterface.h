#pragma once

/**
 * Parameters required to start the server.
 */
struct ServerParameters {
  
};

enum class Commands {
  RequestName,

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
