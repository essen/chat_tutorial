-module(session).
-behaviour(gen_server).

%% API.
-export([start_link/1]).
-export([stop/0]).
-export([hello/1]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {
	buffer = [],
	username
}).

-define(SERVER, ?MODULE).

%% API.

%% @private
start_link(Username) ->
	gen_server:start_link(?MODULE, [Username], []).

%% @private
-spec stop() -> stopped.
stop() ->
	gen_server:call(?SERVER, stop).

hello(Pid) ->
	gen_server:cast(Pid, {hello, self()}).

%% @private
init([Username]) ->
	io:format("session started for ~p~n", [Username]),
	gproc:reg({n, l, {session, Username}}),
	gproc:reg({p, l, my_room}),
	{ok, #state{username=Username}}.

%% @private
handle_call(stop, _From, State) ->
	{stop, normal, stopped, State};
handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

%% @private
handle_cast({hello, Pid}, State=#state{buffer=Buffer}) ->
	_ = [Pid ! Msg || Msg <- lists:reverse(Buffer)],
	{noreply, State};
handle_cast(_Msg, State) ->
	{noreply, State}.

%% @private
handle_info(Info, State=#state{buffer=Buffer, username=Username}) ->
	gproc:send({p, l, {ws, Username}}, Info),
	{noreply, State#state{buffer=[Info|Buffer]}}.

%% @private
terminate(_Reason, _State) ->
	ok.

%% @private
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
