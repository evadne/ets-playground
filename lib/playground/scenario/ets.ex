defmodule Playground.Scenario.ETS do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: use an ETS table.
    Data: {integer}

    Tasks:
      - Bulk Load of <count> items (in one go)
      - Concurrent Load of <count> items
      - Sequential Read of <count> items
      - Randomised Read of <count> items
      - Sequential Update Counter
      - Sequential Update Element
      - Sequential Lookup Element + Update Element
    """
  end

  def scenario_arguments do
    [StreamData.tuple({StreamData.integer()})]
  end

  def scenario_iteration(count, stream, options \\ []) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")

    table_options =
      case Keyword.get(options, :concurrent, false) do
        true -> [:set, :public, {:read_concurrency, true}, {:write_concurrency, true}]
        false -> [:set, :public]
      end

    run_tasks("Bulk Load", 1, fn _ ->
      table_ref = :ets.new(__MODULE__, table_options)

      data =
        Stream.map(Stream.zip(1..count, stream), fn {key, values} ->
          List.to_tuple([key | Tuple.to_list(values)])
        end)
        |> Enum.take(count)

      :ets.insert(table_ref, data)
    end)

    table_ref = :ets.new(__MODULE__, table_options)

    run_tasks("Concurrent Load", count, fn x ->
      [value] = Enum.take(stream, 1)
      tuple = List.to_tuple([x | Tuple.to_list(value)])
      :ets.insert(table_ref, tuple)
    end)

    run_tasks("Sequential Read", count, fn x ->
      :ets.lookup(table_ref, x)
    end)

    run_tasks("Random Read", random_count(count), fn x ->
      :ets.lookup(table_ref, x)
    end)

    run_tasks("Sequential Update Counter", count, fn x ->
      :ets.update_counter(table_ref, x, {2, 1})
    end)

    run_tasks("Sequential Update Element", count, fn x ->
      :ets.update_element(table_ref, x, {2, 0})
    end)

    run_tasks("Sequential Lookup Element + Update Element", count, fn x ->
      element = :ets.lookup_element(table_ref, x, 2)
      :ets.update_element(table_ref, x, {2, element})
    end)
  end
end
