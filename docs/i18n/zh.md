<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-0A84FF?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**应用本身，以及它留下的一切。**

把应用拖进废纸篓，只是去掉了图标。偏好设置、缓存、容器、日志和启动项仍留在资源库里。它们继续占空间，下次重装还会回来。

Banish 会找出这些文件，在移动任何东西之前先给你看，并且只把你选中的内容送进废纸篓。每一项都可以放回去。没有永久删除。

<p><img src="../images/library.png" alt="Banish 中的已安装应用" width="920"></p>

## 你会看到什么

侧边栏列出已安装的应用，带有版本和大小。绿点表示应用正在运行。搜索可以是名称，也可以是包标识，例如 `com.google.Chrome`。

选中后会出现三个数字：应用本身的大小、找到的相关文件大小，以及当前选中、将会进入废纸篓的大小。

**相关文件**按包标识匹配，默认选中。**名称匹配**只是名字相同，所以在你查看路径之前保持未选中。

<p><img src="../images/detail.png" alt="Banish 中的 Chrome 及相关文件" width="920"></p>

## 确认之前，什么都不会动

**Move to Trash** 会打开确认页，显示数量和大小。移动按钮不是默认按钮，所以回车不会误确认。

`/Applications` 里的应用属于 macOS，普通移动会被拒绝。确认页会说明可能需要密码。你确认之后，macOS 询问一次，Banish 再把选中项移入废纸篓。

<p><img src="../images/confirm.png" alt="把 Chrome 移入废纸篓之前的确认" width="920"></p>

取消密码对话框，移动就会停止。还没移动的留在原地。已经进废纸篓的可以放回去。

## 它看哪里

Banish 不会扫描整块磁盘。它只看已知的资源库文件夹，而且只有一两层：偏好设置、Application Support、缓存、日志、容器、标识相符时的网页数据、启动项，以及保存的状态。

强匹配用的是包标识。`com.foo.app` 不会收走 `com.foo.application` 或 `com.foo.app2`。`Google/Chrome` 可以属于 Chrome。`Google/Earth` 不会，仅仅因为有一个词相同。

## 它不会碰什么

`/System`、`/usr`、`/bin`、`/private` 这类系统位置。你的文稿、桌面、下载、照片和音乐。邮件、信息、照片、Safari、钥匙串、日历和备忘录。`~/.ssh`，以及作为删除来源的废纸篓本身。符号链接。还有正在运行的 Banish：应用不能移动自己。

Finder、Safari 和 Mail 这类核心 Apple 应用保持锁定。Keynote、Pages、Numbers 这类可选 Apple 应用可以移除，并会给出明确警告。系统应用默认隐藏，可从显示菜单或设置里打开。

## 权限

只有当 macOS 拒绝把应用移出“应用程序”文件夹时，才会询问**管理员密码**。对话框是系统对话框，上面写的是 Banish。

**完全磁盘访问权限**是可选的。它让 Banish 读取 macOS 本来会隐藏的容器和缓存。没有它，列表仍然可用；某个文件夹读不了时，会出现一条提示。

系统设置 → 隐私与安全性 → 完全磁盘访问权限

## 应用内的语言

窗口跟随 Mac 的语言。阿拉伯语从右向左。设置里可以把语言固定为阿拉伯语或英语。

<p><img src="../images/settings.png" alt="Banish 的设置" width="540"></p>

## 构建

需要 macOS 14 或更高版本，以及 Swift 6。没有第三方库。

```bash
./Scripts/build-app.sh
open build/Banish.app
```

也可以 `make app` 再 `make run`。测试用 `make test`。签过名的应用在 `build/Banish.app`。
