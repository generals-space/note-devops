```
curl -u elastic:f6yM26MZ '192.168.34.16:9211/_cat/health?format=json&pretty=true'
curl -u elastic:f6yM26MZ '192.168.34.16:9211/_cat/indices'
curl -u elastic:f6yM26MZ '192.168.34.16:9211/article01/_search'
```

```bash
curl -u elastic:f6yM26MZ -XPOST -H 'Content-Type: application/json' "192.168.34.16:9211/article01/_doc/0" -d '
    {
        "id": 0,
        "title": "hello world",
        "author": "general",
        "content": "Because the speaker and play_name fields are keyword fields, they are not analyzed. The strings are treated as a single unit even if they contain multiple words.",
        "date": "2020-01-01 12:00:00"
    }
'
```

```bash
for i in $(seq 10000); do
    echo ;
    echo $i;

    curl -u elastic:f6yM26MZ -XPOST -H 'Content-Type: application/json' "192.168.34.16:9211/article01/_doc/" -d '
        {
            "id": "$i",
            "title": "hello world",
            "author": "general",
            "content": "Because the speaker and play_name fields are keyword fields, they are not analyzed. The strings are treated as a single unit even if they contain multiple words.",
            "date": "2020-01-01 12:00:00"
        }
    '
done
```
