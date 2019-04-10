defmodule Playground.Scenario.Counters.Many do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: Comparison of Counters in ETS vs Atomics

    Tasks:

    - Sequentially update <count> ETS counters
    - Sequentially update a <count>-arity atomics
    - Concurrently update <count> ETS counters
    - Concurrently update a <count>-arity atomics
    - Concurrently get <count> ETS counters
    - Concurrently get <count> ETS counters again
    - Concurrently get <count>-arity atomics
    - Concurrently get <count>-arity atomics again
    """
  end

  def scenario_arguments do
    []
  end

  def scenario_iteration(count) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")
    table_options = [:set, :public, {:read_concurrency, true}, {:write_concurrency, true}]

    table_ref = :ets.new(__MODULE__, table_options)
    :ets.insert(table_ref, for(x <- 1..count, do: {x, 0}))

    run_tasks("Sequential ets:update_counter/3", 1, fn _ ->
      for x <- 1..count do
        :ets.update_counter(table_ref, x, {2, 1})
      end
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("Sequential atomics:add/3", 1, fn _ ->
      for _ <- 1..count do
        :atomics.add(atomics_ref, count, 1)
      end
    end)

    run_tasks("Concurrent ets:update_counter/3", count, fn x ->
      :ets.update_counter(table_ref, x, {2, 1})
    end)

    run_tasks("Concurrent atomics:add/3", 1, fn x ->
      :atomics.add(atomics_ref, x, 1)
    end)

    run_tasks("Concurrent ets:lookup_element/3", count, fn x ->
      :ets.lookup_element(table_ref, x, 2)
    end)

    run_tasks("Concurrent ets:lookup_element/3", count, fn x ->
      :ets.lookup_element(table_ref, x, 2)
    end)

    run_tasks("Concurrent atomics:get/2", count, fn x ->
      :atomics.get(atomics_ref, x)
    end)

    run_tasks("Concurrent atomics:get/2", count, fn x ->
      :atomics.get(atomics_ref, x)
    end)
  end
end
