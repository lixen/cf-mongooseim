-module(mongooseim_deployed).
-include_lib("common_test/include/ct.hrl").
-export([all/0]).
-export([bosh_deploy/1]).

all() -> [bosh_deploy].

bosh_deploy(_Config) ->
  case os:getenv("BOSH_TARGET") of
    BoshTarget when is_list(BoshTarget) ->
      deploy_mongooseim(BoshTarget),
      get_mongooseim_nodes(BoshTarget) == "[]";
    _ ->
      ct:fail("missing BOSH_TARGET")
  end.

deploy_mongooseim(BoshTarget) ->
  ok = file:set_cwd("../../release/"),
  io:format("pwd ~p", [file:get_cwd()]),
  0 = bosh("target " ++ BoshTarget, target),
  0 = bosh("login admin admin", login),
  0 = bosh("create release --force", create_release),
  bosh("upload release", upload_release),
  0 = bosh("--deployment ../manifests/cf-mongooseim-" ++ aws_or_lite(BoshTarget, "aws", "lite") ++ ".yml deploy", deploy).

get_mongooseim_nodes(BoshTarget) ->
  case BoshTarget of
    "192.168.50.4" ->
      ok;
    _ ->
      start_ssh_tunnel()
  end,

  inets:start(),
  Headers = auth_header("admin", "admin"),

  Host =  aws_or_lite(BoshTarget, "localhost:8081", "10.244.3.46:8080"),

  {ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} =
   httpc:request(get, {"http://" ++ Host ++ "/api/topo/node", Headers}, [], []),
  Body.

start_ssh_tunnel() ->
  run("ssh -N -L localhost:8081:10.244.3.46:8080 vcap@" ++ os:getenv("BOSH_TARGET"), 1000).

auth_header(User, Pass) ->
  Encoded = base64:encode_to_string(lists:append([User,":",Pass])),
  [{"Authorization","Basic " ++ Encoded}].

bosh(Cmd, BoshCmd) ->
  run("bosh --non-interactive " ++ Cmd, BoshCmd).

run(Cmd, BoshCmd) ->
  run(Cmd, 600000, BoshCmd).

run(Cmd, Timeout, BoshCmd) ->
  Port = erlang:open_port({spawn, Cmd},[exit_status]),
  loop(Port, Timeout, BoshCmd).

loop(Port, Timeout, BoshCmd) ->
  receive
    {Port, {exit_status, S}} ->S
  after Timeout ->
    {timeout, BoshCmd}
  end.

aws_or_lite("192.168.50.4", _Aws, Lite) ->
  Lite;
aws_or_lite(_, Aws, _Lite) ->
  Aws.