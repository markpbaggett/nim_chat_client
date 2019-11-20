import asyncdispatch, asyncnet
type
  #[
    Note to self: Types defined with the ref keyword are known as reference types. When an instance
    of a reference type is passed as a parameter to a procedure, instead of passing the
    underlying object by value, it’s passed by reference. This allows you to modify the 
    original data stored in the passed variable from inside your procedure. 
    
    A non-ref type passed as a parameter to a procedure is IMMUTABLE!!!
  ]#
  Client = ref object
    socket: AsyncSocket
    netAddr: string
    id: int
    connected: bool
  
  Server = ref object
    socket: AsyncSocket
    clients: seq[Client]

proc newServer(): Server = Server(socket: newAsyncSocket(), clients: @[])
var server = newServer()

# Add async code
proc loop(server: Server, port = 7687) {.async.} =
  server.socket.bindAddr(port.Port)
  server.socket.listen()
  while true:
    let clientSocket = await server.socket.accept()
    echo("Accepted connection!")
waitFor loop(server)