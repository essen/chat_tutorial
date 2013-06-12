-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-record(state, {
	username,
	session
}).

init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
	{Username, Req2} = cowboy_req:binding(username, Req),
	Pid = case gproc:where({n, l, {session, Username}}) of
		undefined ->
			{ok, P} = supervisor:start_child(sessions_sup, [Username]),
			P;
		P ->
			session:hello(P),
			P
	end,
	gproc:reg({p, l, {ws, Username}}),
	{ok, Req2, #state{username=Username, session=Pid}}.

websocket_handle({text, Msg}, Req, State) ->
	gproc:send({p, l, my_room}, {text, Msg}),
	{ok, Req, State}.

websocket_info(Info, Req, State) ->
	{reply, Info, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
