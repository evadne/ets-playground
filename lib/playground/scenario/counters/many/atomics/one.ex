defmodule Playground.Scenario.Counters.Many.Atomics.One do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: Deeper Comparison of various Atomics access patterns

    Tasks:

    - Sequentially update a <count>-arity atomics (sequential, ordered)
    - Sequentially update a <count>-arity atomics (sequential, randomised)
    - Concurrently update a <count>-arity atomics (concurrent, sequential, unordered tasks)
    - Concurrently update a <count>-arity atomics (concurrent, sequential, ordered tasks)
    - Concurrently update a <count>-arity atomics (concurrent, randomised, unordered tasks)
    - Concurrently update a <count>-arity atomics (concurrent, randomised, ordered tasks)
    """
  end

  def scenario_arguments do
    []
  end

  def scenario_iteration(count) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("sequential, ordered atomics:add/3", 1, fn _ ->
      for _ <- 1..count do
        :atomics.add(atomics_ref, count, 1)
      end
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("sequential, randomised atomics:add/3", 1, fn _ ->
      for x <- random_count(count) do
        :atomics.add(atomics_ref, x, 1)
      end
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("concurrent, sequential, unordered atomics:add/3", count, fn x ->
      :atomics.add(atomics_ref, x, 1)
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("concurrent, sequential, ordered atomics:add/3", count, [ordered: true], fn x ->
      :atomics.add(atomics_ref, x, 1)
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks("concurrent, randomised, unordered atomics:add/3", random_count(count), fn x ->
      :atomics.add(atomics_ref, x, 1)
    end)

    atomics_ref = :atomics.new(count, signed: false)

    run_tasks(
      "concurrent, randomised, ordered atomics:add/3",
      random_count(count),
      [ordered: true],
      fn x ->
        :atomics.add(atomics_ref, x, 1)
      end
    )
  end
end
