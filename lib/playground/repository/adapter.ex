defmodule Playground.Repository.Adapter do
  @behaviour Ecto.Adapter

  alias Playground.Repository.SchemaServer
  alias Playground.Repository.Supervisor

  defmodule Meta do
    defstruct schema_server_reference: nil
  end

  defmacro __before_compile__(_opts), do: :ok
  def ensure_all_started(_config, _type), do: {:ok, []}

  def init(config) do
    schema_server_repo = Keyword.get(config, :repo)
    schema_server_reference = SchemaServer.reference_for(schema_server_repo)
    child_spec = Supervisor.child_spec(config)
    adapter_meta = %Meta{schema_server_reference: schema_server_reference}
    {:ok, child_spec, adapter_meta}
  end

  def checkout(_, _, fun), do: fun.()

  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(:embed_id, type), do: [Ecto.UUID, type]
  def loaders(_, type), do: [type]

  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(:embed_id, type), do: [type, Ecto.UUID]
  def dumpers(_, type), do: [type]

  defp get_table(adapter_meta, schema) do
    adapter_meta.schema_server_reference
    |> SchemaServer.get_table(schema)
  end

  use __MODULE__.Behaviour.Schema
  use __MODULE__.Behaviour.Queryable
end
