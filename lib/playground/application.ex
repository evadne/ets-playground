defmodule Playground.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Playground.TaskSupervisor},
      Playground.Northwind.Repo
    ]

    options = [strategy: :one_for_one, name: Playground.Supervisor]
    Supervisor.start_link(children, options)
  end
end
