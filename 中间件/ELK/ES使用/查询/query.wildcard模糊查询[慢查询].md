# query.wildcard模糊查询[慢查询]

可以使用通配符进行匹配.

```json
// GET 索引名称/_search
{
  "query": {
    "wildcard": {
      "该索引中某个字段的名称": {
        "value": "*test*"
      }
    }
  }
}
```

## 触发慢查询

由于模糊匹配其实是按通配符规则匹配, 那么只要把待匹配的规则写得足够复杂, 查询时就会耗费大量时间, 从而触发慢查询.

```json
// GET 索引名称/_search
{
  "query": {
    "wildcard": {
      "该索引中某个字段的名称": {
        "value": "*asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;**asdacxzcasdasdczxzc*asdfasd zxcanlsdai(sadsadlasl*asdasdlnalsdnl(asdasda;dm;*"
      }
    }
  }
}
```
