defmodule Playground.Repository.TableServerStarter do
  alias Playground.Repository.TableServer
  alias Playground.Repository.TableSupervisor

  def ensure_table_started(schema) do
    name = TableServer.name_for(schema)

    case GenServer.whereis(name) || start_table(schema) do
      target when is_pid(target) -> {:ok, target}
      {:ok, pid} -> {:ok, pid}
      {:ok, pid, _info} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      _ -> :error
    end
  end

  defp start_table(schema) do
    DynamicSupervisor.start_child(TableSupervisor, {TableServer, schema})
  end
end
