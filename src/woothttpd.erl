-module(woothttpd).
-author("Sébastien Arnaud <arnaudsj@gmail.com>").
-compile(export_all).

start([PortString]) -> 
	Port = list_to_integer(atom_to_list(PortString)),
	{ok, Listen} = gen_tcp:listen(Port, [binary,
					 {reuseaddr, true}, 
					 {packet, 0},
					 {active, true},
					{backlog, 30}] ),
	io:format("nanohttpd listening on ~p~n", [Port]),
	seq_loop(Listen).

%	{ok, Socket} = gen_tcp:accept(Listen),
%	gen_tcp:close(Listen),
%	loop(Socket).

seq_loop(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	loop(Socket),
	seq_loop(Listen).

loop(Socket) ->
	%io:format("nanohttpd accepted a connection~n"),
	receive 
		{tcp, Socket, Bin} -> 
			%io:format("Server received binary = ~p~n",[Bin]),
			
			ReplyBody = "<html><body><h1>Hello, Nano World!</h1></body></html>",
			ReplyFull = io_lib:format("HTTP/1.1 200 OK\nDate: Sat, 12 Sep 2009 20:43:04 GMT\nContent-Type: text/html;charset=ISO-8859-1\nContent-Length: ~w\nServer: nanohttpd/0.1 (Unix)\nConnection: close \n\n~s\r~n\r~n", [size(list_to_binary(ReplyBody)), ReplyBody]),
			
			%io:format("Server replying = ~p~n",[lists:flatten(ReplyFull)]),

			gen_tcp:send(Socket, lists:flatten(ReplyFull)),
			gen_tcp:close(Socket);
			
		{tcp_closed, Socket} -> 
			io:format("Server socket closed~n")
	end.