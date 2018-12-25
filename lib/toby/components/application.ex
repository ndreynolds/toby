defmodule Toby.Components.Application do
  @moduledoc """
  A component for displaying information about OTP applications
  """

  @behaviour Toby.Component.Stateful

  import ExTermbox.Constants, only: [color: 1, key: 1]
  import ExTermbox.Renderer.View

  alias ExTermbox.Event

  alias Toby.Components.StatusBar
  alias Toby.Stats.Server, as: Stats

  @style_selected %{
    color: color(:black),
    background: color(:white)
  }

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  def handle_event(
        %Event{ch: ch, key: key},
        %{application_cursor: cursor, applications: applications} = state
      )
      when ch == ?j or key == @arrow_down do
    {:ok, %{state | application_cursor: min(cursor + 1, length(applications) - 1)}}
  end

  def handle_event(
        %Event{ch: ch, key: key},
        %{application_cursor: cursor} = state
      )
      when ch == ?k or key == @arrow_up do
    {:ok, %{state | application_cursor: max(cursor - 1, 0)}}
  end

  def handle_event(_event, state), do: {:ok, state}

  def tick(state) do
    applications = Stats.fetch!(:applications)
    cursor = state[:application_cursor] || 0
    selected_key = Enum.at(applications, cursor)

    {:ok,
     %{
       applications: applications,
       selected_application: Stats.fetch!({:application, selected_key}),
       application_cursor: cursor
     }}
  end

  def render(%{
        applications: apps,
        application_cursor: cursor,
        selected_application: selected
      }) do
    status_bar = StatusBar.render(%{selected: :application})

    view(bottom_bar: status_bar) do
      row do
        column(size: 6) do
          panel(title: "Applications") do
            table do
              for {app, i} <- Enum.with_index(apps) do
                table_row(
                  if(cursor == i, do: @style_selected, else: %{}),
                  [to_string(app)]
                )
              end
            end
          end
        end

        column(size: 6) do
          panel(title: app_title(selected)) do
            render_app_details(selected)
          end
        end
      end
    end
  end

  defp render_app_details(nil) do
    label("(No Application)")
  end

  defp render_app_details(%{process_tree: tree}) when is_tuple(tree) do
    element(:tree, [to_tree_node(tree)])
  end

  defp render_app_details(_app_without_tree) do
    label("(Application has no master process)")
  end

  def app_title(%{name: name}), do: to_string(name)
  def app_title(_other), do: ""

  defp to_tree_node({pid_or_name, children}) do
    element(
      :tree_node,
      %{content: format_node(pid_or_name)},
      for(child <- children, do: to_tree_node(child))
    )
  end

  defp format_node(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> to_string()
  end

  defp format_node(port) when is_port(port) do
    inspect(port)
  end

  defp format_node(name) when is_atom(name) do
    to_string(name)
  end
end
