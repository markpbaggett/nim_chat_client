import json
type
  Message* = object
    username*: string
    message*: string

proc parseMessage*(data: string): Message =
  let dataJson = parseJson(data)
  result.username = dataJson["username"].getStr()
  result.message = dataJson["message"].getStr()

proc createMessage*(username, message: string): string =
  # $ converts the JsonNode returned by the % operator to a string
  #[ Carriage return and line feed characters are added to the end of the message to 
  ensure the server knows when a Json block ends. While anything in theory could be 
  used, the carriage return and line feed sequence works out of the box with nim's 
  networking protocols.
  ]#
  result = $(%{
    "username": %username,
    "message": %message
  }) & "\c\l"

# Unit Tests
when isMainModule:
  block:
    # Test that parsed json asserts to true
    let data = """{"username": "Mark", "message": "Yo!"}"""
    let parsed = parseMessage(data)
    doAssert parsed.username == "Mark"
    doAssert parsed.message == "Yo!"
    echo("All tests passed!")
  block:
    let data = """foobar"""
    try:
      # If we try to parse anything that is not JSON, we expect this not to pass.
      let parsed = parseMessage(data)
      # I haven't figured out how to ignore the fact that we don't use this variable here.
      doAssert false
    except JsonParsingError:
      # Ensure that this block only passes if a JsonParsingError occurs.
      doAssert true
    except:
      # If any other exception occurs in this block, this should fail.
      doAssert false
    block:
      # Add a test to make sure createMessages pass and assert to true.
      let expected = """{"username":"dom","message":"hello"}""" & "\c\l"
      doAssert createMessage("dom", "hello") == expected