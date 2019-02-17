defmodule Toby.Data.Applications do
  @moduledoc """
  Utilities for gathering application data such as the process tree.
  """

  alias Toby.Data.Node

  def applications(node) do
    {:ok, applications_in_tree(node)}
  end

  def application(node, app) do
    with {:ok, data} <- Node.application(node, app) do
      app_data =
        data
        |> Enum.into(%{})
        |> Map.merge(%{name: app, process_tree: application_process_tree(node, app)})

      {:ok, app_data}
    else
      :undefined -> {:ok, nil}
    end
  end

  defp application_process_tree(node, app) do
    case application_master(node, app) do
      nil -> nil
      pid -> process_tree(node, pid, [application_controller(node)])
    end
  end

  defp process_tree(_node, port, _parents) when is_port(port) do
    {port, []}
  end

  defp process_tree(node, pid, parents) when is_pid(pid) do
    {:links, links} = Node.process_info(node, pid, :links)

    child_pids = links -- parents
    children = for child <- child_pids, do: process_tree(node, child, [pid | parents])

    case Node.process_info(node, pid, :registered_name) do
      {:registered_name, name} -> {name, children}
      _ -> {pid, children}
    end
  end

  defp application_controller(node) do
    Node.where_is(node, :application_controller)
  end

  defp application_master(node, app) do
    Enum.find(application_masters(node), fn pid ->
      case Node.application_by_pid(node, pid) do
        {:ok, ^app} -> true
        _ -> false
      end
    end)
  end

  defp application_masters(node) do
    {:links, masters} = Node.process_info(node, application_controller(node), :links)
    masters
  end

  defp applications_in_tree(node) do
    Enum.flat_map(application_masters(node), fn pid ->
      case Node.application_by_pid(node, pid) do
        {:ok, app} -> [app]
        _ -> []
      end
    end)
  end
end
