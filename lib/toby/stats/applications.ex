defmodule Toby.Stats.Applications do
  @moduledoc """
  Utilities for gathering application data such as the process tree.
  """

  def applications do
    apps = for {app, _desc, _vsn} <- :application.loaded_applications(), do: app

    {:ok, apps}
  end

  def application(app) do
    with {:ok, data} <- :application.get_all_key(app) do
      app_data =
        data
        |> Enum.into(%{})
        |> Map.merge(%{name: app, process_tree: application_process_tree(app)})

      {:ok, app_data}
    else
      :undefined -> {:ok, nil}
    end
  end

  def application_process_tree(app) do
    case application_master(app) do
      nil -> nil
      pid -> process_tree(pid, [application_controller()])
    end
  end

  defp process_tree(port, _parents) when is_port(port) do
    {port, []}
  end

  defp process_tree(pid, parents) when is_pid(pid) do
    {:links, links} = process_info(pid, :links)

    child_pids = links -- parents
    children = for child <- child_pids, do: process_tree(child, [pid | parents])

    case process_info(pid, :registered_name) do
      {:registered_name, name} -> {name, children}
      _ -> {pid, children}
    end
  end

  defp application_controller, do: :erlang.whereis(:application_controller)

  defp application_master(app) do
    {:links, app_masters} = process_info(application_controller(), :links)

    Enum.find(app_masters, fn pid ->
      case :application.get_application(pid) do
        {:ok, ^app} -> true
        _ -> false
      end
    end)
  end

  defp process_info(pid, key), do: :erlang.process_info(pid, key)
end
