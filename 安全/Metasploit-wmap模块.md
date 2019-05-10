# Metasploit-wmap模块

<!tags!>: <!web漏洞!> <!漏洞扫描!> <!metasploit!> <!wmap!>

参考文章

1. [Metaspliot进行漏洞扫描(3)-wamp](http://www.2cto.com/article/201312/266601.html)

## 

启动`msfconsole`, 加载`wmap模块`

```
msf > load wmap

.-.-.-..-.-.-..---..---.
| | | || | | || | || |-'
`-----'`-'-'-'`-^-'`-'
[WMAP 1.5.1] ===  et [  ] metasploit.com 2012
[*] Successfully loaded plugin: wmap
msf > 
```

此时输入help, 即可得到wmap模块的帮助手册.

```
msf > help

wmap Commands
=============

    Command       Description
    -------       -----------
    wmap_modules  Manage wmap modules
    wmap_nodes    Manage nodes
    wmap_run      Test targets
    wmap_sites    Manage sites
    wmap_targets  Manage targets
    wmap_vulns    Display web vulns
```

`wmap_sites`命令是用来管理网站，所以我们要使用这个命令。输入`wmap_sites -h` ，它会显示用于管理所有网站使用的选项。

```
msf > wmap_sites -h
[*] Usage: wmap_sites [options]
	-h        Display this help text
	-a [url]  Add site (vhost,url)
	-d [ids]  Delete sites (separate ids with space)
	-l        List all available sites
	-s [id]   Display site structure (vhost,url|ids) (level) (unicode output true/false)
```

可以看到，`-a`选项添加一个站点。因此，让我们使用这个选项添加一个站点。输入`wmap_site -a <目标网站>`。

```
msf > wmap_sites -a 104.151.231.170
[*] Site created.
msf > wmap_sites -l
[*] Available sites
===============

     Id  Host             Vhost            Port  Proto  # Pages  # Forms
     --  ----             -----            ----  -----  -------  -------
     0   104.151.231.170  104.151.231.170  80    http   0        0

```

现在网站已添加，接下来添加目标。使用`wmap_targets -h`命令来列出所有`wmap_targets`用法选项

```
msf > wmap_targets -h
[*] Usage: wmap_targets [options]
	-h 		Display this help text
	-t [urls]	Define target sites (vhost1,url[space]vhost2,url) 
	-d [ids]	Define target sites (id1, id2, id3 ...)
	-c 		Clean target sites list
	-l  		List all target sites
```

正如我们可以在使用选项看到，我们可以通过两种方式添加我们的目标。一个是`-t`，为此我们必须提供目标URL。也可以使用`-d`，指定目标站点在`wmap_sites -l`中的ID。在这里，我们使用`-d`选项。

```
msf > wmap_targets -d 0
[*] Loading 104.151.231.170,http://104.151.231.170:80/.
msf > wmap_targets -l
[*] Defined targets
===============

     Id  Vhost            Host             Port  SSL    Path
     --  -----            ----             ----  ---    ----
     0   104.151.231.170  104.151.231.170  80    false  	/
```

现在一切都准备好了，目标被成功添加，我们可以运行我们的WMAP用于扫描Web应用程序。扫描命令`wmap_run`，但是，在运行此命令之前，检查所有的使用方式选项, 输入`wmap_run -h`.

```
msf > wmap_run -h
[*] Usage: wmap_run [options]
	-h                        Display this help text
	-t                        Show all enabled modules
	-m [regex]                Launch only modules that name match provided regex.
	-p [regex]                Only test path defined by regex.
	-e [/path/to/profile]     Launch profile modules against all matched targets.
	                          (No profile file runs all enabled modules.)
```

`-t`选项是显示此次检查所有启用的模块，用于扫描。所以输入`wmap_run -t`.

```
msf > wmap_run -t
[*] Testing target:
[*] 	Site: 104.151.231.170 (104.151.231.170)
[*] 	Port: 80 SSL: false
============================================================
[*] Testing started. 2017-06-05 20:31:02 +0800
[*] Loading wmap modules...
[*] 40 wmap enabled modules loaded.
[*] 
=[ SSL testing ]=
============================================================
[*] Target is not SSL. SSL modules disabled.
[*] 
=[ Web Server testing ]=
============================================================
[*] Module auxiliary/scanner/http/http_version
[*] Module auxiliary/scanner/http/open_proxy
[*] Module auxiliary/admin/http/tomcat_administration
[*] Module auxiliary/admin/http/tomcat_utf8_traversal
[*] Module auxiliary/scanner/http/drupal_views_user_enum
[*] Module auxiliary/scanner/http/frontpage_login
[*] Module auxiliary/scanner/http/host_header_injection
[*] Module auxiliary/scanner/http/options
[*] Module auxiliary/scanner/http/robots_txt
[*] Module auxiliary/scanner/http/scraper
[*] Module auxiliary/scanner/http/svn_scanner
[*] Module auxiliary/scanner/http/trace
[*] Module auxiliary/scanner/http/vhost_scanner
[*] Module auxiliary/scanner/http/webdav_internal_ip
[*] Module auxiliary/scanner/http/webdav_scanner
[*] Module auxiliary/scanner/http/webdav_website_content
[*] 
=[ File/Dir testing ]=
============================================================
[*] Module auxiliary/dos/http/apache_range_dos
[*] Module auxiliary/scanner/http/backup_file
[*] Module auxiliary/scanner/http/brute_dirs
[*] Module auxiliary/scanner/http/copy_of_file
[*] Module auxiliary/scanner/http/dir_listing
[*] Module auxiliary/scanner/http/dir_scanner
[*] Module auxiliary/scanner/http/dir_webdav_unicode_bypass
[*] Module auxiliary/scanner/http/file_same_name_dir
[*] Module auxiliary/scanner/http/files_dir
[*] Module auxiliary/scanner/http/http_put
[*] Module auxiliary/scanner/http/ms09_020_webdav_unicode_bypass
[*] Module auxiliary/scanner/http/prev_dir_same_name_file
[*] Module auxiliary/scanner/http/replace_ext
[*] Module auxiliary/scanner/http/soap_xml
[*] Module auxiliary/scanner/http/trace_axd
[*] Module auxiliary/scanner/http/verb_auth_bypass
[*] 
=[ Unique Query testing ]=
============================================================
[*] Module auxiliary/scanner/http/blind_sql_query
[*] Module auxiliary/scanner/http/error_sql_injection
[*] Module auxiliary/scanner/http/http_traversal
[*] Module auxiliary/scanner/http/rails_mass_assignment
[*] Module exploit/multi/http/lcms_php_exec
[*] 
=[ Query testing ]=
============================================================
[*] 
=[ General testing ]=
============================================================
[*] Done.
```

现在，键入`wmap_run -e` ，它会开始执行所有启用的模块进行扫描. 这将需要一些时间，具体取决于有多大的应用.

```
msf > wmap_run -e
[*] Using ALL wmap enabled modules.
[-] NO WMAP NODES DEFINED. Executing local modules
[*] Testing target:
[*] 	Site: 104.151.231.170 (104.151.231.170)
[*] 	Port: 80 SSL: false
============================================================
[*] Testing started. 2017-06-05 20:33:33 +0800

...
...

=[ Query testing ]=
============================================================
[*] 
=[ General testing ]=
============================================================
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Launch completed in 6.694957256317139 seconds.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
[*] Done.
```

输入vulns查询扫描到的所有漏洞.

...call, 竟然没有