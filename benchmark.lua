local iterations = 1000
local how_many_times_for_average = 10

local tests = {
  {
    name = "Joaat",
    func = function()
      joaat("weapon_pistol")
    end
  },
  {
    name = "Hash",
    func = function()
      GetHashKey("weapon_pistol")
    end
  }
}

----------------------------------
-- DO NOT TOUCH BELOW THIS LINE --
----------------------------------

local results = {}

local benchmarkF = {}
benchmarkF.__index = benchmarkF

local benchmark = setmetatable({}, benchmarkF)

function benchmarkF:add(data)
  assert(data.name, "Name is required")
  assert(data.func, "Function is required")
  assert(type(data.name) == "string", "Name must be a string")
  assert(type(data.func) == "function", "Function must be a function")
  self[data.name] = data.func
end

function benchmarkF:run()

  results = {}

  for name, func in pairs(self) do

    results[name] = results[name] or {}
    results[name].times = {}

    for i = 1, how_many_times_for_average do

      local time = os.nanotime()

      for i = 1, iterations do
        func()
      end

      local time2 = os.nanotime()

      table.insert(results[name].times, time2 - time)

    end

    results[name].total = 0

    for i = 1, #results[name].times do
      results[name].total += results[name].times[i]
    end

    results[name].average = results[name].total / #results[name].times
  end

  local str = ""

  local fastest = nil

  for name, data in pairs(results) do

    str = ("%s%s: Time taken: %s\n"):format(str, name, data.average)

    if not fastest or data.average < fastest.average then
      fastest = data
      fastest.name = name
    end

  end

  str = ("%sIterations: %s. Checked %s times. Totalling: %s total iterations per function\n"):format(str, iterations, how_many_times_for_average, iterations * how_many_times_for_average)
  str = str .. "------------------------------------\n"
  str = ("%s\n\27[30m\27[42mFastest: %s \27[0m\n"):format(str, fastest.name)
  str = str .. "------------------------------------\n"

  print(str)
end

local test = setmetatable({}, benchmarkF)

for i = 1, #tests do
  test:add(tests[i])
end

test:run()
