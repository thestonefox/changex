defmodule Changex.Formatter.Elixir do
  use Changex.Formatter

  @moduledoc """
  Format changelog to the terminal in markdown format that matches the
  format of the elixir-lang changelog
  """

  @doc """
  Take a map of commits in the following format:

      %{
        fix: %{
          scope1: [commit1, commit2],
          scope2: [commit5, commit6]
        }
        feat: %{
          scope1: [commit3, commit4],
          scope2: [commit7, commit8]
        }
      }

  And return a string in the format:

      ## v0.0.1

       *  Enhancements
        * [Scope 1] commit 1
        * [Scope 1] commit 2
        * [Scope 2] commit 5
        * [Scope 2] commit 6
       *  Bug fixes
        * [Scope 1] commit 3
        * [Scope 1] commit 4
        * [Scope 2] commit 7
        * [Scope 2] commit 8

  """
  def format(commits, options \\ []) do
    heading(Keyword.get(options, :version)) <> types(commits)
  end

  defp heading(version) do
    "## #{(version || current_version)}\n\n"
  end

  defp types(commits) do
    valid_types
    |> Enum.filter(fn (type) -> Dict.get(commits, type) end)
    |> Enum.map(fn (type) -> build_type(type, Dict.get(commits, type)) end)
    |> Enum.join("\n")
  end

  defp build_type(type, commits) when is_map(commits) do
    "* #{type |> lookup_type}" <> build_commits(commits)
  end
  defp build_type(type, _), do: nil

  defp build_commits(commits) do
    commits
    |> Enum.map(&build_commit_scope/1)
    |> Enum.join("")
  end

  defp build_commit_scope({scope, commits}) do
    commits
    |> Enum.reduce("", fn (commit, acc) -> build_commit(commit, scope, acc) end)
  end

  defp build_commit(commit, scope, acc) do
    description = Keyword.get(commit, :description) |> String.split("\n") |> Enum.join("\n    ")
    acc <> "\n  * [#{scope}] #{description}"
  end

  defp valid_types, do: [:feat, :fix, :break]

  defp lookup_type(:fix), do: "Bug fixes"
  defp lookup_type(:feat), do: "Enhancements"
  defp lookup_type(:break), do: "Breaking changes"

end
