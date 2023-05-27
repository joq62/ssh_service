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
-define(C202,{"192.168.1.202",22,"ubuntu","festum01"}).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
   
    ok=setup(),
   % ok=test1(),
    ok=load_start(),
     
    io:format("Test OK !!! ~p~n",[?MODULE]),
    timer:sleep(2000),
    init:stop(),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
load_start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    {Ip,Port,Uid,Pwd}=?C200,
    TimeOut=5000,
    GitPath="https://github.com/joq62/adder.git",
    Dir="adder",
    NodeName=Dir,
    Cookie="a_cookie",
    App=adder,
    Node=list_to_atom(NodeName++"@"++"c200"),

    {ok,["/home/ubuntu"]}=ssh_server:send_msg(Ip,Port,Uid,Pwd,"pwd",TimeOut),
    %%
    rpc:call(Node,init,stop,[],5000),
    timer:sleep(5000),
    RmDirResult=ssh_server:send_msg(Ip,Port,Uid,Pwd,"rm -rf "++Dir,TimeOut),
    io:format("rm dir ~p~n",[{RmDirResult,?MODULE,?FUNCTION_NAME,?LINE}]),

     MkDirResult=ssh_server:send_msg(Ip,Port,Uid,Pwd,"mkdir "++Dir,TimeOut),
    io:format("mkdir dir ~p~n",[{MkDirResult,?MODULE,?FUNCTION_NAME,?LINE}]),

    GitCloneResult=ssh_server:send_msg(Ip,Port,Uid,Pwd,"git clone "++GitPath++" " ++Dir,TimeOut),
    io:format("GitCloneResult ~p~n",[{GitCloneResult,?MODULE,?FUNCTION_NAME,?LINE}]),

    Ebin=filename:join(Dir,"ebin"),
    Pa=" -pa "++Ebin,
    SysConfig=" -config "++filename:join([Dir,"config","sys.config"]),
    SetCookie=" -setcookie "++Cookie,
    Sname=" -sname "++NodeName,
    Detached=" -detached ",
 %   VmStart=ssh_server:send_msg(Ip,Port,Uid,Pwd,"erl "++Pa++" "++Sname++" "++SetCookie++" "++SysConfig++" "++Sname++" "++Detached,TimeOut),
 %   VmStart=ssh_server:send_msg(Ip,Port,Uid,Pwd,"erl "++Pa++" "++Sname++" "++SetCookie++" "++SysConfig++" "++Sname++" "++Detached,TimeOut),
%    VmStart=ssh_server:send_msg(Ip,Port,Uid,Pwd,"erl -pa adder/ebin -sname adder -setcookie a_cookie -config adder/config/sys.config -detached",TimeOut),
    VmStart=ssh_server:send_msg(Ip,Port,Uid,Pwd,"erl -pa adder/ebin -sname adder -setcookie a_cookie  -detached",TimeOut),
    io:format("VmStart ~p~n",[{VmStart,?MODULE,?FUNCTION_NAME,?LINE}]),
    timer:sleep(5000),
    pong=net_adm:ping(Node),
    

    
    
    
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
