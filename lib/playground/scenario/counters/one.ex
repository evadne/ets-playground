defmodule Playground.Scenario.Counters.One do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: Comparison of Counters in ETS vs Atomics

    Tasks:

    - Sequentially update an ETS counter <count> times
    - Sequentially update an 1-arity atomics <count> times
    - Concurrently update an ETS counter <count> times
    - Concurrently update an 1-arity atomics <count> times
    - Concurrently get an ETS counter <count> times
    - Concurrently get an 1-arity atomics <count> times
    """
  end

  def scenario_arguments do
    []
  end

  def scenario_iteration(count) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")
    table_options = [:set, :public, {:read_concurrency, true}, {:write_concurrency, true}]

    run_tasks("Sequential ets:update_counter/3", 1, fn _ ->
      table_ref = :ets.new(__MODULE__, table_options)
      :ets.insert(table_ref, {0, 0})

      for _ <- 1..count do
        :ets.update_counter(table_ref, 0, {2, 1})
      end
    end)

    run_tasks("Sequential atomics:add/3", 1, fn _ ->
      atomics_ref = :atomics.new(1, signed: false)

      for _ <- 1..count do
        :atomics.add(atomics_ref, 1, 1)
      end
    end)

    table_ref = :ets.new(__MODULE__, table_options)
    :ets.insert(table_ref, {0, 0})

    run_tasks("Concurrent ets:update_counter/3", count, fn _ ->
      :ets.update_counter(table_ref, 0, {2, 1})
    end)

    atomics_ref = :atomics.new(1, signed: false)

    run_tasks("Concurrent atomics:add/3", count, fn _ ->
      :atomics.add(atomics_ref, 1, 1)
    end)

    run_tasks("Concurrent ets:lookup_element", count, fn _ ->
      :ets.lookup_element(table_ref, 0, 2)
    end)

    run_tasks("Concurrent atomics:add/2", count, fn _ ->
      :atomics.get(atomics_ref, 1)
    end)
  end
end
