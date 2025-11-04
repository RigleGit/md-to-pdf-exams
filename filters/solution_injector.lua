local function has_class(el, class)
  if not el.classes then
    return false
  end
  for _, cls in ipairs(el.classes) do
    if cls == class then
      return true
    end
  end
  return false
end

local function load_solutions(path)
  solutions = {}
  local file = io.open(path, "r")
  if not file then
    io.stderr:write("[solution_injector] No se pudo abrir el archivo de soluciones: " .. path .. "\n")
    return
  end
  local content = file:read("*a")
  file:close()

  local solution_doc = pandoc.read(
    content,
    "markdown+tex_math_dollars+tex_math_single_backslash+fenced_divs"
  )
  for _, block in ipairs(solution_doc.blocks) do
    if block.t == "Div" and block.identifier ~= "" and has_class(block, "solution") then
      solutions[block.identifier] = block
    end
  end
end

local function meta_bool(val)
  if not val then
    return false
  end
  if type(val) == "boolean" then
    return val
  end
  if type(val) == "table" and val.t == "MetaBool" then
    return val.boolean
  end
  local s = pandoc.utils.stringify(val)
  s = s:lower()
  return not (s == "" or s == "false" or s == "0" or s == "no")
end

function Pandoc(doc)
  local answers_enabled = meta_bool(doc.meta["answers"])
  local meta_path = doc.meta["solutions-file"]
  if answers_enabled and meta_path then
    local path = pandoc.utils.stringify(meta_path)
    load_solutions(path)
  end

  local new_blocks = pandoc.List()

  for _, blk in ipairs(doc.blocks) do
    if blk.t == "Div" and blk.identifier ~= "" and has_class(blk, "solution-placeholder") then
      if answers_enabled then
        local sol = solutions[blk.identifier]
        if sol then
          new_blocks:insert(sol:clone())
        else
          io.stderr:write("[solution_injector] No se encontró solución para el id: " .. blk.identifier .. "\n")
          new_blocks:insert(blk)
        end
      else
        -- No answers: simplemente omitimos el placeholder.
      end
    else
      new_blocks:insert(blk)
    end
  end

  doc.blocks = new_blocks
  return doc
end
local solutions = {}
