
## rerun

一个模块化的shell自动化框架，基于[rerun/rerun](https://github.com/rerun/rerun)的修改版本，并非官方版本。

修改版做了一些新的特性，以满足更好的使用。主要增加了命名空间模块功能、优化交互展示等。

## 截图
![ghbjayce-rerun-1.5.x.png](https://raw.githubusercontent.com/GHBJayce/Assets/feat/v1.0.0/project/ghbjayce-rerun/ghbjayce-rerun-1.5.x.png)

## 安装
```bash
git clone git@github.com:GHBJayce/rerun.git
cd rerun
git checkout feat/1.5.x
vi ~/.bash_profile
# 输入以下内容，保存退出
export RERUN_ROOT_PATH=替换成rerun所在的目录，绝对路径
export PATH=$PATH:$RERUN_ROOT_PATH
export RERUN_MODULES="$RERUN_ROOT_PATH/modules"
export RERUN_COLOR=true
source ~/.bash_profile
```

## 使用
```bash
# 展示所有可用命令
rerun
# 添加模块
rerun stubbs:add-module --module git --description "description"
# 添加命名空间模块
rerun stubbs:add-module --module jayce/git --description "description"
# 添加git:push命令
rerun stubbs:add-command --module git --command push --description "description"
# 添加git:push --remote参数
rerun stubbs:add-option --module git --command push --required false --export false --default 'start' --option remote --description "description"
# 移除git:push命令
rerun stubbs:rm-command --module git --command push
# 移除git:push --remote参数
rerun stubbs:rm-option --module jayce --command push --option remote
```

## 声明

该项目目前仅用于学习参考，开源协议遵从[rerun/rerun](https://github.com/rerun/rerun)，并且会尽快补充协议相关的内容。

感谢[rerun/rerun](https://github.com/rerun/rerun)项目以及他们的开发团队，非常棒的开源项目，我从中学到了很多优秀的东西。