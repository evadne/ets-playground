defmodule Playground.Scenario do
  require Logger

  @type scenario_type_oneshot :: :oneshot
  @type scenario_type_iterations :: {:iterations, Stream.t()}
  @type scenario_type :: scenario_type_oneshot | scenario_type_iterations

  @callback scenario_banner() :: String.t()
  @callback scenario_type() :: scenario_type
  @callback scenario_arguments() :: [term()]

  defmacro __using__(_) do
    module = __MODULE__

    quote do
      @behaviour unquote(module)
      import unquote(module).Helpers

      def run do
        unquote(module).Runner.run(__MODULE__)
      end
    end
  end
end
