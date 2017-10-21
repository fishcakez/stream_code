defmodule StreamCodeTest do
  use ExUnit.Case
  use ExUnitProperties

  property "duck, duck, goose!" do
    check all code <- StreamCode.unfold_string([], &dg_data/1, &dg_next/2) do
      Code.eval_string(code, [], __ENV__)
    end
  end

  defp dg_data(stack) do
    [:duck, :goose]
    |> one_of()
    |> filter(fn value -> value == :duck or :duck in stack end, 20)
  end

  defp dg_next(:duck, stack) do
    quoted =
      quote location: :keep do
        refute :goose in unquote(stack)
        IO.write("duck ")
      end
    {quoted, [:duck | stack]}
  end
  defp dg_next(:goose, stack) do
    quoted =
      quote location: :keep do
        assert :duck in unquote(stack)
        IO.write("goose!\n")
      end
    {quoted, []}
  end

  property "async then await" do
    check all code <- StreamCode.unfold_string(nil, &task_data/1, &task_next/2) do
      Code.eval_string(code, [], __ENV__)
    end
  end

  defp task_data(nil),
    do: tuple({constant(:async), integer()})
  defp task_data({task, _}),
    do: constant({:await, task})

  defp task_next({:async, i}, _) do
    var = Macro.var(:task, __MODULE__)
    quoted =
      quote do
        unquote(var) = Task.async(fn -> unquote(i) end)
      end
    {quoted, {var, i}}
  end
  defp task_next({:await, var}, {var, i}) do
    quoted =
      quote do
        assert Task.await(unquote(var)) == unquote(i)
      end
    {quoted, nil}
  end
end
