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
		  SessionResult=receive
			      {ssh_cm, ConRef, {data, ChanId, Type, Result}}->
				  {ok,{data, ChanId, Type, Result}};
			      Err2 ->
				  {error,[Err2,?MODULE,?FUNCTION_NAME,?LINE]}
			  after TimeOut->
				  {error,[timeout,?MODULE,?FUNCTION_NAME,?LINE]}
			  end,
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
