defmodule Playground.Scenario.Data do
  use Playground.Scenario

  def scenario_type do
    {:iterations, Stream.map(10..20, &round(:math.pow(2, &1)))}
  end

  def scenario_banner do
    """
    Scenario: Read constants from Module
    Data: {integer, binary}

    Tasks:
      - Build Module with <count> items, based on List
      - Sequential Read of <count> items
      - Randomised Read of <count> items
      - Build Module with <count> items, based on Map
      - Sequential Read of <count> items
      - Randomised Read of <count> items
    """
  end

  def scenario_arguments do
    [StreamData.binary()]
  end

  def scenario_iteration(count, stream) do
    IO.write("#{String.pad_leading(Integer.to_string(count), 11)}:")

    data =
      Stream.map(Stream.zip(1..count, stream), fn {key, value} ->
        {key, value}
      end)
      |> Enum.take(count)

    module_name = Module.concat([__MODULE__, Data, "ListWith#{count}"])

    run_tasks("Build Module", 1, fn _ ->
      {:ok, _} = build_module(module_name, data)
    end)

    run_tasks("Sequential Read", count, fn x ->
      {_, value} = List.keyfind(module_name.data(), x, 0)
      value
    end)

    run_tasks("Random Read", random_count(count), fn x ->
      {_, value} = List.keyfind(module_name.data(), x, 0)
      value
    end)

    module_name = Module.concat([__MODULE__, Data, "MapWith#{count}"])
    module_data = Map.new(data)

    run_tasks("Build Module", 1, fn _ ->
      {:ok, _} = build_module(module_name, module_data)
    end)

    run_tasks("Sequential Read", count, fn x ->
      Map.get(module_name.data(), x)
    end)

    run_tasks("Random Read", random_count(count), fn x ->
      Map.get(module_name.data(), x)
    end)
  end

  defp build_module(name, data) do
    contents =
      quote do
        def data, do: unquote(Macro.escape(data))
      end

    Module.create(name, contents, Macro.Env.location(__ENV__))
    {:ok, name}
  end
end
