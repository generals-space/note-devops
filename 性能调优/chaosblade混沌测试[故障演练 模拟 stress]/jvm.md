
```
blade prepare jvm --help
Attach a type agent to the jvm process for java framework experiment.

Usage:
  blade prepare jvm

Examples:
prepare jvm --process tomcat

Flags:
  -a, --async             whether to attach asynchronously, default is false
  -e, --endpoint string   the attach result reporting address. It takes effect only when the async value is true and the value is not empty
  -h, --help              help for jvm
  -j, --javaHome string   the java jdk home path
  -n, --nohup             used to internal async attach, no need to config
      --pid string        the target java process id
  -P, --port int          the port used for agent server
  -p, --process string    the java application process name (required)
  -u, --uid string        used to internal async attach, no need to config

```

```
$ blade create jvm --help
Experiment with the JVM, and you can specify classes, method injection delays, return values, exception failure scenarios, or write Groovy and Java scripts to implement complex scenarios.

Usage:
  blade create jvm [flags]
  blade create jvm [command]

Available Commands:
  CodeCacheFilling       Fill up code cache.
  OutOfMemoryError       JVM out of memory
  cpufullload            Process occupied cpu full load
  delay                  delay time
  return                 Return the specify value
  script                 Dynamically execute custom scripts
  throwCustomException   throw custom exception
  throwDeclaredException Throw the first declared exception of method
```
