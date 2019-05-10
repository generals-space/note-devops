local brute = require "brute"
local creds = require "creds"
local http = require "http"
local nmap = require "nmap"
local shortport = require "shortport"
local stdnse = require "stdnse"
local string = require "string"
local table = require "table"
local url = require "url"

---
-- @usage
-- nmap --script http-form-brute -p 80 <host>
--
-- @output
-- PORT     STATE SERVICE REASON
-- 80/tcp   open  http    syn-ack
-- | http-form-brute:
-- |   Accounts
-- |     Patrik Karlsson:secret - Valid credentials
-- |   Statistics
-- |_    Perfomed 60023 guesses in 467 seconds, average tps: 138
--
-- @args http-form-brute.path identifies the page that contains the form
--       (default: "/"). The script analyses the content of this page to
--       determine the form destination, method, and fields. If argument
--       passvar is specified then the form detection is not performed and
--       the path argument is instead used as the form submission destination
--       (the form action). Use the other arguments to define the rest of
--       the form manually as necessary.
-- @args http-form-brute.method sets the HTTP method (default: "POST")
-- @args http-form-brute.hostname sets the host header in case of virtual
--       hosting
-- @args http-form-brute.uservar (optional) sets the form field name that
--       holds the username used to authenticate.
-- @args http-form-brute.passvar sets the http-variable name that holds the
--       password used to authenticate. If this argument is set then the form
--       detection is not performed. Use the other arguments to define
--       the form manually.
-- @args http-form-brute.onsuccess (optional) sets the message/pattern
--       to expect on successful authentication
-- @args http-form-brute.onfailure (optional) sets the message/pattern
--       to expect on unsuccessful authentication
-- @args http-form-brute.sessioncookies Attempt to grab session cookies before
--       submitting the form. Setting this to "false" could speed up cracking
--       against forms that do not require any cookies to be set before logging
--       in. Default: true

--

author = {"Patrik Karlsson", "nnposter"}
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"intrusive", "brute"}


portrule = shortport.port_or_service( {80, 443}, {"http", "https"}, "tcp", "open")


-- Miscellaneous script-wide constants
local max_rcount = 2    -- how many times a form submission can be redirected
local form_debug = 1    -- debug level for printing form components

---
-- Test whether a given string (presumably a HTML fragment) contains
-- a given form field
--
-- @param html The HTML string to analyze
-- @param fldname The field name to look for
-- @return Verdict (true or false)
local contains_form_field = function (html, fldname)
    for _, f in pairs(http.grab_forms(html)) do
        local form = http.parse_form(f)
        for _, fld in pairs(form.fields) do
            if fld.name == fldname then 
                return true end
        end
    end
    return false
end

