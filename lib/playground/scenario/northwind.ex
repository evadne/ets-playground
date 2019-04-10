defmodule Playground.Scenario.Northwind do
  use Playground.Scenario

  def scenario_type do
    :oneshot
  end

  def scenario_banner do
    """
    ETS backed Ecto interactions with Northwind Database as an example.
    
    Scenarios:
    
    - List all Employees
    - Insert / Delete Employee
    - Ingestion from JSON files
    - List all Employees Again
    - Select with Bound ID
    - Where
    - Select Where
    - Select / Update
    - Assoc Traversal
    - Promote to Customer
    - Stream Employees
    - Order / Shipper / Orders Preloading
    """
  end

  def scenario_arguments do
    []
  end

  alias Playground.Northwind.Model
  alias Playground.Northwind.Repo

  import Ecto.Query

  defmacrop situation(_title, do: block) do
    quote do
      # IO.puts(unquote(title))
      unquote(block)
    end
  end

  def scenario_iteration do
    situation "List all Employees" do
      Repo.all(Model.Employee)
    end

    situation "Insert / Delete Employee" do
      changes = %{first_name: "Evadne", employee_id: 1024}
      changeset = Model.Employee.changeset(changes)
      {:ok, employee} = Repo.insert(changeset)
      Repo.delete(employee)
    end

    situation "Ingestion from JSON files" do
      :ok = Playground.Northwind.Importer.perform()
    end

    situation "List all Employees Again" do
      Repo.all(Model.Employee)
    end

    situation "Select with Bound ID" do
      Repo.get(Model.Employee, 2)
    end

    situation "Where" do
      Model.Employee
      |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
      |> Repo.all()
    end

    situation "Select Where" do
      Model.Employee
      |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
      |> select([x], x.last_name)
      |> Repo.all()
    end

    situation "Select / Update" do
      Model.Employee
      |> where([x], x.title == "Vice President Sales")
      |> Repo.all()
      |> List.first()
      |> Model.Employee.changeset(%{title: "SVP Sales"})
      |> Repo.update()
    end

    situation "Assoc Traversal" do
      Model.Employee
      |> Repo.get(5)
      |> Ecto.assoc(:reports)
      |> Repo.all()
      |> List.first()
      |> Ecto.assoc(:manager)
      |> Repo.one()
      |> Ecto.assoc(:reports)
      |> Repo.all()
    end

    situation "Promote to Customer" do
      Model.Employee
      |> where([x], x.title == "SVP Sales" and x.first_name == "Andrew")
      |> Repo.one()
      |> Model.Employee.changeset(%{title: "Customer"})
      |> Repo.update()
    end

    situation "Stream Employees" do
      Model.Employee
      |> Repo.stream()
      |> Enum.to_list()
    end

    situation "Order / Shipper / Orders Preloading" do
      Model.Order
      |> Repo.all()
      |> Repo.preload(shipper: :orders)
    end
  end
end
