#!/bin/bash -ex

git_repository="/home/delxie/Documents/repository-git/"

git_project="zkp-pbms"

#跳转到项目文件夹下
cd $git_repository'/'$git_project

#检查文件的状态
git status

#git status -s或者git status --short 简化输出

#跟踪新文件
git add .

#该命令将您的工作目录中的内容与您的暂存区中的内容进行比较。结果告诉您您尚未commit的更改
git diff

git diff --staged

git diff --cached

#会对文件进行删除,下次提交时，该文件将被删除，不再被跟踪
git rm README.md

#您可能希望将文件保存在硬盘驱动器上，但不要将Git跟踪。如果您忘记向.gitignore文件中添加某些内容并意外上演，则会特别有用，如大型日志文件或一堆已.a编译的文件。为此，请使用以下--cached选项：
git rm --cached README

#重命名
git mv README.md README

#查看提交历史记录
git log


#更有用的选项之一是-p显示每个提交中引入的差异。您也可以使用-2，其限制输出只有最后两个条目
git log -p -2

#要查看每个提交的一些缩写统计信息，可以使用以下--stat选项
git log --stat

git log --pretty=format:"%h - %an, %ar : %s"

#如果你承诺，然后意识到你忘了在一个你想添加到这个提交的文件中进行更改，你可以这样做,你最终得到一个提交 - 第二个提交将替换第一个commit的结果。
git commit -m 'initial commit'
git add forgotten_file
git commit --amend

#果你意识到你不想保留对CONTRIBUTING.md文件的更改怎么办？你如何轻松地修改它,将其恢复到最后一次提交时
#它明确地告诉你如何丢弃你所做的更改。让我们做它说的话
git checkout -- [filename]


#在Git中创建一个注释标签很简单。最简单的方法是指定-a运行tag命令
git tag -a v1.4 -m "my version 1.4"

git show v1.4

#要标记该提交，请在命令结束时指定提交校验和（或其一部分）
git tag -a v1.2 9fceb02

#将标签显式推送到共享服务器
git push origin [tagname]

#如果您有很多标签要一次性向上推，您还可以使用--tags该git push命令的选项。这将会将您所有的标签转移到尚未存在的远程服务器
git push origin --tags

#你不能在Git中checkout一个标签，因为它们不能被移动。如果要将版本的存储库放在工作目录中，看起来像一个特定的标签，您可以在特定的标签上创建一个新的分支
git checkout -b [branchname] [tagname]

