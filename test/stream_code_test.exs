defmodule StreamCodeTest do
  use ExUnit.Case
  use ExUnitProperties

  property "duck, duck, goose!" do
    check all code <- StreamCode.unfold_string([], &data/1, &next/2) do
      Code.eval_string(code, [], __ENV__)
    end
  end

  defp data(stack) do
    [:duck, :goose]
    |> one_of()
    |> filter(fn value -> value == :duck or :duck in stack end, 20)
  end

  defp next(:duck, stack) do
    quoted =
      quote location: :keep do
        refute :goose in unquote(stack)
        IO.write("duck ")
      end
    {quoted, [:duck | stack]}
  end
  defp next(:goose, stack) do
    quoted =
      quote location: :keep do
        assert :duck in unquote(stack)
        IO.write("goose!\n")
      end
    {quoted, []}
  end
end
