## 见[note-cloud]()仓库中的 bashrc.sh 脚本吧

## @function: 为man手册页设置颜色高亮显示(很漂亮)
man() {
  env \
  LESS_TERMCAP_mb=$(printf "\e[1;31m") \
  LESS_TERMCAP_md=$(printf "\e[1;31m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;32m") \
  man "$@"
}

## @function: 为目标文件计算md5值并将其移动(MacOS)
## $1:        目标文件路径
function mdit
{
    ## md5 的结果如下, 需要裁切
    ## MD5 (2C0155F5-DEA0-4188-8840-F98838DCBA51.png) = 06a52288d8f045e4c41550b737e016ba
    md5_result=$(md5 $1)
    ## 从左向右, 删除到" = ", 保留右侧
    md5_val=${md5_result##* = }

    filename=$(basename $1)
    dirname=$(dirname $1)
    suffix=${filename##*.}
    new_file=${dirname}/${md5_val}.${suffix}

    echo $md5_val
    mv $1 $new_file
}

## @function: 为目标文件计算md5值并将其移动(Linux)
## $1:        目标文件路径
function mdit
{
    ## md5 的结果如下, 需要裁切
    ## 06a52288d8f045e4c41550b737e016ba  2C0155F5-DEA0-4188-8840-F98838DCBA51.png
    md5_result=$(md5sum $1)
    ## 从右向左, 删除到空格, 保留左侧
    md5_val=${md5_result%% *}

    filename=$(basename $1)
    dirname=$(dirname $1)
    suffix=${filename##*.}
    new_file=${dirname}/${md5_val}.${suffix}

    echo $md5_val
    mv $1 $new_file
}
