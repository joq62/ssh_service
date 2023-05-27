%% @author Paolo Oliveira <paolo@fisica.ufc.br>
%% @copyright 2015-2016 Paolo Oliveira (license MIT)
%% @version 1.0.0
%% @doc
%% A simple, pure erlang implementation of a module for <b>Raspberry Pi's General Purpose
%% Input/Output</b> (GPIO), using the standard Linux kernel interface for user-space, sysfs,
%% available at <b>/sys/class/gpio/</b>.
%% @end
 
-module(lib_ssh).
-export([send/6]).
-author('joq erlang').

-define(DELAY,2000).
% io:format("Reply ~p~n",[{Reply,?MODULE,?FUNCTION_NAME,?LINE}]),



send(Ip,Port,User,Password,Msg,TimeOut)->
    Reply=case ssh_connect(Ip,Port,User,Password,TimeOut) of
	      {error,Err}->
		  {error,[Err,?MODULE,?FUNCTION_NAME,?LINE]};
	      {ok,ConRef,ChanId}->
		  ssh_connection:exec(ConRef,ChanId,Msg,TimeOut),
		  SessionResult=rec(ConRef,ChanId,[],start,TimeOut),
		  ssh:close(ConRef),
		  SessionResult;
	      Reason ->
		  {error,[Reason,?MODULE,?FUNCTION_NAME,?LINE]}
	  end,
    Reply.


ssh_connect(Ip,Port,User,Password,TimeOut)->
    Result=case ssh:connect(Ip,Port,[{user,User},{password,Password},
				     {silently_accept_hosts, true} ],TimeOut) of
	       {error,Err}->
		   {error,Err};
	       {ok,ConRef}->
		   case ssh_connection:session_channel(ConRef,TimeOut) of
		       {error,Err}->
			   {error,[Err,?MODULE,?FUNCTION_NAME,?LINE]};
		       {ok,ChanId}->
			   {ok,ConRef,ChanId}
		   end;
	       Err2 ->
		   {error,[Err2]}
	   end,
    Result.

rec(_ConRef,_ChanId,Result,exit,_TimeOut)->
    lists:reverse(Result);

rec(ConRef,ChanId,Result,State,TimeOut)->
  %  io:format("Result,State ~p~n",[{Result,State,?MODULE,?FUNCTION_NAME,?LINE}]),
    receive
	{ssh_cm, ConRef, {data, ChanId, Type, Data}} when Type == 0 ->
	    NextState=eof,
	    X1=binary_to_list(Data),
	    ParsedData=string:tokens(X1,"\n"),
	    io:format("NewResult,NextState ~p~n",[{[{ok,ParsedData}|Result],NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=[{ok,ParsedData}|Result];
	{ssh_cm, ConRef, {data, ChanId, Type, Data}} when Type == 1 ->
	    NextState=eof,
	    X1=binary_to_list(Data),
	    ParsedData=string:tokens(X1,"\n"),
	    io:format("NewResult,NextState ~p~n",[{[{error,[ParsedData,?MODULE,?FUNCTION_NAME,?LINE]}|Result],NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=[{error,[ParsedData,?MODULE,?FUNCTION_NAME,?LINE]}|Result];
	{ssh_cm,ConRef,{eof,0}} ->
	    NextState=exit_status,
	    io:format("Result,NextState ~p~n",[{Result,NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=Result;
	{ssh_cm,ConRef,{exit_status,0,0}} ->
	    NextState=closed,
	    io:format("Result,NextState ~p~n",[{Result,NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=Result;
	{ssh_cm,ConRef,{exit_status,0,1}} ->
	    NextState=closed,
	    io:format("Result,NextState ~p~n",[{Result,NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=Result;
	{ssh_cm,ConRef,{closed,0}} ->
	    NextState=exit,
	    io:format("Result,NextState ~p~n",[{Result,NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult=Result;
	Unmatched->
	    NextState=exit,
	    io:format("Unmatched,Result,NextState ~p~n",[{Unmatched,Result,NextState,?MODULE,?FUNCTION_NAME,?LINE}]),
	    NewResult={error,["Unmatched",Unmatched,?MODULE,?LINE]}
    after TimeOut->
	    NextState=exit,
	    NewResult={error,["timeout",?MODULE,?LINE]}
    end,
    rec(ConRef,ChanId,NewResult,NextState,TimeOut).
