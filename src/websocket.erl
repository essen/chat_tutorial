%% Feel free to use, reuse and abuse the code in this file.

-module(websocket).

%% API.
-export([start/0]).

start() ->
	ok = application:start(crypto),
	ok = application:start(ranch),
	ok = application:start(cowlib),
	ok = application:start(cowboy),
	ok = application:start(gproc),
	ok = application:start(websocket).
