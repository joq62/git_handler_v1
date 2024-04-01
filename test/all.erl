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

-define(DeploymentSpecsRepoDir,"deployment_specs").
-define(DeploymentSpecsGitPath,"https:deployment_specs").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),
  
   % ok=loop(false),
    ok=git_test:start(),
   % ok=git_fetch_test:start(),

    io:format("Test OK !!! ~p~n",[?MODULE]),
%    timer:sleep(1000),
%    init:stop(),
    ok.


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
deployment_test()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),



    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
loop(RepoState)->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
     io:format("get_deployments ~p~n",[{deployment:get_deployments(),?MODULE,?LINE}]),
   
    NewState=case deployment:is_repo_updated() of
		 true->
		     case RepoState of
			 false->
			     io:format("RepoState false-> true ~p~n",[{deployment:is_repo_updated(),?MODULE,?LINE}]),
			     true;
			 true->
			     RepoState
		     end;
		 false->
		     case RepoState of
			 true->
			     io:format("RepoState true->false ~p~n",[{deployment:is_repo_updated(),?MODULE,?LINE}]),
			     deployment:update_repo(), 
			     false;
			 false->
			     RepoState
		     end
	     end,
		    
    timer:sleep(10000),
    loop(NewState).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),

    ok=application:start(log),
    pong=log:ping(),
    ok=application:start(rd),
    pong=rd:ping(),
    ok=application:start(git_handler),
    pong=git_handler:ping(),    
 
    % cleanb up spec dirs 

    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-[git_handler]],
    [rd:add_target_resource_type(TargetType)||TargetType<-[]],
    rd:trade_resources(),
    timer:sleep(3000),
   
    ok.
