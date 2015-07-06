defmodule XtractTest do
  use ExUnit.Case

  def example_xml do
    """
    <XML>
      <book num="Gen">
        <chapter num="1">
          <verse num="1">In the beginning God created the heaven and the earth.</verse>
        </chapter>
      </book>
    </XML>
    """
  end

  def ideal_elixir_rep do
    [%{ :book => %{ :attrs => [num: 'Gen'], :content => %{
          :chapter => %{ :attrs => [num: '1'], :content => %{
              :verse => %{ :attrs => [num: '1'], :content => "In the beginning God created the heaven and the earth." }
            }
          }
        }}}]
  end
  
  test "Xtract.Parser.parse/1 idealizes XML" do
    xtracted_data = Xtract.Parser.parse(example_xml)
    assert xtracted_data == ideal_elixir_rep()
  end

  test "Xtract.Parser.find/1 can find content" do
    node = Xtract.Parser.find(example_xml, :verse)
    assert node == "In the beginning God created the heaven and the earth."
  end
end

