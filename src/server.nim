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
proc `$` (client: Client): string =
  $client.id & "(" & client.netAddr & ")"

proc processMessages(server: Server, client: Client) {.async.} =
  while true:
    let line = await client.socket.recvLine()
    if line.len == 0: # if line is empty, display message saying client disconnected
      echo(client, "disconnected!")
      client.connected = false
      client.socket.close()
      return # Stop further processing of messages
    echo (client, " sent: ", line)


# Add async code
proc loop(server: Server, port = 7687) {.async.} =
  server.socket.bindAddr(port.Port)
  server.socket.listen()
  while true:
    let (netAddr, clientSocket) = await server.socket.acceptAddr()
    echo("Accepted connection from ", netAddr)
    let client = Client(
      socket: clientSocket,
      netAddr: netAddr,
      id: server.clients.len,
      connected: true
    )
    server.clients.add(client)
    asyncCheck processMessages(server, client)

var server = newServer()
waitFor loop(server)