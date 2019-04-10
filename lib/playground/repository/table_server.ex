defmodule Playground.Repository.TableServer do
  use GenServer
  alias Playground.Repository.TableServerRegistry

  def name_for(table_name) do
    {:via, Registry, {TableServerRegistry, table_name}}
  end

  def get_table(pid) when is_pid(pid) do
    GenServer.call(pid, :get_table)
  end

  def start_link(table_name) do
    GenServer.start_link(__MODULE__, table_name, name: name_for(table_name))
  end

  def init(table_name) do
    {:ok, :ets.new(table_name, [:set, :public])}
  end

  def handle_call(:get_table, _, state) do
    {:reply, {:ok, state}, state}
  end
end
