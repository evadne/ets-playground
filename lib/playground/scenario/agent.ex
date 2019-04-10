defmodule Playground.Scenario.Agent do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: use an Agent which holds a Map with integer keys.
    Data: {integer}

    Tasks:
      - Bulk Load of <count> items
      - Concurrent Load of <count> items
      - Sequential Read of <count> items
      - Randomised Read of <count> items
      - Sequential Update of <count> items, incrementing the integer
    """
  end

  def scenario_arguments do
    [StreamData.tuple({StreamData.integer()})]
  end

  def scenario_iteration(count, stream) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}: ")

    run_tasks("Bulk Load", 1, fn _ ->
      {:ok, pid} = Agent.start_link(fn -> %{} end)

      data =
        Stream.map(Stream.zip(1..count, stream), fn {key, values} ->
          List.to_tuple([key | Tuple.to_list(values)])
        end)
        |> Enum.take(count)
        |> Map.new()

      Agent.update(pid, fn _ -> data end)
    end)

    {:ok, pid} = Agent.start_link(fn -> %{} end)

    run_tasks("Concurrent Load", count, fn x ->
      Agent.update(pid, fn data ->
        [value] = Enum.take(stream, 1)
        Map.put(data, x, value)
      end)
    end)

    run_tasks("Sequential Read", count, fn x ->
      Agent.get(pid, fn data -> Map.get(data, x) end)
    end)

    run_tasks("Random Read", random_count(count), fn x ->
      Agent.get(pid, fn data -> Map.get(data, x) end)
    end)

    run_tasks("Sequential Get & Update", count, fn x ->
      Agent.get(pid, fn data ->
        Map.update!(data, x, fn value ->
          element = elem(value, 0)
          put_elem(value, 0, element + 1)
        end)
      end)
    end)
  end
end
