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
-module(git_test).      
 
-export([start/0]).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


-define(DeploymentRepoDir,"deployment_specs_test").
-define(DeploymentGit,"https://github.com/joq62/deployment_specs_test.git").

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),
    
    ok=setup(),
    ok=test1(),
    loop(false),

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
test1()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),

    %% Detect that no local repo 
    file:del_dir_r(?DeploymentRepoDir),
    false=filelib:is_dir(?DeploymentRepoDir),
    %% Filure test
    {error,_,_,_,_}=git_handler:all_filenames(?DeploymentRepoDir),
  %  {error,{badmatch,{error,enoent}},
  %   [{lib_git_handler,all_filenames,1,
  %     [{file,
%	 "/home/joq62/erlang/dev/git_handler/src/lib_git_handler.erl"},
%	{line,46}]},
 %     {git_handler,handle_call,3,
  %     [{file,
%	 "/home/joq62/erlang/dev/git_handler/src/git_handler.erl"},
%	{line,223}]},
 %     {gen_server,try_handle_call,4,
  %     [{file,"gen_server.erl"},{line,721}]},
   %   {gen_server,handle_msg,6,
    %   [{file,"gen_server.erl"},{line,750}]},
     % {proc_lib,init_p_do_apply,3,
     %  [{file,"proc_lib.erl"},{line,226}]}]},
   % {badmatch,{error,enoent},_,_,_}=git_handler:all_filenames(?DeploymentRepoDir),
    {error,_,_,_,_}=git_handler:read_file(?DeploymentRepoDir,"first.deployment"),
    {error,_,_,_,_}=git_handler:update_repo(?DeploymentRepoDir),

    %and do clone 
    ok=git_handler:clone("glurk",?DeploymentGit),
    ok=git_handler:clone(?DeploymentRepoDir,"glurk"),
    ok=git_handler:clone(?DeploymentRepoDir,?DeploymentGit),
    true=filelib:is_dir(?DeploymentRepoDir),
    {ok,["first.deployment"]}=git_handler:all_filenames(?DeploymentRepoDir),
    {ok,[Map]}=git_handler:read_file(?DeploymentRepoDir,"first.deployment"),
    [{"adder","c200"},{"adder","c202"},{"divi","c200"},{"divi","c202"}]=lists:sort(maps:get(deployments,Map)),
    {error,_,_,_,_}=git_handler:read_file(?DeploymentRepoDir,"glurk.deployment"),
    {error,["Already updated ",?DeploymentRepoDir]}=git_handler:update_repo(?DeploymentRepoDir),
    
    ok.
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
loop(RepoState)->
  %  io:format("Start ~p~n",[{time(),?MODULE,?FUNCTION_NAME,?LINE}]),
    io:format("get all filenames ~p~n",[{git_handler:all_filenames(?DeploymentRepoDir),?MODULE,?LINE}]),
    NewState=case git_handler:is_repo_updated(?DeploymentRepoDir) of
		 true->
		     case RepoState of
			 false->
			     io:format("RepoState false-> true ~p~n",[{git_handler:is_repo_updated(?DeploymentRepoDir),?MODULE,?LINE}]),
			     io:format("get all filenames ~p~n",[{git_handler:all_filenames(?DeploymentRepoDir),?MODULE,?LINE}]),
			     true;
			 true->
			     RepoState
		     end;
		 false->
		     case RepoState of
			 true->
			     io:format("RepoState true->false ~p~n",[{git_handler:is_repo_updated(?DeploymentRepoDir),?MODULE,?LINE}]),
			     io:format("git_handler:update_repo(?DeploymentRepoDir)~p~n",[{git_handler:update_repo(?DeploymentRepoDir),?MODULE,?LINE}]),
			     git_handler:update_repo(?DeploymentRepoDir),
			     io:format("get all filenames ~p~n",[{git_handler:all_filenames(?DeploymentRepoDir),?MODULE,?LINE}]),
			     false;
			 false->
			     RepoState
		     end
	     end,
		    
    timer:sleep(10*1000),
    loop(NewState).

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
setup()->
    io:format("Start ~p~n",[{?MODULE,?FUNCTION_NAME,?LINE}]),

  
    pong=log:ping(),
  
    pong=rd:ping(),
  
    pong=git_handler:ping(),    
 
    % cleanb up spec dirs 

    [rd:add_local_resource(ResourceType,Resource)||{ResourceType,Resource}<-[git_handler]],
    [rd:add_target_resource_type(TargetType)||TargetType<-[]],
    rd:trade_resources(),
    timer:sleep(3000),
   
    ok.
