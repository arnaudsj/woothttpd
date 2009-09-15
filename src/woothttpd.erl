-module(woothttpd).
-author("Sébastien Arnaud <arnaudsj@gmail.com>").
-compile(export_all).

start([PortString]) -> 
	Port = list_to_integer(atom_to_list(PortString)),
	%% TODO: Make Workers a parameter to the start function
	Workers = 100,
	{ok, Listen} = gen_tcp:listen(Port, [binary,
					{reuseaddr, true}, 
					{packet, 0},
					{active, once},
					{backlog, 100} ] ),
	io:format("woothttpd listening on ~p~n", [Port]),
	_PidList = lists:map(fun(_I)-> spawn(?MODULE, accept_loop, [Listen]) end, lists:seq(1, Workers)),
	io:format("woothttpd fired ~p workers~n", [Workers]),
	%% TODO: Replace this by using the Socket controlling process to keep count of how many connections are used at any one time and fire/kill processes to scale up/down silently.
	accept_loop(Listen). 

accept_loop(Listen) ->
	{ok, Socket} = gen_tcp:accept(Listen),
	loop(Socket),
	accept_loop(Listen).

loop(Socket) ->
	receive 
		{tcp, Socket, _Bin} -> 
			ReplyBody = "<html>\n<head>\n<title>Welcome to nginx!</title>\n</head>\n<body bgcolor=\"white\" text=\"black\">\n<center><h1>Welcome to WootHTTPD!</h1></center>\n</body>\n</html>\n",
			ReplyFull = io_lib:format("HTTP/1.1 200 OK\nDate: Sat, 12 Sep 2009 20:43:04 GMT\nContent-Type: text/html;charset=ISO-8859-1\nContent-Length: ~w\nServer: woothttpd/0.1 (Unix)\nConnection: close \n\n~s\r~n\r~n", [length(ReplyBody)+4, ReplyBody]), % +4 added to compensate 4 bytes for URL needed
			inet:setopts(Socket, [{active, once}]),
			gen_tcp:send(Socket, ReplyFull),
			gen_tcp:close(Socket);
		{tcp_closed, Socket} -> 
			io:format("Server socket closed~n")
	end.