require 'busted.runner'()

describe("template module", function()
  local template = require('template')

  describe("template processing", function()
    it("processes simple template", function()
      local func = template.compile("Hello, <%= name %>!")
      local output = {}
      template.print(func, { name = "World" }, function(s) table.insert(output, s) end)
      assert.equal("Hello, World!", table.concat(output, ""))
    end)

    it("processes conditional template", function()
      local func = template.compile("<? if name then ?>Hello, <%= name %>!<? else ?>Guest<? end ?>")
      local output = {}
      template.print(func, { name = "World" }, function(s) table.insert(output, s) end)
      assert.equal("Hello, World!", table.concat(output, ""))
    end)

    it("minial template is functional", function()
      -- Add some spaces
      local func = template.compile([[

        <? for i = 1, max do ?>.<?end?>

      ]], true)
      local output = {}
      template.print(func, { max = 10 }, function(s) table.insert(output, s) end)
      assert.equal(" .......... ", table.concat(output, ""))
    end)

    it("xml escaping", function()
      local data = { chars = { '&', '<', '>', '"', "'", '/' } }
      local func = template.compile([[<? for i, v in ipairs(chars) do ?><% v %><? end ?>]], true)
      local output = {}
      template.print(func, data, function(s) table.insert(output, s) end)
      assert.equal("&amp;&lt;&gt;&quot;&#39;&#47;", table.concat(output, ""))
    end)

    it("big template rendering", function()
      local fd = assert(io.open("./test/dir_page.ltpl", "r"))
      local content = assert(fd:read("*a"))
      fd:close()
      local func = template.compile(content, true)
      local data = {
        path="/", 
        files={ 
          {css_class="directory"; href="/"; filename="."; size=0; size="0B"; time="1970-01-01 00:00:00"}
        }
      }
      local output={}
      template.print(func, data, function(s) table.insert(output, s) end)
      print(table.concat(output))
    end)

    it("errors on invalid template", function()
      assert.has_error(function()
        template.compile("<%= ) %>")
      end)
    end)
  end)
end)
