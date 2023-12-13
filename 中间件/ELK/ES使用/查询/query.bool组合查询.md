```json
{
    "query": {
        "bool": {
            "must": [
                {
                    "range": {
                        "logTime": {
                            "gte": "2021-07-29 18:40.37",
                            "lte": "2021-07-30 18:40.37"
                        }
                    }
                },
                {
                    "term": {
                        "clusterName": {
                            "value": "xxxxxxx"
                        }
                    }
                }
            ]
        }
    }
}
```

与`must`同级的还有`must_not`, 整个`query.bool`语句可以看作是一个`if()`查询.
