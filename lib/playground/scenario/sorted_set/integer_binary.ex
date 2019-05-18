defmodule Playground.Scenario.SortedSet.IntegerBinary do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: insert into ETS Ordered Set and Discord.SortedSet.
    Data: {integer | binary (8 to 16 bytes) }
    
    Tasks: 
    
    - Insert <count> items into ETS table (Orderd Set)
    - Insert 1 more item into aforementioned ETS table
    - Insert <count> items into Discord.SortedSet
    - Insert 1 more item into aforementioned Discord.SortedSet
    """
  end

  def scenario_arguments do
    [
      StreamData.one_of([
        StreamData.integer(),
        StreamData.binary(min_length: 8, max_length: 16)
      ])
    ]
  end
  
  def scenario_iteration(count, stream, _options \\ []) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")

    table_options = [
      :ordered_set,
      :public,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ]

    table_ref = :ets.new(__MODULE__, table_options)
    sorted_set_ref = Discord.SortedSet.new()
    
    elements = Enum.take(stream, count)

    run_tasks("ETS Load", 1, fn _ ->
      for element <- elements do
        :ets.insert(table_ref, {element})
      end
    end)
    
    run_tasks("ETS Append", 1, fn _ ->
      :ets.insert(table_ref, {Enum.take(stream, 1)})
    end)

    run_tasks("SortedSet Load", 1, fn _ ->
      for element <- elements do
        Discord.SortedSet.add(sorted_set_ref, element)
      end
    end)

    run_tasks("SortedSet Append", 1, fn _ ->
      Discord.SortedSet.add(sorted_set_ref, Enum.take(stream, 1))
    end)
  end
end
