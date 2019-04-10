defmodule Playground.Scenario.Helpers do
  def run_tasks(name, target, options \\ [], task_fun)

  def run_tasks(name, count, options, task_fun) when is_integer(count) do
    run_tasks(name, 1..count, options, task_fun)
  end

  def run_tasks(_name, enum, options, task_fun) do
    task_concurrency = 1 * System.schedulers_online()
    task_options = [ordered: false, max_concurrency: task_concurrency, timeout: :infinity]
    task_options = Keyword.merge(task_options, options)
    task_stream = Task.async_stream(enum, task_fun, task_options)
    {time, _} = :timer.tc(fn -> Stream.run(task_stream) end)
    time_seconds = time / 1_000_000
    time_label = :erlang.float_to_binary(time_seconds, decimals: 2)
    time_label_padded = String.pad_leading(time_label, 8)
    IO.write("#{time_label_padded}s")
  end

  def random_count(count) do
    1..count |> Enum.take_random(count)
  end
end
