defmodule Playground.Repository.Adapter.Behaviour.Queryable do
  defmacro __using__(_) do
    quote do
      @behaviour Ecto.Adapter.Queryable

      def prepare(:all, query) do
        {:nocache, query}
      end

      def execute(adapter_meta, _, {:nocache, query}, params, _) do
        {_, schema} = query.from.source
        ets_table_reference = get_table(adapter_meta, schema)
        ets_match_specification = __MODULE__.MatchSpecification.build(query, params)
        ets_objects = :ets.select(ets_table_reference, [ets_match_specification])
        {length(ets_objects), ets_objects}
      end

      def stream(adapter_meta, _, {:nocache, query}, params, _) do
        {_, schema} = query.from.source
        ets_match_specification = __MODULE__.MatchSpecification.build(query, params)
        ets_table_reference = get_table(adapter_meta, schema)
        stream_start_fun = fn -> stream_start(ets_table_reference, ets_match_specification) end
        stream_next_fun = fn acc -> stream_next(acc) end
        stream_after_fun = fn acc -> stream_after(ets_table_reference, acc) end
        Stream.resource(stream_start_fun, stream_next_fun, stream_after_fun)
      end

      defp stream_start(ets_table_reference, ets_match_specification) do
        :ets.safe_fixtable(ets_table_reference, true)
        :ets.select(ets_table_reference, [ets_match_specification], 5)
      end

      defp stream_next(:"$end_of_table") do
        {:halt, :ok}
      end

      defp stream_next({objects, continuation}) do
        {[{length(objects), objects}], :ets.select(continuation)}
      end

      defp stream_after(ets_table_reference, :ok) do
        :ets.safe_fixtable(ets_table_reference, false)
      end

      defp stream_after(_, acc) do
        acc
      end
    end
  end
end
