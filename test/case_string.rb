testcase String do

  test "tabto indents to a column" do
    "a\n  b".tabto(4).assert == "    a\n      b"
  end

  test "tabto can reduce the indentation" do
    "    a\n      b".tabto(2).assert == "  a\n    b"
  end

end
