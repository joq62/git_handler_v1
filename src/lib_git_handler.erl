%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2024, c50
%%% @doc
%%%
%%% @end
%%% Created : 11 Jan 2024 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(lib_git_handler).
  
-include("git_handler.hrl").
-define(UpToDate,"Up to date").
-define(NotUpToDate,"Not up to date").
 
%% API

-export([
	 all_filenames/1,
	 read_file/2,	
	 update_repo/1,
	 clone/2, 
	 delete/1,
	 is_repo_updated/1

	]).



-export([

	
	]).



%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
all_filenames(RepoDir)->
    {ok,AllFileNames}=file:list_dir(RepoDir),
    AllRegularFiles=[FileName||FileName<-AllFileNames,
				filelib:is_regular(filename:join(RepoDir,FileName))],
    {ok,AllRegularFiles}.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
read_file(RepoDir,FileName)->
    FullFileName=filename:join([RepoDir,FileName]),
    {ok,Info}=file:consult(FullFileName),
    {ok,Info}.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
all_repo_files(RepoDir)->
    {ok,AllFileNames}=file:list_dir(RepoDir),
    AllFullFilenames=[filename:join([RepoDir,FileName])||FileName<-AllFileNames],
    {ok,AllFullFilenames}.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
delete(RepoDir)->
    ok=file:del_dir_r(RepoDir),
    ok.


%%********************* Deployment *****************************************    
get_info(Key,DeploymentId,SpecMaps)->
    Result=case [Map||Map<-SpecMaps,
		      DeploymentId==maps:get(id,Map)] of
	       []->
		   {error,["DeploymentId doesn't exists",DeploymentId]};
	       [Map]->
		   case maps:get(Key,Map) of
		       {badkey,Key}->
			   {error,["Badkey ",Key]};
		       Value->
			   {ok,Value}
		   end
	   end,
    Result. 

%%********************* Repo ************************************


%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
check_update_repo_return_maps(RepoDir,RepoGit)->
    Result=case is_repo_updated(RepoDir) of
	       {error,["RepoDir doesnt exists, need to clone"]}->
		   clone(RepoDir,RepoGit);
	       {ok,false} ->
		   update_repo(RepoDir);
	       {ok,true}->
		   ok
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
check_status_repo(RepoDir)->
    Result=case is_repo_updated(RepoDir) of
	       {error,["RepoDir doesnt exists, need to clone"]}->
		   {ok,eexists};
	       {ok,false} ->
		   {ok,not_updated};
	       {ok,true}->
		   {ok,updated}
	   end,
    Result.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
is_repo_updated(RepoDir)->
    Result=case filelib:is_dir(RepoDir) of
	       false->
		   {error,["RepoDir doesnt exists, need to clone"]};
	       true->
		   {ok,is_up_to_date(RepoDir)}
	   end,
    Result.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
update_repo(RepoDir)->
    true=filelib:is_dir(RepoDir),
    Result=fetch_merge(RepoDir),  
    Result.
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
clone(RepoDir,RepoGit)->
    file:del_dir_r(RepoDir),
    ok=file:make_dir(RepoDir),
    []=os:cmd("git clone -q "++RepoGit++" "++RepoDir),
    ok.


%%%===================================================================
%%% Internal functions
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
fetch_merge(LocalRepo)->
    Result=case is_up_to_date(LocalRepo) of
	       false->
		   []=os:cmd("git -C "++LocalRepo++" "++"fetch origin "),
		   Info=os:cmd("git -C "++LocalRepo++" "++"merge  "),
		   {ok,Info};
	       true->
		   {error,["Already updated ",LocalRepo]}
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
merge(LocalRepo)->
    Result=case is_up_to_date(LocalRepo) of
	       false->
		   os:cmd("git -C "++LocalRepo++" "++"merge  ");
	       true->
		   {error,["Already updated ",LocalRepo]}
	   end,
    Result.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------

do_clone(RepoDir,RepoGit)->
    []=os:cmd("git clone -q "++RepoGit++" "++RepoDir),
    ok.

%%--------------------------------------------------------------------
%% @doc
%% 
%% @end
%%--------------------------------------------------------------------
is_up_to_date(LocalRepo)->

    _Fetch=os:cmd("git -C "++LocalRepo++" "++"fetch origin "),
    Status=os:cmd("git -C "++LocalRepo++" status -uno | grep -q 'Your branch is up to date'  && echo Up to date || echo Not up to date"),
    [FilteredGitStatus]=[S||S<-string:split(Status, "\n", all),
			  []=/=S],
    Result=case FilteredGitStatus of
	       ?UpToDate->
		   true;
	       ?NotUpToDate->
		   false
	   end,
    Result.
