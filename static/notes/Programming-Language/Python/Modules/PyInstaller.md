# PyInstaller 库

将 .py 源代码转换成不需要编译或解释的可执行文件（机器码）

使用方法：

cmd终端中输入`pyinstaller -F <文件名.py>`

参数|描述
--|--
pyinstaller -h|查看帮助
pyinstaller --clean|清除打包过程中生成的临时文件
pyinstaller -D, --onedir|默认值，生成 dist 文件夹
pyinstaller -F, --onefile|在 dist 文件夹中只生成独立的打包文件
pyinstaller -i <图标文件名.ico> -F <文件名.py>|指定打包程序使用的图标（icon）文件

