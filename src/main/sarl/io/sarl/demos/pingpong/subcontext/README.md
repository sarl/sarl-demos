Demo: Distributed Factorial
===========================

## Principle of the Demo

The principle of the application is the following:

* The Ping agent is sending a Ping message to all agents.
* The Pong agent is receiving the Ping message, and replies with a Pong message to the sender of the Ping message.
* The Ping agent is receiving a Pong message and replies to the sender of the Pong with a new Ping message.

These messages contains an integer number that indicates the number of the event.

**All the messages are exchanged into a specific space of the inner context of an agent of type SubcontextPongAgent.** The ID of the default is given in the
`io.sarl.demos.pingpong.PingPongConstants` Java class.

## Compiling the Demo using Maven

You need to compile the demo with Maven. Type on the command
line:

> mvn clean package

## Launching the Demo

For launching the demo, you need to launch two agents
in two different Janus runtime environments.
Type on the two following command lines in different terminals
(the order of the command lines is important):

> mvn exec:java
>     -Dexec.mainClass=io.janusproject.Boot
>     -Dexec.args=io.sarl.demos.pingpong.subcontext.SubcontextPingAgent

> mvn exec:java
>     -Dexec.mainClass=io.janusproject.Boot
>     -Dexec.args=io.sarl.demos.pingpong.subcontext.SubcontextPongAgent
