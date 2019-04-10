defmodule Playground.Repository.SchemaServer do
  @moduledoc """
  The Schema/Table Map Server is responsible for holding an ETS
  table to be used by the Adapter, in order to hold mappings
  between Schema modules and their backing ETS table references.
  """

  use GenServer
  alias Playground.Repository.TableServer
  alias Playground.Repository.TableServerStarter

  def start_link(repo) do
    GenServer.start_link(__MODULE__, repo)
  end

  def reference_for(repo) do
    {__MODULE__, repo, table_name_for(repo)}
  end

  def init(repo) do
    table_name = table_name_for(repo)
    table_options = [:set, :public, :named_table, {:read_concurrency, true}]
    table_reference = :ets.new(table_name, table_options)
    {:ok, table_reference}
  end

  def get_table(reference, schema) do
    {_, _, table_name} = reference

    case :ets.lookup(table_name, schema) do
      [{_, schema_table_reference}] -> schema_table_reference
      [] -> start_table(reference, schema)
    end
  end

  defp start_table(reference, schema) do
    {_, _, table_name} = reference
    {:ok, pid} = TableServerStarter.ensure_table_started(schema)
    {:ok, table} = TableServer.get_table(pid)

    if :ets.insert_new(table_name, {schema, table}) do
      _ = Process.link(pid)
      table
    else
      GenServer.stop(pid)
      get_table(table_name, schema)
    end
  end

  defp table_name_for(repo) do
    Module.concat([__MODULE__, repo])
  end
end
