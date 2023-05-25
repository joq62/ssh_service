%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(all).      
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-define(C200,{"192.168.1.200",22,"ubuntu","festum01"}).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=test1(),
     
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
    {Ip,Port,Uid,Pwd}=?C200,
    TimeOut=5000,
    {ok,["/home/ubuntu"]}=ssh_server:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    {ok,["/home/ubuntu"]}=ssh_server:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    {error,["bash: glurk: command not found"]}=ssh_server:send_msg(Ip,Port,Uid,Pwd,"glurk",TimeOut),
    {error,["rm: cannot remove 'glurk'"]}=ssh_server:send_msg(Ip,Port,Uid,Pwd,"rm -r glurk",TimeOut),

     {error,["Database not available ",dbetcd_appl]}=ssh_server:send_msg("c200","pwd",TimeOut),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
   
    a_cookie=erlang:get_cookie(),
    ok=application:start(tests),
    pong=common:ping(),
    pong=sd:ping(),
    pong=log:ping(),
    pong=ssh_server:ping(),
    ok.
