local iterations = 10000
local how_many_times_for_average = 10

local exampleTests = {

  ["Hash"] = {
    {
      name = "Joaat",
      func = function()
        local wep = joaat("weapon_pistol")
      end
    },
    {
      name = "Hash",
      func = function()
        local wep = GetHashKey("weapon_pistol")
      end
    },
    {
      name = "Backticks (`)",
      func = function()
        local wep = `weapon_pistol`
      end
    }
  },

  ["Concat"] = {
    {
      name = "..",
      func = function()
        local str = "Hello"
        str = str .. " World"
      end
    },
    {
      name = "string.format",
      func = function()
        local str = "Hello"
        str = string.format("%s %s", str, "World")
      end
    },
    {
      name = "('%s'):format()",
      func = function()
        local str = "Hello"
        str = ("%s %s"):format(str, "World")
      end
    },
    {
      name = "table.concat",
      func = function()
        local str = {"Hello"}
        table.insert(str, "World")
        table.concat(str, " ")
      end
    }
  },

  ["Insert"] = {
    {
      name = "table.insert",
      func = function()
        local tbl = {}
        table.insert(tbl, i)
      end
    },
    {
      name = "Insert with pre-allocated size",
      func = function()
        local tbl = {}
        tbl[1] = 1
      end
    },
    {
      name = "Insert with next available index",
      func = function()
        local tbl = {}
        tbl[#tbl + 1] = i
      end
    }
  },
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
  self.tests[data.name] = data.func
end

function benchmarkF:execute()
  for name, func in pairs(self.tests) do

    self.results[name] = self.results[name] or {}
    self.results[name].times = {}

    for i = 1, how_many_times_for_average do

      local time = os.nanotime()

      for i = 1, iterations do
        func()
      end

      local time2 = os.nanotime()

      table.insert(self.results[name].times, time2 - time)

    end

    self.results[name].total = 0

    for i = 1, #self.results[name].times do
      self.results[name].total += self.results[name].times[i]
    end

    self.results[name].average = self:nanoToMilliseconds(self.results[name].total / #self.results[name].times)
  end
  return self.results
end

function benchmarkF:nanoToMilliseconds(nano)
  local secs = nano / 1000000
  -- to 5 decimal places
  return string.format("%.5f", secs)
end

function benchmarkF:print(results)
  local leaderboard = {}
  for name, data in pairs(self.results) do
    table.insert(leaderboard, {name = name, data = data})
  end

  table.sort(leaderboard, function(a, b)
    return a.data.average < b.data.average
  end)

  for i = 2, #leaderboard do
    local diff = leaderboard[1].data.average - leaderboard[i].data.average
    local percentage = diff / leaderboard[1].data.average * 100
    leaderboard[i].data.percentage = math.abs(percentage)
  end

  print("Total tests: " .. #leaderboard .. ". Total iterations: " .. iterations .. ". Total average runs: " .. how_many_times_for_average .. ".")
  print("Results:")
  print("   1. " .. leaderboard[1].name .. " took an average of " .. leaderboard[1].data.average .. " milliseconds to run " .. iterations .. " times. ^2(Fastest)^7")
  for i = 2, #leaderboard do
    print("   " .. i .. ". " .. leaderboard[i].name .. " took an average of " .. leaderboard[i].data.average .. " milliseconds to run " .. iterations .. " times. (" .. leaderboard[i].data.percentage .. "% slower than the fastest)")
  end
end

function benchmarkF:run()
  self:execute()
  self:print()
end

local test = setmetatable({
  results = {},
  tests = {},
}, benchmarkF)

local selectedTest = "Insert"
if not exampleTests[selectedTest] then
  print("Test not found")
  return
end
for i = 1, #exampleTests[selectedTest] do
  test:add(exampleTests[selectedTest][i])
end

test:run()
