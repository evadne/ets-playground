defmodule Playground.Scenario.Runner do
  def run(target) do
    IEx.Helpers.clear()
    IO.puts("")
    IO.puts(target.scenario_banner())

    case target.scenario_type() do
      {:iterations, iteration_stream} ->
        run_iterations(target, iteration_stream)

      :oneshot ->
        run_iteration(target, target.scenario_arguments())
    end
  end

  defp run_iterations(target, iteration_stream) do
    iteration_fun = fn iteration ->
      arguments = [iteration | target.scenario_arguments()]
      run_iteration(target, arguments)
    end

    iteration_stream
    |> Stream.each(iteration_fun)
    |> Stream.run()

    IO.puts("")
  end

  def run_iteration(target, arguments) do
    Playground.TaskSupervisor
    |> Task.Supervisor.async_nolink(target, :scenario_iteration, arguments)
    |> Task.await(:infinity)

    IO.write("\n")
  end
end
