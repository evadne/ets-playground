defmodule Playground.Repository.Supervisor do
  @moduledoc """
  Supervision tree which supports the ETS Adapter. There are several
  children used in the tree:

  - a Dynamic Supervisor to hold the Table Servers
  - a Registry to keep track of the Table Servers
  - a Task Supervisor for one-off tasks
  """

  use Supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl true
  def init(config) do
    schema_server_module = Playground.Repository.SchemaServer
    table_supervisor_name = Playground.Repository.TableSupervisor
    table_registry_name = Playground.Repository.TableServerRegistry
    task_supervisor_name = Playground.Repository.TaskSupervisor
    repo = Keyword.get(config, :repo)

    children = [
      {schema_server_module, repo},
      {DynamicSupervisor, strategy: :one_for_one, name: table_supervisor_name},
      {Registry, keys: :unique, name: table_registry_name},
      {Task.Supervisor, name: task_supervisor_name}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