local function urlencode_form(fields, uservar, username, passvar, password)
    local parts = {}
    for _, field in ipairs(fields) do
        if field.name then
        local val = field.value or ""
        if field.name == uservar then
            val = username
        elseif field.name == passvar then
            val = password
        end
        parts[#parts+1] = url.escape(field.name) .. "=" .. url.escape(val)
        end
    end
    return table.concat(parts, "&")
end

---
-- 从目标html页面中检测form对象
-- @param host HTTP host
-- @param port HTTP port
-- @param path Path for retrieving the page
-- @return 检测到的form对象(与http.parse_form()构造的对象相似), 如果没检测到返回nil
-- @return Error string that describes any failure
-- @return cookies that were set by the request
local detect_form = function (host, port, path, hostname)
    local http_get_opts = {
        bypass_cache = true,
        header = {Host = hostname}
    }
    -- http get请求, 返回response对象
    local response = http.get(host, port, path, http_get_opts)
    if not (response and response.body and response.status == 200) then
        return nil, string.format("Unable to retrieve a login form from path %q", path)
    end
    -- grab_forms(), 从响应体中检测form的存在, 返回以纯文本形式的form数据...真方便
    for _, f in pairs(http.grab_forms(response.body)) do
        -- parse_form()将纯文本形式的form格式化成form对象, 该对象将拥有action, field, id等属性.
        -- 等等...id, action应该是form元素本身的属性, 至于field, 应该是form内部组件元素的name属性数组吧.
        local form = http.parse_form(f)
        local unfld, pnfld, ptfld
        -- 一般一个fld就是一个表单域, 包含name与type属性
        for _, fld in pairs(form.fields) do
            if fld.name then
                -- 看起来fld.name不只是字符串, 还包含成员方法呢
                local name = fld.name:lower()
                if not unfld and name:match("^user") then
                    unfld = fld
                end
                -- 通过查找名称包含'pass'字符串与类型为'password'两种方式找出表单密码域
                if not pnfld and (name:match("^pass") or name:match("^key")) then
                    pnfld = fld
                end
                if not ptfld and fld.type and fld.type == "password" then
                    ptfld = fld
                end
            end
        end
        if pnfld or ptfld then
            form.method = form.method or "GET"
            form.uservar = (unfld or {}).name
            form.passvar = (ptfld or pnfld).name --类型优先啊
            return form, nil, response.cookies
        end
    end

    return nil, string.format("Unable to detect a login form at path %q", path)
end

-- Recursively copy a table.
-- Only recurs when a value is a table, other values are copied by assignment.
local function tcopy (t)
    local tc = {};
    for k,v in pairs(t) do
        if type(v) == "table" then
            tc[k] = tcopy(v);
        else
            tc[k] = v;
        end
    end
    return tc;
end

-- TODO: expire cookies
local function update_cookies (old, new)
    for i, c in ipairs(new) do
        local add = true
        for j, oc in ipairs(old) do
        if oc.name == c.name then
            old[j] = c
            add = false
            break
        end
        end
        if add then
        table.insert(old, c)
        end
    end
end

-- make sure this path is ok as a form action.
-- Also make sure we stay on the same host.
-- 确认目标form对象的action路径的有效性
local function path_ok (path, hostname, port)
    local pparts = url.parse(path)
    if pparts.authority then
        if pparts.userinfo
            or ( pparts.host ~= hostname )
            or ( pparts.port and pparts.port ~= port.number ) then
            return false
        end
    end
    return true
end

Driver = {

    new = function (self, host, port, options)
        local o = {}
        setmetatable(o, self)
        self.__index = self
        if not options.http_options then
        -- we need to supply the no_cache directive, or else the http library
        -- incorrectly tells us that the authentication was successful
        options.http_options = {
            no_cache = true,
            bypass_cache = true,
            redirect_ok = false,
            cookies = options.cookies,
            header = {
                -- nil just means not set, so default http.lua behavior
                Host = options.hostname,
                ["Content-Type"] = "application/x-www-form-urlencoded"
            }
        }
        end
        o.host = host
        o.port = port
        o.options = options
        -- each thread may store its params table here under its thread id
        options.threads = options.threads or {}
        return o
    end, 
    ------------------ new成员方法结束

    connect = function (self)
        -- This will cause problems, as there is no way for us to "reserve"
        -- a socket. We may end up here early with a set of credentials
        -- which won't be guessed until the end, due to socket exhaustion.
        return true
    end,

    submit_form = function (self, username, password)
        local path = self.options.path
        local tid = stdnse.gettid()
        local thread = self.options.threads[tid]
        if not thread then
            thread = {
                -- copy of form fields so we don't clobber another thread's passvar
                params = tcopy(self.options.formfields),
                -- copy of options so we don't clobber another thread's cookies
                opts = tcopy(self.options.http_options),
            }
            self.options.threads[tid] = thread
        end
        if self.options.sessioncookies and not (thread.opts.cookies and next(thread.opts.cookies)) then
            -- grab new session cookies
            local form, errmsg, cookies = detect_form(self.host, self.port, path, self.options.hostname)
            if not form then
                stdnse.debug1("Failed to get new session cookies: %s", errmsg)
            else
                thread.opts.cookies = cookies
                thread.params = form.fields
            end
        end
        local params = thread.params
        local opts = thread.opts
        local response
        -- 提交请求
        if self.options.method == "POST" then
            response = http.post(self.host, self.port, path, opts, nil,
            urlencode_form(params, self.options.uservar, username, self.options.passvar, password))
        else
            local uri = path
                .. (path:find("?", 1, true) and "&" or "?")
                .. urlencode_form(params, self.options.uservar, username, self.options.passvar, password)
            response = http.get(self.host, self.port, uri, opts)
        end
        local rcount = 0
        while response do       -- ...有必要弄这个while循环吗???(-_-#)
            if self.options.is_success and self.options.is_success(response) then
                opts.cookies = nil
                return response, true
            end
            update_cookies(opts.cookies, response.cookies)
            if self.options.is_failure and self.options.is_failure(response) then
                return response, false
            end
            local status = tonumber(response.status) or 0
            local rpath = response.header.location
            if not (status > 300 and status < 400 and rpath and rcount < max_rcount) then
                break
            end
            rcount = rcount + 1
            path = url.absolute(path, rpath)
            if path_ok(path, self.options.hostname, self.port) then
                -- clean up the url (cookie check fails if path contains hostname)
                -- this strips off the smallest prefix followed by a non-doubled /
                path = path:gsub("^.-%f[/](/%f[^/])","%1")
                response = http.get(self.host, self.port, path, opts)
            else
                -- being redirected off-host. Stop and assume failure.
                response = nil
            end
        end
        if response and self.options.is_failure then
            -- "log out" to avoid dumb login attempt limits
            opts.cookies = nil
        end
        -- Neither is_success nor is-failure condition applied. The login is deemed
        -- a success if the script is looking for a failure (which did not occur).
        return response, (response and self.options.is_failure)
    end,

    login = function (self, username, password)
        stdnse.verbose('current certification pair is ' .. username .. ' : ' .. password)
        local response, success = self:submit_form(username, password)
        if not response then
            local err = brute.Error:new("Form submission failed")
            err:setRetry(true)
        return false, err
        end
        if not success then
            return false, brute.Error:new("Incorrect password")
        end
        return true, creds.Account:new(username, password, creds.State.VALID)
    end,

    disconnect = function (self)
        return true
    end,

}

action = function (host, port)
    local path = stdnse.get_script_args('http-form-brute.path') or "/"
    local method = stdnse.get_script_args('http-form-brute.method')
    local uservar = stdnse.get_script_args('http-form-brute.uservar')
    local passvar = stdnse.get_script_args('http-form-brute.passvar')
    local onsuccess = stdnse.get_script_args('http-form-brute.onsuccess')
    local onfailure = stdnse.get_script_args('http-form-brute.onfailure')
    local hostname = stdnse.get_script_args('http-form-brute.hostname') or stdnse.get_hostname(host)
    local sessioncookies = stdnse.get_script_args('http-form-brute.sessioncookies')
    -- Originally intended more granular control with "always" or other strings
    -- to say when to grab new session cookies. For now, only boolean, though.
    if not sessioncookies then
        sessioncookies = true
    elseif sessioncookies == "false" then
        sessioncookies = false
    end

    local formfields = {}
    local cookies = {}
    -- 如果命令行没有指定密码域, 则需要脚本自行检测.
    if not passvar then
        local form, errmsg, dcookies = detect_form(host, port, path, hostname)
        if not form then
            return stdnse.format_output(false, errmsg)
        end
        path = form.action and url.absolute(path, form.action) or path
        method = method or form.method
        uservar = uservar or form.uservar
        passvar = passvar or form.passvar
        onsuccess = onsuccess or form.onsuccess
        onfailure = onfailure or form.onfailure
        formfields = form.fields or formfields
        cookies = dcookies or cookies
        sessioncookies = form.sessioncookies == nil and sessioncookies or form.sessioncookies
    end

    -- 保证表单提交url与当前主机同域, 否则没法用.
    if not path_ok(path, hostname, port) then
        return stdnse.format_output(false, string.format("Unusable form action %q", path))
    end
    stdnse.debug(form_debug, "Form submission path: " .. path)

    -- 默认请求方法为post类型
    method = string.upper(method or "POST")
    if not (method == "GET" or method == "POST") then
        return stdnse.format_output(false, string.format("Invalid HTTP method %q", method))
    end
    stdnse.debug(form_debug, "HTTP method: " .. method)

    -- passvar必须指定, 或是能自行检测到, uservar不是必选的...???
    if not passvar then
        return stdnse.format_output(false, "No passvar was specified or detected (see http-form-brute.passvar)")
    end
    stdnse.debug(form_debug, "Username field: " .. (uservar or "(not set)"))
    stdnse.debug(form_debug, "Password field: " .. passvar)

    -- 竟然也不需要前向声明
    if onsuccess and onfailure then
        return stdnse.format_output(false, "Either the onsuccess or onfailure argument should be passed, not both.")
    end

    -- is_success/is_failure最终还是要成为回调函数的
    -- 通过登录请求的响应体是否包含onsuccess/onfailure所表示的字符串来判断
    local is_success = onsuccess and (
        type(onsuccess) == "function" and onsuccess
        or function (response)
            return http.response_contains(response, onsuccess, true)
        end
    )
    local is_failure = onfailure and (
        type(onfailure) == "function" and onfailure
        or function (response)
            return http.response_contains(response, onfailure, true)
        end
    )
    -- the fallback test is to look for passvar field in the response
    if not (is_success or is_failure) then
        is_failure = function (response)
            return response.body and contains_form_field(response.body, passvar)
        end
    end

    local options = {
        path = path,
        method = method,
        uservar = uservar,
        passvar = passvar,
        is_success = is_success,
        is_failure = is_failure,
        hostname = hostname,
        formfields = formfields,
        cookies = cookies,
        sessioncookies = sessioncookies,
    }

    -- 验证表单提交行为(如果简单的提交都做不了就不用费事了...)
    local username = uservar and stdnse.generate_random_string(8)
    local password = stdnse.generate_random_string(8)
    local testdrv = Driver:new(host, port, options)
    -- 注意实例方法的调用方式, 用冒号, 与c++有点像
    local response, success = testdrv:submit_form(username, password)
    if not response then
        return stdnse.format_output(false, string.format("Failed to submit the form to path %q", path))
    end
    if success then
        return stdnse.format_output(false, "Failed to recognize failed authentication. See http-form-brute.onsuccess and http-form-brute.onfailure")
    end

    local engine = brute.Engine:new(Driver, host, port, options)
    -- there's a bug in http.lua that does not allow it to be called by
    -- multiple threads
    -- TODO: is this even true any more? We should fix it if not.
    engine:setMaxThreads(1)
    engine.options.script_name = SCRIPT_NAME
    engine.options:setOption("passonly", not uservar)

    local status, result = engine:start()
    return result
end
-------- action函数结束