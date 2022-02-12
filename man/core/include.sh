
# 用户自定义公共函数批量引入
userFuncPath="${RERUN_ROOT_PATH}/user/function"
if [ $(ls $userFuncPath | wc -l) -gt 0 ]; then
    userFuncFileList=$(ls $userFuncPath | grep '.sh')
    for userFuncFileName in ${userFuncFileList[@]}; do
        source "${userFuncPath}/${userFuncFileName}"
    done
fi