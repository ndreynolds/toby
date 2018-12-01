# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :toby,
  # This sets the default environment used by `mix release`
  default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"gjHEQMA/CJk&PfwOH8ar|fY,vl>%f6YBhv5k&XLIqX31gJy6p,ST~pC1xf3Lx<Yg")
  set(vm_args: "rel/vm.args")
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :toby do
  set(version: current_version(:toby))

  set(
    applications: [
      :runtime_tools
    ]
  )
end
