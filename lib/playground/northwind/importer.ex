defmodule Playground.Northwind.Importer do
  alias Playground.Northwind.{Model, Repo}

  @otp_app Mix.Project.config()[:app]
  @models [
    Model.Category,
    Model.Customer,
    Model.Employee,
    Model.Order,
    Model.Product,
    Model.Shipper,
    Model.Supplier
  ]

  def perform do
    for model <- @models, do: perform(model)
    :ok
  end

  def perform(model) do
    {:ok, representations} = load_representations(model)
    {:ok, changesets} = build_changesets(model, representations)

    for changeset <- changesets do
      {:ok, entity} = Repo.insert(changeset)
      entity
    end
  end

  defp load_representations(model) do
    with file_path_fragment = "priv/northwind/#{model.__schema__(:source)}.json",
         file_path <- Application.app_dir(@otp_app, file_path_fragment),
         {:ok, file_content} <- File.read(file_path),
         {:ok, representations} <- Jason.decode(file_content) do
      {:ok, representations}
    end
  end

  defp transform(key, value) do
    {transform_key(key), transform_value(value)}
  end

  defp transform_key(key) do
    key
    |> Macro.underscore()
    |> String.replace_suffix("_i_ds", "_ids")
  end

  defp transform_value(value) when is_map(value) do
    for {vk, vv} <- value, into: %{}, do: transform(vk, vv)
  end

  defp transform_value(value) do
    value
  end

  defp build_changesets(model, representations) do
    changeset_params = Enum.map(representations, &transform_value/1)
    changesets = Enum.map(changeset_params, &model.changeset/1)
    {:ok, changesets}
  end
end
