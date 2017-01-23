%%%-------------------------------------------------------------------
%%% @author jay
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jan 2017 9:01 PM
%%%-------------------------------------------------------------------
-module(erl_heroku_app).
-author("Lee Jae Kyung").

-behaviour(application).

%% Application callbacks
-export([start/2,
    stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
    {ok, pid()} |
    {ok, pid(), State :: term()} |
    {error, Reason :: term()}).
start(_StartType, _StartArgs) ->
    %% start mnesia for heroku upload
    mon_db:install(),
    %% necessary application
    ok = application:start(crypto),
    ok = application:start(asn1),
    ok = application:start(public_key),
    ok = application:start(ssl),
    ok = application:start(cowlib),
    ok = application:start(ranch),
    ok = application:start(mnesia),
    ok = application:start(inets),
    ok = application:start(cowboy),
    ok = application:start(ebus),
    ok = application:start(jiffy),

    Port = port(),

    %% Cowboy Router
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/websocket", ws_handler, []},
            {"/:api/[:what/[:opt]]", mon_http, []}
        ]}
    ]),
    %% HTTP Server start
    {ok, _} = cowboy:start_http(http, 100, [{port, Port}], [
        {env, [{dispatch, Dispatch}]}
    ]),

    %% Code reloader start
    mon_reloader:start(),

    %% Session Table
    ets:new(session_list, [public, named_table]),

    case erl_heroku_sup:start_link() of
        {ok, Pid} ->
            io:format("start ok!"),
            {ok, Pid};
        Error ->
            Error
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------
-spec(stop(State :: term()) -> term()).
stop(_State) ->
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
port() ->
    case os:getenv("PORT") of
        false ->
            {ok, Port} = application:get_env(http_port),
            Port;
        Other ->
            list_to_integer(Other)
    end.