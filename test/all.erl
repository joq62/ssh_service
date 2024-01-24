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

-define(C50,{"172.18.221.251",22,"joq62","festum01"}).
%% -define(C200,{"192.168.1.200",22,"ubuntu","festum01"}).
-define(C202,{"192.168.1.202",22,"ubuntu","festum01","c202"}).
-define(C201,{"192.168.1.201",22,"ubuntu","festum01","c201"}).

-define(NodeName,"kubelet").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
    ok=test_c50(),
%    ok=test0(),
%    ok=start_vm(),
%    ok=check_hosts(),
     
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
test_c50()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    {Ip,Port,Uid,Pwd}=?C50,
    TimeOut=5000,
    %% Working directory
    {ok,["/home/joq62"]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    %io:format("Pwd1 ~p~n",[{Pwd1,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    %% create and delete dir
    
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"rm -rf glurk",TimeOut),
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"mkdir glurk",TimeOut),
    {error,[_Reason]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"mkdir glurk",TimeOut),
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"rm -rf glurk",TimeOut),
       
    %start vm 
    {ok,HostName}=net:gethostname(),
    CookieStr=atom_to_list(erlang:get_cookie()),
    NodeName="ssh_test_vm",
    Node=list_to_atom(NodeName++"@"++HostName),
    rpc:call(Node,init,stop,[],5000),
    timer:sleep(3000),
    ErlCmd="erl -sname "++NodeName++" "++"-setcookie "++CookieStr++" "++"-noinput -detached",
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,ErlCmd,TimeOut),
    timer:sleep(3000),
    pong=net_adm:ping(Node),

    %% Start kubelet 
    {ok,[Home]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    Ebin=filename:join([Home,"kubelet","ebin"]),
  %  io:format("Ebin ~p~n",[{Ebin,?MODULE,?FUNCTION_NAME,?LINE}]),
    true=rpc:call(Node,code, add_path,[Ebin],5000),
    KubeletBeam=filename:join([Home,"kubelet","ebin","kubelet.beam"]),
    KubeletBeam=rpc:call(Node,code, where_is_file,["kubelet.beam"],5000),
    ok=rpc:call(Node,application,load,[kubelet],5000),
    ok=rpc:call(Node,application,start,[kubelet],5000),
    pong=rpc:call(Node,kubelet,ping,[],5000),

    
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
check_hosts()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    {Ip,Port,Uid,Pwd,HostName}=?C202,
    {IpC201,Port,Uid,Pwd,HostNameC201}=?C201,
    TimeOut=60,

    Response=ssh_service:send_msg(Ip,Port,Uid,Pwd,"ping "++IpC201,TimeOut),
    io:format("Response ~p~n",[{Response,?MODULE,?FUNCTION_NAME,?LINE}]),
       
    
    ok.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
start_vm()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    {IpC201,Port,Uid,Pwd,HostNameC201}=?C201,
    {Ip,Port,Uid,Pwd,HostName}=?C202,
    TimeOut=2000,
    CookieStr=atom_to_list(erlang:get_cookie()),
    NodeName=?NodeName,
    Node=list_to_atom(NodeName++"@"++HostName),

    io:format("NodeName, CookieStr, Node ~p~n",[{NodeName, CookieStr, Node,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    rpc:call(Node,init,stop,[],5000),
    timer:sleep(2000),
    
    % erl -sname NodeName -setcookie CookieStr -noinput
  %  ErlCmd="erl "++"-sname "++NodeName++" "++"-setcookie "++CookieStr++" "++" -noinput &",
    ErlCmd="erl "++"-sname "++NodeName++" "++"-setcookie "++CookieStr++" "++" -detached",
    io:format("ErlCmd ~p~n",[{ErlCmd,?MODULE,?FUNCTION_NAME,?LINE}]),

    ResponseC201=ssh_service:send_msg(IpC201,Port,Uid,Pwd,ErlCmd,TimeOut),
    io:format("ResponseC201 ~p~n",[{ResponseC201,?MODULE,?FUNCTION_NAME,?LINE}]), 

    ResponseC202=ssh_service:send_msg(Ip,Port,Uid,Pwd,ErlCmd,TimeOut),
    io:format("ResponseC202 ~p~n",[{ResponseC202,?MODULE,?FUNCTION_NAME,?LINE}]),


    
    timer:sleep(2000),
    pong=net_adm:ping(Node),
    
    ok.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
test0()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    {Ip,Port,Uid,Pwd,_HostName}=?C202,
    TimeOut=5000,
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"rm -rf glurk",TimeOut),
    Pwd1=ssh_service:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    io:format("Pwd1 ~p~n",[{Pwd1,?MODULE,?FUNCTION_NAME,?LINE}]),
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"mkdir  glurk",TimeOut),
    {error,Reason1}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"mkdir  glurk",TimeOut),
    io:format("error,Reason1 ~p~n",[{Reason1,?MODULE,?FUNCTION_NAME,?LINE}]),
    {ok,[]}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"rm -r glurk",TimeOut),
    {error,Reason2}=ssh_service:send_msg(Ip,Port,Uid,Pwd,"rm -r glurk",TimeOut),
    io:format("error,Reason2 ~p~n",[{Reason2,?MODULE,?FUNCTION_NAME,?LINE}]),
%    Pwd2=ssh_service:send_msg("172.26.158.249",22,"joq62","festum01","pwd",TimeOut),
%    io:format("Pwd2 ~p~n",[{Pwd2,?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok.

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------


setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME}]),
   
    a=erlang:get_cookie(),
    ok=application:start(ssh_service),
    pong=ssh_service:ping(),
    ok.
