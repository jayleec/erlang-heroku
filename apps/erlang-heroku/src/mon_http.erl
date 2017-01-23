
%%%-------------------------------------------------------------------
%%% @author Lee
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. 12월 2016 오후 5:47
%%%-------------------------------------------------------------------
-module(mon_http).
-author("Lee Jae Kyung").

%% API
-export([init/3 , handle/2 , terminate/3]).

init(_Type, Req, []) ->
    {ok, Req, no_state}.

handle(Req, State) ->
%% Header access control allow
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, Req),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
%% read data
    {Api, Req3} = cowboy_req:binding(api, Req2),
    {What, Req4} = cowboy_req:binding(what, Req3),
    {Opt, Req5} = cowboy_req:binding(opt, Req4),

    {ok, Data, Req6} = cowboy_req:body_qs(Req5),
%%    io:format("Data :~p~n", [Data]),

    io:format("~napi = ~p, what=~p, opt = ~p ~n",[Api, What, Opt]),

    Reply = handle(Api, What, Opt, Data),

    {ok, Req7} = cowboy_req:reply(200, [
        {<<"content-type">>, <<"text/plain">>}
    ], Reply, Req6),

    {ok, Req7, State}.

%%handle(<<"websocket">>, _, _, _) ->
%%    %%  create chatting room1
%%    chat_manager:init_room(1),
%%    jsx:encode([{<<"result">>, <<"websocket started">>}]);

handle(<<"login">>, _, _, Data) ->
    Id = proplists:get_value(<<"id">>, Data),
    Password = proplists:get_value(<<"password">>, Data),
    case mon_users:login(Id, Password) of
        {ok, SessionKey} ->
            jsx:encode([
                {<<"result">>, <<"ok">>},
                {<<"session_key">>, SessionKey}
            ]);
        fail ->
            jsx:encode([{<<"result">>, <<"fail">>}])
    end;

handle(<<"join">>, _, _, Data) ->
%%    io:format("Data print: ~p~n", [Data]),
%%  Erlang/OTP 19
%%    #{id := Id, password := Password} = cowboy_req:match_qs([id, password], Data),
    Id = proplists:get_value(<<"id">>, Data),
    Password = proplists:get_value(<<"password">>, Data),
  case mon_users:join(Id, Password) of
    fail ->
      jsx:encode([{<<"result">>, <<"duplicated">>}]);
    ok ->
      jsx:encode([{<<"result">>, <<"join">>}])
  end;

%% Erlang/OTP 19 only
%%handle(<<"users">>, <<"point">>, _, Data) ->
%%  #{point := Point0, session_key := SessionKey} = cowboy_req:match_qs([point, session_key ], Data),
%%  Point = binary_to_integer(Point0),
%%  case mon_users:point(SessionKey, Point) of
%%      ok ->
%%        jsx:encode([{<<"result">>, <<"ok">>}]);
%%      fail ->
%%        jsx:encode([{<<"result">>, <<"fail">>}])
%%  end;
%%
%%handle(<<"users">>, <<"token">>, _, Data) ->
%%  #{token := Token, session_key := SessionKey} = cowboy_req:match_qs([token, session_key ], Data),
%%  case mon_users:token(SessionKey, Token) of
%%    ok ->
%%      jsx:encode([{<<"result">>, <<"ok">>}]);
%%    fail ->
%%      jsx:encode([{<<"result">>, <<"fail">>}])
%%  end;

handle(<<"hello">>, <<"world">>, _, _) ->
  jsx:encode([{<<"result">>, <<"world">>}]);

handle( _, _, _, _) ->
  jsx:encode([{<<"result">>, <<"no API ~~ error">>}]).

terminate(_Reason, _Req, _State) ->
  ok.