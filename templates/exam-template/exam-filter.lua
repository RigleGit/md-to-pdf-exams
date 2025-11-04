function Div(el)
  if el.classes == nil or #el.classes == 0 then
    return nil
  end

  local class = el.classes[1]

  if class == "solution" then
    local blocks = pandoc.List()
    blocks:insert(pandoc.RawBlock("latex", "\\begin{solution}"))
    for _, item in ipairs(el.content) do
      blocks:insert(item)
    end
    blocks:insert(pandoc.RawBlock("latex", "\\end{solution}"))
    return blocks
  end

  return nil
end

function Str(e)
  if e.text == "@q" then
    return pandoc.RawInline("latex", "\\question")
  elseif e.text == "@p" then
    return pandoc.RawInline("latex", "\\part")
  else
    return e
  end
end
